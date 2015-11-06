//
//  UIControl+BUIControl.m
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

#import "UIControl+BUIControl.h"
#import <objc/runtime.h>

@implementation UIControl (BUIControl)
static char OperationKey;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  删除Block
 *
 *  @param event 事件类型
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */

- (void)removeHandlerForEvent:(UIControlEvents)event
{
    
    NSString *methodName = [UIControl eventName:event];
    NSMutableDictionary *opreations = (NSMutableDictionary *)objc_getAssociatedObject(self, &OperationKey);
    
    if (opreations == nil) {
        opreations = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &OperationKey, opreations, OBJC_ASSOCIATION_RETAIN);
    }
    [opreations removeObjectForKey:methodName];
    [self removeTarget:self action:NSSelectorFromString(methodName) forControlEvents:event];
}

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  Block按钮事件
 *
 *  @param event 事件类型
 *  @param block 委托Block
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (void)handleControlEvent:(UIControlEvents)event withBlock:(void (^)(id sender))block
{
    
    NSString *methodName = [UIControl eventName:event];
    
    NSMutableDictionary *opreations = (NSMutableDictionary *)objc_getAssociatedObject(self, &OperationKey);
    
    if (opreations == nil) {
        opreations = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &OperationKey, opreations, OBJC_ASSOCIATION_RETAIN);
    }
    [opreations setObject:block forKey:methodName];
    
    [self addTarget:self action:NSSelectorFromString(methodName) forControlEvents:event];
}


- (void)UIControlEventTouchDown { [self callActionBlock:UIControlEventTouchDown]; }
- (void)UIControlEventTouchDownRepeat { [self callActionBlock:UIControlEventTouchDownRepeat]; }
- (void)UIControlEventTouchDragInside { [self callActionBlock:UIControlEventTouchDragInside]; }
- (void)UIControlEventTouchDragOutside { [self callActionBlock:UIControlEventTouchDragOutside]; }
- (void)UIControlEventTouchDragEnter { [self callActionBlock:UIControlEventTouchDragEnter]; }
- (void)UIControlEventTouchDragExit { [self callActionBlock:UIControlEventTouchDragExit]; }
- (void)UIControlEventTouchUpInside { [self callActionBlock:UIControlEventTouchUpInside]; }
- (void)UIControlEventTouchUpOutside { [self callActionBlock:UIControlEventTouchUpOutside]; }
- (void)UIControlEventTouchCancel { [self callActionBlock:UIControlEventTouchCancel]; }
- (void)UIControlEventValueChanged { [self callActionBlock:UIControlEventValueChanged]; }
- (void)UIControlEventEditingDidBegin { [self callActionBlock:UIControlEventEditingDidBegin]; }
- (void)UIControlEventEditingChanged { [self callActionBlock:UIControlEventEditingChanged]; }
- (void)UIControlEventEditingDidEnd { [self callActionBlock:UIControlEventEditingDidEnd]; }
- (void)UIControlEventEditingDidEndOnExit { [self callActionBlock:UIControlEventEditingDidEndOnExit]; }
- (void)UIControlEventAllTouchEvents { [self callActionBlock:UIControlEventAllTouchEvents]; }
- (void)UIControlEventAllEditingEvents { [self callActionBlock:UIControlEventAllEditingEvents]; }
- (void)UIControlEventApplicationReserved { [self callActionBlock:UIControlEventApplicationReserved]; }
- (void)UIControlEventSystemReserved { [self callActionBlock:UIControlEventSystemReserved]; }
- (void)UIControlEventAllEvents { [self callActionBlock:UIControlEventAllEvents]; }


- (void)callActionBlock:(UIControlEvents)event
{
    
    NSMutableDictionary *opreations = (NSMutableDictionary *)objc_getAssociatedObject(self, &OperationKey);
    
    if (opreations == nil) return;
    void (^block)(id sender) = [opreations objectForKey:[UIControl eventName:event]];
    
    if (block) block(self);
}

+ (NSString *)eventName:(UIControlEvents)event
{
    switch (event) {
        case UIControlEventTouchDown:
            return @"UIControlEventTouchDown";
        case UIControlEventTouchDownRepeat:
            return @"UIControlEventTouchDownRepeat";
        case UIControlEventTouchDragInside:
            return @"UIControlEventTouchDragInside";
        case UIControlEventTouchDragOutside:
            return @"UIControlEventTouchDragOutside";
        case UIControlEventTouchDragEnter:
            return @"UIControlEventTouchDragEnter";
        case UIControlEventTouchDragExit:
            return @"UIControlEventTouchDragExit";
        case UIControlEventTouchUpInside:
            return @"UIControlEventTouchUpInside";
        case UIControlEventTouchUpOutside:
            return @"UIControlEventTouchUpOutside";
        case UIControlEventTouchCancel:
            return @"UIControlEventTouchCancel";
        case UIControlEventValueChanged:
            return @"UIControlEventValueChanged";
        case UIControlEventEditingDidBegin:
            return @"UIControlEventEditingDidBegin";
        case UIControlEventEditingChanged:
            return @"UIControlEventEditingChanged";
        case UIControlEventEditingDidEnd:
            return @"UIControlEventEditingDidEnd";
        case UIControlEventEditingDidEndOnExit:
            return @"UIControlEventEditingDidEndOnExit";
        case UIControlEventAllTouchEvents:
            return @"UIControlEventAllTouchEvents";
        case UIControlEventAllEditingEvents:
            return @"UIControlEventAllEditingEvents";
        case UIControlEventApplicationReserved:
            return @"UIControlEventApplicationReserved";
        case UIControlEventSystemReserved:
            return @"UIControlEventSystemReserved";
        case UIControlEventAllEvents:
            return @"UIControlEventAllEvents";
        default:
            return @"description";
    }
    return @"description";
}

+ (UIControlEvents)eventWithName:(NSString *)name
{
    if ([name isEqualToString:@"UIControlEventTouchDown"]) return UIControlEventTouchDown;
    if ([name isEqualToString:@"UIControlEventTouchDownRepeat"]) return UIControlEventTouchDownRepeat;
    if ([name isEqualToString:@"UIControlEventTouchDragInside"]) return UIControlEventTouchDragInside;
    if ([name isEqualToString:@"UIControlEventTouchDragOutside"]) return UIControlEventTouchDragOutside;
    if ([name isEqualToString:@"UIControlEventTouchDragEnter"]) return UIControlEventTouchDragEnter;
    if ([name isEqualToString:@"UIControlEventTouchDragExit"]) return UIControlEventTouchDragExit;
    if ([name isEqualToString:@"UIControlEventTouchUpInside"]) return UIControlEventTouchUpInside;
    if ([name isEqualToString:@"UIControlEventTouchUpOutside"]) return UIControlEventTouchUpOutside;
    if ([name isEqualToString:@"UIControlEventTouchCancel"]) return UIControlEventTouchCancel;
    if ([name isEqualToString:@"UIControlEventTouchDown"]) return UIControlEventTouchDown;
    if ([name isEqualToString:@"UIControlEventValueChanged"]) return UIControlEventValueChanged;
    if ([name isEqualToString:@"UIControlEventEditingDidBegin"]) return UIControlEventEditingDidBegin;
    if ([name isEqualToString:@"UIControlEventEditingChanged"]) return UIControlEventEditingChanged;
    if ([name isEqualToString:@"UIControlEventEditingDidEnd"]) return UIControlEventEditingDidEnd;
    if ([name isEqualToString:@"UIControlEventEditingDidEndOnExit"]) return UIControlEventEditingDidEndOnExit;
    if ([name isEqualToString:@"UIControlEventAllTouchEvents"]) return UIControlEventAllTouchEvents;
    if ([name isEqualToString:@"UIControlEventAllEditingEvents"]) return UIControlEventAllEditingEvents;
    if ([name isEqualToString:@"UIControlEventApplicationReserved"]) return UIControlEventApplicationReserved;
    if ([name isEqualToString:@"UIControlEventSystemReserved"]) return UIControlEventSystemReserved;
    if ([name isEqualToString:@"UIControlEventAllEvents"]) return UIControlEventAllEvents;
    return UIControlEventAllEvents;
}

@end
