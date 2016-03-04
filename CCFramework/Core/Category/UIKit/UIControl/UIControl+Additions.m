//
//  UIControl+Additions.m
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

#import "UIControl+Additions.h"
#import <objc/runtime.h>

static const void *UIControlActionBlockArray = &UIControlActionBlockArray;

@implementation UIControlActionBlockWrapper

- (void)invokeBlock:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}

@end


@implementation UIControl (Additions)

- (void)handleControlEvent:(UIControlEvents)controlEvents withBlock:(UIControlActionBlock)actionBlock
{
    NSMutableArray *actionBlocksArray = [self actionBlocksArray];
    
    UIControlActionBlockWrapper *blockActionWrapper = [[UIControlActionBlockWrapper alloc] init];
    blockActionWrapper.actionBlock = actionBlock;
    blockActionWrapper.controlEvents = controlEvents;
    [actionBlocksArray addObject:blockActionWrapper];
    
    [self addTarget:blockActionWrapper action:@selector(invokeBlock:) forControlEvents:controlEvents];
}


- (void)removeActionBlocksForControlEvent:(UIControlEvents)controlEvents
{
    NSMutableArray *actionBlocksArray = [self actionBlocksArray];
    NSMutableArray *wrappersToRemove = [NSMutableArray arrayWithCapacity:[actionBlocksArray count]];
    
    [actionBlocksArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIControlActionBlockWrapper *wrapperTmp = obj;
        if (wrapperTmp.controlEvents == controlEvents) {
            [wrappersToRemove addObject:wrapperTmp];
            [self removeTarget:wrapperTmp action:@selector(invokeBlock:) forControlEvents:controlEvents];
        }
    }];
    
    [actionBlocksArray removeObjectsInArray:wrappersToRemove];
}


- (NSMutableArray *)actionBlocksArray
{
    NSMutableArray *actionBlocksArray = objc_getAssociatedObject(self, UIControlActionBlockArray);
    if (!actionBlocksArray) {
        actionBlocksArray = [NSMutableArray array];
        objc_setAssociatedObject(self, UIControlActionBlockArray, actionBlocksArray, OBJC_ASSOCIATION_RETAIN);
    }
    return actionBlocksArray;
}

#pragma mark -
#pragma mark :. Block

#define UICONTROL_EVENT(methodName, eventName)                                                                  \
-(void)methodName : (void (^)(void))eventBlock                                                              \
{                                                                                                           \
objc_setAssociatedObject(self, @selector(methodName:), eventBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);    \
[self addTarget:self action:@selector(methodName##Action:) forControlEvents:UIControlEvent##eventName]; \
}                                                                                                           \
-(void)methodName##Action : (id)sender                                                                      \
{                                                                                                           \
void (^block)() = objc_getAssociatedObject(self, @selector(methodName:));                               \
if (block) {                                                                                            \
block();                                                                                            \
}                                                                                                       \
}

UICONTROL_EVENT(touchDown, TouchDown)
UICONTROL_EVENT(touchDownRepeat, TouchDownRepeat)
UICONTROL_EVENT(touchDragInside, TouchDragInside)
UICONTROL_EVENT(touchDragOutside, TouchDragOutside)
UICONTROL_EVENT(touchDragEnter, TouchDragEnter)
UICONTROL_EVENT(touchDragExit, TouchDragExit)
UICONTROL_EVENT(touchUpInside, TouchUpInside)
UICONTROL_EVENT(touchUpOutside, TouchUpOutside)
UICONTROL_EVENT(touchCancel, TouchCancel)
UICONTROL_EVENT(valueChanged, ValueChanged)
UICONTROL_EVENT(editingDidBegin, EditingDidBegin)
UICONTROL_EVENT(editingChanged, EditingChanged)
UICONTROL_EVENT(editingDidEnd, EditingDidEnd)
UICONTROL_EVENT(editingDidEndOnExit, EditingDidEndOnExit)

@end
