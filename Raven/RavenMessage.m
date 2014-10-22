//
//  RavenMessage.m
//  Raven
//
//  Created by Joe Rickerby on 20/08/2014.
//  Copyright (c) 2014 Gangverk. All rights reserved.
//

#import "RavenMessage.h"

NSString *const kRavenLogLevelArray[] = {
    @"debug",
    @"info",
    @"warning",
    @"error",
    @"fatal"
};

RavenLogLevel kRavenMessageDefaultLevel = kRavenLogLevelInfo;

@implementation RavenMessage

+ (instancetype)messageWithString:(NSString *)messageString
{
    return [self messageWithString:messageString level:kRavenMessageDefaultLevel];
}

+ (instancetype)messageWithString:(NSString *)messageString level:(RavenLogLevel)level
{
    RavenMessage *result = [RavenMessage new];
    
    result.message = messageString;
    result.level = level;
    
    return result;
}

+ (instancetype)messageWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    RavenMessage *result = [RavenMessage new];
    
    result.message = [[NSString alloc] initWithFormat:format arguments:args];
    result.formatString = format;
    
    va_end(args);
    
    return result;
}

+ (instancetype)messageWithLevel:(RavenLogLevel)level format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    
    RavenMessage *result = [RavenMessage new];
    
    result.message = [[NSString alloc] initWithFormat:format arguments:args];
    result.formatString = format;
    
    va_end(args);
    
    result.level = level;
    
    return result;
}

+ (instancetype)messageWithError:(NSError *)error
{
    return [self messageWithError:error level:kRavenLogLevelError];
}

+ (instancetype)messageWithError:(NSError *)error level:(RavenLogLevel)level
{
    RavenMessage *result = [RavenMessage new];
    
    result.message = error.localizedDescription;
    result.extra = [RavenMessage extraDictionaryForError:error];
    result.level = level;
    
    if ([error respondsToSelector:@selector(stacktrace)]) {
        NSArray *callStack = [error performSelector:@selector(stacktrace)];
        result.stacktrace = [RavenMessage stacktraceDictFromCallStackSymbols:callStack];
    }
    
    return result;
}

+ (instancetype)messageWithException:(NSException *)exception
{
    return [self messageWithException:exception level:kRavenLogLevelError];
}

+ (instancetype)messageWithException:(NSException *)exception level:(RavenLogLevel)level
{
    RavenMessage *result = [RavenMessage new];
    
    result.message = [NSString stringWithFormat:@"%@: %@", exception.name, exception.reason];
    result.extra = exception.userInfo;
    result.level = level;
    result.exception = @{ @"type": exception.name,
                          @"value": exception.reason,
                          @"stacktrace": [RavenMessage stacktraceDictFromCallStackSymbols:exception.callStackSymbols] };
    
    return result;
}

#pragma mark Instance

- (id)init
{
    self = [super init];
    
    if (self) {
        // set default values
        self.level = kRavenMessageDefaultLevel;
        self.timestamp = [NSDate date];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryRepresentationWithExtra:nil tags:nil];
}

- (NSDictionary *)dictionaryRepresentationWithExtra:(NSDictionary *)defaultExtra tags:(NSDictionary *)defaultTags
{
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:defaultExtra];
    [extra addEntriesFromDictionary:self.extra];
    
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary:defaultTags];
    [tags addEntriesFromDictionary:self.tags];
    
    NSMutableDictionary *result = [@{ @"event_id": [RavenMessage eventId],
                                      @"timestamp": [[RavenMessage dateFormatter] stringFromDate:self.timestamp],
                                      @"level": kRavenLogLevelArray[self.level],
                                      @"platform": @"objc",
                                      @"extra": extra,
                                      @"tags": tags,
                                      @"message": self.message ?: [NSNull null],
                                      @"culprit": self.culprit ?: [NSNull null],
                                      @"sentry.interfaces.Stacktrace": self.stacktrace ?: [NSNull null],
                                      @"sentry.interfaces.Exception": self.exception ?: [NSNull null],
                                      @"sentry.interfaces.User": self.user ?: [NSNull null],
                                      @"sentry.interfaces.Message": (self.formatString
                                                                     ? @{ @"message": self.formatString }
                                                                     : [NSNull null]) }
                                   mutableCopy];
    
    // remove all the null objects
    [result removeObjectsForKeys:[result allKeysForObject:[NSNull null]]];

    return result;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.message = [aDecoder decodeObjectForKey:@"message"];
        self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
        self.level = [aDecoder decodeIntForKey:@"level"];
        self.culprit = [aDecoder decodeObjectForKey:@"culprit"];
        self.extra = [aDecoder decodeObjectForKey:@"extra"];
        self.tags = [aDecoder decodeObjectForKey:@"tags"];
        self.stacktrace = [aDecoder decodeObjectForKey:@"stacktrace"];
        self.exception = [aDecoder decodeObjectForKey:@"exception"];
        self.user = [aDecoder decodeObjectForKey:@"user"];
        self.formatString = [aDecoder decodeObjectForKey:@"formatString"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.message forKey:@"message"];
    [aCoder encodeObject:self.timestamp forKey:@"timestamp"];
    [aCoder encodeInt:self.level forKey:@"level"];
    [aCoder encodeObject:self.culprit forKey:@"culprit"];
    [aCoder encodeObject:self.extra forKey:@"extra"];
    [aCoder encodeObject:self.tags forKey:@"tags"];
    [aCoder encodeObject:self.stacktrace forKey:@"stacktrace"];
    [aCoder encodeObject:self.exception forKey:@"exception"];
    [aCoder encodeObject:self.user forKey:@"user"];
    [aCoder encodeObject:self.formatString forKey:@"formatString"];
}

#pragma mark Private

+ (NSString *)eventId
{
    return [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *result = nil;
    
    if (!result) {
        result = [[NSDateFormatter alloc] init];
        
        [result setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [result setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    
    return result;
}

+ (NSDictionary *)stacktraceDictFromCallStackSymbols:(NSArray *)callStackSymbols
{
    NSMutableArray *frames = [NSMutableArray array];
    
    for (NSString *frame in [callStackSymbols reverseObjectEnumerator]) {
        [frames addObject:@{ @"function": frame }];
    }
    
    return @{ @"frames": frames };
}

+ (NSDictionary *)extraDictionaryForError:(NSError *)error
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    result[@"domain"] = error.domain;
    result[@"code"] = @(error.code);
    
    for (NSString *key in error.userInfo) {
        id value = error.userInfo[key];
        
        if ([NSJSONSerialization isValidJSONObject:value]) {
            result[key] = value;
        } else if ([value isKindOfClass:[NSError class]]) {
            result[key] = [self extraDictionaryForError:value];
        } else {
            result[key] = [value description];
        }
    }
    
    return result;
}

@end
