//
//  UIScrollView+CCInputDodger.m
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

#import "UIScrollView+CCInputDodger.h"
#import <objc/runtime.h>
#import "UIView+CCInputDodger.h"
#import "CCInputDodger.h"

static char kCCOriginalContentInsetKey;

@implementation UIScrollView (CCInputDodger)

- (UIEdgeInsets)originalContentInset
{
    return [objc_getAssociatedObject(self, &kCCOriginalContentInsetKey) UIEdgeInsetsValue];
}

- (void)setOriginalContentInset:(UIEdgeInsets)originalContentInset
{
    static NSString *key = @"originalContentInsetAsDodgeViewForCCInputDodger";
    
    [self willChangeValueForKey:key];
    objc_setAssociatedObject(self, &kCCOriginalContentInsetKey, [NSValue valueWithUIEdgeInsets:originalContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:key];
}

- (void)registerInputDodger
{
    if (![[CCInputDodger dodger] isRegisteredForDodgeView:self]) {
        if (UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, self.originalContentInset))
            self.originalContentInset = self.contentInset;
    }
    [super registerInputDodger];
}

@end
