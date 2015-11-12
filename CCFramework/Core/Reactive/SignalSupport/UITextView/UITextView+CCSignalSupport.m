//
//  UITextView+CCSignalSupport.m
//  CCFramework
//
//  Created by CC on 15/11/12.
//  Copyright © 2015年 CC. All rights reserved.
//

#import "UITextView+CCSignalSupport.h"
#import "CCDelegateProxy.h"
#import <objc/runtime.h>

@implementation UITextView (CCSignalSupport)

static void CCUseDelegateProxy(UITextView *self) {
    if (self.delegate == self.cc_delegateProxy) return;
    
    self.cc_delegateProxy.cc_proxiedDelegate = self.delegate;
    self.delegate = (id)self.cc_delegateProxy;
}

- (CCDelegateProxy *)cc_delegateProxy {
    CCDelegateProxy *proxy = objc_getAssociatedObject(self, _cmd);
    if (proxy == nil) {
        proxy = [[CCDelegateProxy alloc] initWithProtocol:@protocol(UITextViewDelegate)];
        objc_setAssociatedObject(self, _cmd, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return proxy;
}

@end
