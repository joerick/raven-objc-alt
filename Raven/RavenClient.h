//
//  RavenClient.h
//  Raven
//
//  Created by Kevin Renskers on 25-05-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RavenMessage.h"

#define RavenLog( s, ... ) [[RavenClient sharedClient] send: \
                            [RavenMessage messageWithLevel:kRavenLogLevelInfo \
                                                    format:(s), ##__VA_ARGS__]]


@interface RavenClient : NSObject

+ (RavenClient *)sharedClient;
+ (void)setupExceptionHandler;

+ (void)setupSharedClientDSN:(NSString *)DSN;

@property (strong, nonatomic) NSString *DSN;

@property (strong, nonatomic) NSDictionary *extra;
@property (strong, nonatomic) NSDictionary *tags;
@property (strong, nonatomic) NSDictionary *user;

/**
 * If this property is true will send default tags in addition to any supplied in the tags property:
 * - Build version
 * - Device model (on iOS)
 * - OS version (on iOS)
 * 
 * By default, this is true.
 */
@property (assign, nonatomic) BOOL sendDefaultTags;

/**
 * Sends the RavenMessage now.
 */
- (void)send:(RavenMessage *)message;

/**
 * Saves the RavenMessage, to be sent on the next call to -sendDeferred. Messages are persisted to disk, so this is
 * useful when the app is going to crash.
 */
- (void)defer:(RavenMessage *)message;

/**
 * Sends any messages previously deferred using -defer:
 */
- (void)sendDeferred;

@end


@interface RavenClient (Convenience)

- (void)captureMessage:(NSString *)message;
- (void)captureMessage:(NSString *)message level:(RavenLogLevel)level;
- (void)captureError:(NSError *)error;
- (void)captureException:(NSException *)exception;

@end
