//
//  UIGestureRecognizer+Additions.m
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

#import "UIGestureRecognizer+Additions.h"
#import <objc/runtime.h>

static const void *UIGestureRecognizerActionBlockArray = &UIGestureRecognizerActionBlockArray;

@implementation UIGestureRecognizerActionBlockWrapper

- (void)invokeBlock:(UIGestureRecognizer *)sender
{
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}

@end

@implementation UIGestureRecognizer (Additions)

- (void)handleGestureRecognizerEvent:(UIGestureRecognizerActionBlock)actionBlock
{
    NSMutableArray *actionBlocksArray = [self actionBlocksArray];
    
    UIGestureRecognizerActionBlockWrapper *blockActionWrapper = [[UIGestureRecognizerActionBlockWrapper alloc] init];
    blockActionWrapper.actionBlock = actionBlock;
    [actionBlocksArray addObject:blockActionWrapper];
    
    [self addTarget:blockActionWrapper action:@selector(invokeBlock:)];
}


- (NSMutableArray *)actionBlocksArray
{
    NSMutableArray *actionBlocksArray = objc_getAssociatedObject(self, UIGestureRecognizerActionBlockArray);
    if (!actionBlocksArray) {
        actionBlocksArray = [NSMutableArray array];
        objc_setAssociatedObject(self, UIGestureRecognizerActionBlockArray, actionBlocksArray, OBJC_ASSOCIATION_RETAIN);
    }
    return actionBlocksArray;
}

@end
