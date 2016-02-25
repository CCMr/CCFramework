//
//  UIScrollView+Expand.m
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
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

#import "UIScrollView+Expand.h"
#import "CCExpandHeader.h"
#import <objc/runtime.h>

static char CCExpandHeaderKey;

@implementation UIScrollView (Expand)

- (void)setExpandHeader:(CCExpandHeader *)header
{
    [self willChangeValueForKey:@"CCExpandHeaderKey"];
    objc_setAssociatedObject(self, &CCExpandHeaderKey, header, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"CCExpandHeaderKey"];
}

- (CCExpandHeader *)expandHeader
{
    return objc_getAssociatedObject(self, &CCExpandHeaderKey);
}

- (void)expandView:(UIView *)expandView
{
    if (!self.expandHeader) {
        CCExpandHeader *header = [[CCExpandHeader alloc] init];
        [header expandWithScrollView:self expandView:expandView];
        self.expandHeader = header;
    }
    [self.expandHeader expandWithScrollView:self expandView:expandView];
}

@end
