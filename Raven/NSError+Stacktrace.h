//
//  NSError+JSErrorStacktrace.h
//  JSErrorStacktrace_SampleProject
//
//  Created by Javier Soto on 3/20/13.
//  Copyright (c) 2013 Javier Soto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Stacktrace)

- (NSString *)stacktrace;

@end
