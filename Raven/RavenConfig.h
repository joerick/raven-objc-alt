//
//  RavenConfig.h
//  Raven
//
//  Created by David Cramer on 12/28/12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RavenConfig : NSObject

- (instancetype)initWithDSN:(NSString *)DSN;

@property (strong, nonatomic, readonly) NSString *DSN;

@property (strong, nonatomic, readonly) NSURL *serverURL;
@property (strong, nonatomic, readonly) NSString *publicKey;
@property (strong, nonatomic, readonly) NSString *secretKey;
@property (strong, nonatomic, readonly) NSString *projectId;

@end
