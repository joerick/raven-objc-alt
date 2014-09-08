//
//  NSError+Stacktrace.m
//
//  Created by Javier Soto on 3/20/13.
//  Copyright (c) 2013 Javier Soto. All rights reserved.
//

#import "NSError+Stacktrace.h"

#import <objc/runtime.h>

@implementation NSError (Stacktrace)

- (NSString *)stacktrace
{
    return objc_getAssociatedObject(self, "stacktrace");
}

- (void)storeStacktrace
{
    NSArray *stackFrames = [NSThread callStackSymbols];
    
    // trim any NSError-related frames so the last frame is the one that created the NSError
    int i;
    for (i = 0; i < stackFrames.count; i++) {
        NSString *frame = stackFrames[i];
        
        if ([frame rangeOfString:@"[NSError"].location == NSNotFound) {
            break;
        }
    }
    
    NSArray *trimmedFrames = [stackFrames subarrayWithRange:NSMakeRange(i, stackFrames.count - i)];
    
    objc_setAssociatedObject(self, "stacktrace", trimmedFrames, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Swizzled Method

- (id)init_jsswizzledInitWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    [self storeStacktrace];
    
    // Call original implementation
    return [self init_jsswizzledInitWithDomain:domain code:code userInfo:dict];
}

@end

static void __attribute__((constructor)) JSErrorStacktraceInstall()
{
    Class NSErrorClass = [NSError class];

    Method originalInitMethod = class_getInstanceMethod(NSErrorClass, @selector(initWithDomain:code:userInfo:));
    Method swizzledInitMethod = class_getInstanceMethod(NSErrorClass, @selector(init_jsswizzledInitWithDomain:code:userInfo:));

    method_exchangeImplementations(originalInitMethod, swizzledInitMethod);
}
