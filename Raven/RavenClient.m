//
//  RavenClient.m
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <sys/utsname.h>
#import "RavenClient.h"
#import "RavenConfig.h"

NSString *const userDefaultsKey = @"com.getmixim.RavenClient";


@interface RavenClient () <NSURLConnectionDelegate>

@property (strong, nonatomic) RavenConfig *config;
@property (copy, nonatomic) NSArray *deferredMessages;

- (NSDictionary *)tagsWithDefaults;
- (NSDictionary *)defaultTags;

@end

void exceptionHandler(NSException *exception)
{
	[[RavenClient sharedClient] defer:[RavenMessage messageWithException:exception
                                                                   level:kRavenLogLevelFatal]];
}

@implementation RavenClient

#pragma mark - Class

+ (RavenClient *)sharedClient
{
    static RavenClient *result = nil;
    
    @synchronized(self) {
        if (!result) {
            result = [[self alloc] init];
        }
    }
    
    return result;
}

+ (void)setupExceptionHandler
{
    NSSetUncaughtExceptionHandler(&exceptionHandler);
}

+ (void)setupSharedClientDSN:(NSString *)DSN
{
    [RavenClient sharedClient].DSN = DSN;
    [[RavenClient sharedClient] sendDeferred];
    
    [RavenClient setupExceptionHandler];
}

#pragma mark - Instance

- (void)send:(RavenMessage *)message
{
    if (!message.user) {
        message.user = self.user;
    }
    
    NSDictionary *messageDictionary = [message dictionaryRepresentationWithExtra:self.extra tags:self.tags];
    
    NSError *error = nil;
    
    NSData *messageJSON = [NSJSONSerialization dataWithJSONObject:messageDictionary
                                                          options:0
                                                            error:&error];
    
    if (!messageJSON) {
        NSLog(@"Failed to serialize raven message. %@", error);
        
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.config.serverURL];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[messageJSON length]]
   forHTTPHeaderField:@"Content-Length"];

    [request setHTTPBody:messageJSON];
    [request setValue:[NSString stringWithFormat:
                       @"Sentry sentry_version=5, sentry_client=raven-objc-alt/0.1.0, sentry_timestamp=%ld, sentry_key=%@, sentry_secret=%@",
                       (long)[[NSDate date] timeIntervalSince1970],
                       self.config.publicKey,
                       self.config.secretKey]
   forHTTPHeaderField:@"X-Sentry-Auth"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                               
                               BOOL httpSuccess = httpResponse.statusCode == 200;
                               
                               if (connectionError) {
                                   NSLog(@"Failed to send event to Sentry! %@ %@",
                                         connectionError.localizedDescription,
                                         connectionError.userInfo[NSURLErrorFailingURLStringErrorKey]);
                               } else if (!httpSuccess) {
                                   NSLog(@"Failed to log event with Sentry! Server error %li %@",
                                         (long)httpResponse.statusCode,
                                         httpResponse.allHeaderFields[@"X-Sentry-Error"]);
                               } else {
                                   NSLog(@"Event sent to Sentry");
                               }
                           }];
}

- (void)defer:(RavenMessage *)message
{
    self.deferredMessages = [self.deferredMessages arrayByAddingObject:message];
}

- (void)sendDeferred
{
    for (RavenMessage *message in self.deferredMessages) {
        [self send:message];
    }
    
    self.deferredMessages = @[];
}

#pragma mark - Properties

- (NSString *)DSN
{
    return self.config.DSN;
}

- (void)setDSN:(NSString *)DSN
{
    self.config = [[RavenConfig alloc] initWithDSN:DSN];
}

#pragma mark - Private

- (NSDictionary *)tagsWithDefaults
{
    NSMutableDictionary *result = [self.tags mutableCopy];
    
    if (self.sendDefaultTags) {
        [result addEntriesFromDictionary:self.defaultTags];
    }
    
    return result;
}

- (NSDictionary *)defaultTags
{
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithUTF8String:systemInfo.machine];

#if TARGET_OS_IPHONE
    return @{ @"Build version": buildVersion,
              @"Device model": deviceModel,
              @"OS version": [[UIDevice currentDevice] systemVersion] };
#else
    return @{ @"Build version": buildVersion,
              @"Device model": deviceModel };
#endif
}

- (NSArray *)deferredMessages
{
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:userDefaultsKey];
    
    if (!data) {
        return @[];
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data] ?: @[];
}

- (void)setDeferredMessages:(NSArray *)deferredMessages
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:deferredMessages]
                                              forKey:userDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation RavenClient (Convenience)

- (void)captureMessage:(NSString *)message
{
    [self send:[RavenMessage messageWithString:message]];
}

- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level
{
    [self send:[RavenMessage messageWithString:message level:level]];
}

- (void)captureError:(NSError *)error
{
    [self send:[RavenMessage messageWithError:error]];
}

- (void)captureException:(NSException *)exception
{
    [self send:[RavenMessage messageWithException:exception]];
}

@end
