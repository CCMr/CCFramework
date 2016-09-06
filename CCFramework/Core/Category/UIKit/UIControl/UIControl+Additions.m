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

@interface UIControl ()

/**
 *  @author CC, 16-09-02
 *
 *  @brief bool 类型 设置是否执行点UI方法
 *         YES 不允许点击
 *         NO 允许点击
 */
@property(nonatomic, assign) BOOL isIgnoreEvent;

@end

@implementation UIControl (Additions)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selA = @selector(sendAction:to:forEvent:);
        SEL selB = @selector(cc_sendAction:to:forEvent:);
        Method methodA =   class_getInstanceMethod(self,selA);
        Method methodB = class_getInstanceMethod(self, selB);
        //将 methodB的实现 添加到系统方法中 也就是说 将 methodA方法指针添加成 方法methodB的  返回值表示是否添加成功
        BOOL isAdd = class_addMethod(self, selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        //添加成功了 说明 本类中不存在methodB 所以此时必须将方法b的实现指针换成方法A的，否则 b方法将没有实现。
        if (isAdd) {
            class_replaceMethod(self, selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }else{
            //添加失败了 说明本类中 有methodB的实现，此时只需要将 methodA和methodB的IMP互换一下即可。
            method_exchangeImplementations(methodA, methodB);
        }
    });
}

- (NSTimeInterval)timeInterval
{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}
- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    objc_setAssociatedObject(self, @selector(timeInterval), @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//当我们按钮点击事件 sendAction 时  将会执行  mySendAction
- (void)cc_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (self.isIgnore) {
        //不需要被hook
        [self cc_sendAction:action to:target forEvent:event];
        return;
    }

    NSString *controlName = NSStringFromClass(self.class);
    if ([controlName isEqualToString:@"UIButton"] || [controlName isEqualToString:@"UINavigationButton"]) {
        self.timeInterval = self.timeInterval == 0 ? defaultInterval : self.timeInterval;
        if (self.isIgnoreEvent) {
            return;
        } else if (self.timeInterval > 0) {
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.timeInterval];
        }
    }
    // 此处 methodA和methodB方法IMP互换了，实际上执行 sendAction；所以不会死循环
    self.isIgnoreEvent = YES;
    [self cc_sendAction:action to:target forEvent:event];
}
//runtime 动态绑定 属性
- (void)setIsIgnoreEvent:(BOOL)isIgnoreEvent
{
    // 注意BOOL类型 需要用OBJC_ASSOCIATION_RETAIN_NONATOMIC 不要用错，否则set方法会赋值出错
    objc_setAssociatedObject(self, @selector(isIgnoreEvent), @(isIgnoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isIgnoreEvent
{
    //_cmd == @select(isIgnore); 和set方法里一致
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setIsIgnore:(BOOL)isIgnore
{
    // 注意BOOL类型 需要用OBJC_ASSOCIATION_RETAIN_NONATOMIC 不要用错，否则set方法会赋值出错
    objc_setAssociatedObject(self, @selector(isIgnore), @(isIgnore), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isIgnore
{
    //_cmd == @select(isIgnore); 和set方法里一致
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)resetState
{
    [self setIsIgnoreEvent:NO];
}

#pragma mark :. 事件委托

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

#define UICONTROL_EVENT(methodName, eventName)                                                            \
-(void)methodName : (void (^)(void))eventBlock                                                           \
{                                                                                                        \
objc_setAssociatedObject(self, @selector(methodName:), eventBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);    \
[self addTarget:self action:@selector(methodName##Action:) forControlEvents:UIControlEvent##eventName]; \
}                                                                                                        \
-(void)methodName##Action : (id)sender                                                                   \
{                                                                                                        \
void (^block)() = objc_getAssociatedObject(self, @selector(methodName:));                               \
if (block) {                                                                                            \
block();                                                                                               \
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
