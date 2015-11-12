//
//  CCDelegateProxy.m
//  CCFramework
//
//  Created by CC on 15/11/12.
//  Copyright © 2015年 CC. All rights reserved.
//

#import "CCDelegateProxy.h"
#import <objc/runtime.h>

@interface CCDelegateProxy ()

@property(nonatomic, strong) Protocol *protocol;

@end

@implementation CCDelegateProxy

- (instancetype)initWithProtocol:(Protocol *)protocol
{
    NSCParameterAssert(protocol != NULL);
    
    if (self = [super init]) {
        class_addProtocol(self.class, protocol);
        
        _protocol = protocol;
    }
    
    return self;
}

#pragma mark API

//- (RACSignal *)signalForSelector:(SEL)selector
//{
//    return [self rac_signalForSelector:selector fromProtocol:_protocol];
//}

#pragma mark NSObject

- (BOOL)isProxy
{
    return YES;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    [invocation invokeWithTarget:self.cc_proxiedDelegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    // Look for the selector as an optional instance method.
    struct objc_method_description methodDescription = protocol_getMethodDescription(_protocol, selector, NO, YES);
    
    if (methodDescription.name == NULL) {
        // Then fall back to looking for a required instance
        // method.
        methodDescription = protocol_getMethodDescription(_protocol, selector, YES, YES);
        if (methodDescription.name == NULL) return [super methodSignatureForSelector:selector];
    }
    
    return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    // Add the delegate to the autorelease pool, so it doesn't get deallocated
    // between this method call and -forwardInvocation:.
    __autoreleasing id delegate = self.cc_proxiedDelegate;
    if ([delegate respondsToSelector:selector]) return YES;
    
    return [super respondsToSelector:selector];
}


@end
