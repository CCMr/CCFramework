//
//  UIView+CCInputDodger.m
//  CCFramework
//
// Copyright (c) 2016 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "UIView+CCInputDodger.h"
#import "CCInputDodger.h"
#import <objc/runtime.h>

static char kCCShiftHeightKey;
static char kCCFrstResponderShiftHeightKey;
static char kCCOriginalY;

/**
 *  swizzle method
 */
void CCInputDodger_Swizzle(Class c, SEL origSEL, SEL newSEL)
{
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = nil;
    if (!origMethod) {
        origMethod = class_getClassMethod(c, origSEL);
        newMethod = class_getClassMethod(c, newSEL);
    } else {
        newMethod = class_getInstanceMethod(c, newSEL);
    }
    
    if (!origMethod || !newMethod)
        return;
    
    if (class_addMethod(c, origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@implementation UIView (CCInputDodger)

- (BOOL)CCInputDodgerHookBecomeFirstResponder
{
    if ([self canBecomeFirstResponder])
        [[CCInputDodger dodger] firstResponderViewChangeTo:self];
    
    return [self CCInputDodgerHookBecomeFirstResponder];
}

+ (void)load
{
    //hook become first responder
    CCInputDodger_Swizzle([self class], @selector(becomeFirstResponder), @selector(CCInputDodgerHookBecomeFirstResponder));
}

- (CGFloat)shiftHeight
{
    return [objc_getAssociatedObject(self, &kCCShiftHeightKey) doubleValue];
}

- (void)setShiftHeight:(CGFloat)shiftHeight
{
    static NSString *key = @"shiftHeight";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &kCCShiftHeightKey, @(shiftHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

- (CGFloat)firstResponderShiftHeight
{
    return [objc_getAssociatedObject(self, &kCCFrstResponderShiftHeightKey) doubleValue];
}

- (void)setFirstResponderShiftHeight:(CGFloat)firstResponderShiftHeight
{
    static NSString *key = @"frstResponderShiftHeight";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &kCCFrstResponderShiftHeightKey, @(firstResponderShiftHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

- (CGFloat)originalY
{
    return [objc_getAssociatedObject(self, &kCCOriginalY) doubleValue];
}

- (void)setOriginalY:(CGFloat)originalY
{
    static NSString *key = @"originalY";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &originalY, @(originalY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

#pragma mark - outcall
- (void)registerInputDodger
{
    if (![[CCInputDodger dodger] isRegisteredForDodgeView:self]) {
        if (self.originalY == 0)
            self.originalY = self.frame.origin.y;
    }
    [[CCInputDodger dodger] registerDodgeView:self];
}

- (void)unregisterInputDodger
{
    [[CCInputDodger dodger] unregisterDodgeView:self];
}


@end
