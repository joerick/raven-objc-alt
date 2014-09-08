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

/**
 * Convenience method to setup Raven in one line.
 *
 * Call from the -applicationDidFinishLaunching: method.
 *
 * This will set the shared client's DSN, install the exception handler and send any previously deferred messages.
 */
+ (void)setupSharedClientDSN:(NSString *)DSN;

+ (RavenClient *)sharedClient;
+ (void)setupExceptionHandler;

@property (strong, nonatomic) NSString *DSN;

/**
 * Any additional key-value pairs to add to each message sent. Must be JSON-serializable.
 */
@property (strong, nonatomic) NSDictionary *extra;

/**
 * Any tags to be appended to each message sent
 */
@property (strong, nonatomic) NSDictionary *tags;

/**
 * Should contain at least an "id" key. Can also contain any other information such as email address, username.
 */
@property (strong, nonatomic) NSDictionary *user;

/**
 * If this property is true will send default tags in addition to any supplied in the tags property:
 * - Build version
 * - Device model
 * - OS version (on iOS)
 * 
 * By default, this is true.
 */
@property (assign, nonatomic) BOOL sendDefaultTags;

/**
 * Send a RavenMessage now.
 */
- (void)send:(RavenMessage *)message;

/**
 * Save the RavenMessage, to be sent on the next call to -sendDeferred. Messages are persisted to disk, so this is
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
