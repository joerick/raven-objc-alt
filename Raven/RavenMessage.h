//
//  RavenMessage.h
//  Raven
//
//  Created by Joe Rickerby on 20/08/2014.
//  Copyright (c) 2014 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kRavenLogLevelDebug,
    kRavenLogLevelInfo,
    kRavenLogLevelWarning,
    kRavenLogLevelError,
    kRavenLogLevelFatal
} RavenLogLevel;

@interface RavenMessage : NSObject <NSCoding>

+ (instancetype)messageWithString:(NSString *)messageString;
+ (instancetype)messageWithString:(NSString *)messageString level:(RavenLogLevel)level;
+ (instancetype)messageWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
+ (instancetype)messageWithLevel:(RavenLogLevel)level format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
+ (instancetype)messageWithError:(NSError *)error;
+ (instancetype)messageWithError:(NSError *)error level:(RavenLogLevel)level;
+ (instancetype)messageWithException:(NSException *)exception;
+ (instancetype)messageWithException:(NSException *)exception level:(RavenLogLevel)level;

@property (copy) NSString *message;
@property (copy) NSDate *timestamp;
@property (assign) RavenLogLevel level;
@property (copy) NSString *culprit;
@property (copy) NSDictionary *extra;
@property (copy) NSDictionary *tags;
@property (copy) NSDictionary *stacktrace;
@property (copy) NSDictionary *exception;
@property (copy) NSDictionary *user;
@property (copy) NSString *formatString;

/**
 * Get the message as a dictionary, ready to be encoded as JSON and sent to sentry.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 * Get the message as a dictionary, ready to be encoded as JSON and sent to sentry.
 * The extra and tags parameters will be merged with those on this message, with the message entries taking priority.
 */
- (NSDictionary *)dictionaryRepresentationWithExtra:(NSDictionary *)extra tags:(NSDictionary *)tags;

/**
 * Use to convert a callstack symbols array (from +[NSThread callStackSymbols], for example) to a dictionary suitable
 * for the 'stacktrace' property.
 */
+ (NSDictionary *)stacktraceDictFromCallStackSymbols:(NSArray *)callStackSymbols;

@end
