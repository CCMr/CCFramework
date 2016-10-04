//
//  UIView+Method.m
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

#import "UIView+Method.h"
#import "SDWebImageManager.h"
#import <objc/runtime.h>
#import "CCCacheManager.h"
#import "CCMessageAvatarFactory.h"

@interface GestureCallbackValues : NSObject

@property(nonatomic, copy) void (^tapCallback)(UITapGestureRecognizer *recognizer, NSString *gestureId);
@property(nonatomic, copy) void (^pinchCallback)(UIPinchGestureRecognizer *recognizer, NSString *gestureId);
@property(nonatomic, copy) void (^panCallback)(UIPanGestureRecognizer *recognizer, NSString *gestureId);
@property(nonatomic, copy) void (^swipeCallback)(UISwipeGestureRecognizer *recognizer, NSString *gestureId);
@property(nonatomic, copy) void (^rotationCallback)(UIRotationGestureRecognizer *recognizer, NSString *gestureId);
@property(nonatomic, copy) void (^longPressCallback)(UILongPressGestureRecognizer *recognizer, NSString *gestureId);

@property(nonatomic, retain) UIGestureRecognizer *gesture;
@property(nonatomic, retain) NSString *gestureId;

@end

@implementation GestureCallbackValues
@synthesize tapCallback, pinchCallback, panCallback, swipeCallback, rotationCallback, longPressCallback;
@synthesize gesture, gestureId;
@end

@implementation CCCircleView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)));
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.829 green:0.194 blue:0.257 alpha:1.000].CGColor);
    
    CGContextFillPath(context);
}

@end

static char BUTTONCARRYOBJECTS;

@implementation UIView (Method)

-(CGSize)LayoutSizeFittingSize
{
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);
    
    CGSize viewSize = CGSizeMake(contentViewWidth, 0);

    if (contentViewWidth > 0) {
        if (viewSize.height <= 0) {
            // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
            // of growing horizontally, in a flow-layout manner.
            NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
            [self addConstraint:widthFenceConstraint];
            
            // Auto layout engine does its math
            viewSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            [self removeConstraint:widthFenceConstraint];
        }
    }else{
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (self.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[ViewMethod] Warning once only: Cannot get a proper View Size (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in View, making it into 'self-sizing' view.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
        viewSize = [self sizeThatFits:CGSizeMake(contentViewWidth, 0)];
    }
    
    if (viewSize.height == 0)
        viewSize.height = CGRectGetHeight(self.frame);
    
    return viewSize;
}

- (void)setCarryObjects:(id)carryObjects
{
    objc_setAssociatedObject(self, &BUTTONCARRYOBJECTS, carryObjects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)carryObjects
{
    return objc_getAssociatedObject(self, &BUTTONCARRYOBJECTS);
}

#pragma mark -
#pragma mark :. NIB

+ (UINib *)loadNib
{
    return [self loadNibNamed:NSStringFromClass([self class])];
}
+ (UINib *)loadNibNamed:(NSString *)nibName
{
    return [self loadNibNamed:nibName bundle:[NSBundle mainBundle]];
}
+ (UINib *)loadNibNamed:(NSString *)nibName bundle:(NSBundle *)bundle
{
    return [UINib nibWithNibName:nibName bundle:bundle];
}
+ (instancetype)loadInstanceFromNib
{
    return [self loadInstanceFromNibWithName:NSStringFromClass([self class])];
}
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName
{
    return [self loadInstanceFromNibWithName:nibName owner:nil];
}
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner
{
    return [self loadInstanceFromNibWithName:nibName owner:owner bundle:[NSBundle mainBundle]];
}
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner bundle:(NSBundle *)bundle
{
    UIView *result = nil;
    NSArray *elements = [bundle loadNibNamed:nibName owner:owner options:nil];
    for (id object in elements) {
        if ([object isKindOfClass:[self class]]) {
            result = object;
            break;
        }
    }
    return result;
}

/**
 *  @brief  找到当前view所在的viewcontroler
 */
- (UIViewController *)viewController
{
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder);
    return nil;
}

/**
 *  @author CC, 16-04-25
 *  
 *  @brief 找到当前View所在的NavigationController
 */
-(UINavigationController *)navigationController
{
    return self.viewController.navigationController;
}

#pragma mark -
#pragma mark :. Method

/**
 *  @author CC, 16-03-14
 *  
 *  @brief 找到指定类名的view对象
 *
 *  @param className View名称
 */
-(id)findSubViewWithSubViewNSString:(NSString *)className
{
    return [self findSubViewWithSubViewClass:NSClassFromString(className)];
}

/**
 *  @brief  找到指定类名的view对象
 *
 *  @param clazz view类名
 *
 *  @return view对
 */
- (id)findSubViewWithSubViewClass:(Class)clazz
{
    for (id subView in self.subviews) {
        if ([subView isKindOfClass:clazz])
            return subView;
    }
    
    return nil;
}
/**
 *  @brief  找到指定类名的SuperView对象
 *
 *  @param clazz SuperView类名
 *
 *  @return view对象
 */
- (id)findSuperViewWithSuperViewClass:(Class)clazz
{
    if (self == nil) {
        return nil;
    } else if (self.superview == nil) {
        return nil;
    } else if ([self.superview isKindOfClass:clazz]) {
        return self.superview;
    } else {
        return [self.superview findSuperViewWithSuperViewClass:clazz];
    }
}
/**
 *  @brief  找到并且resign第一响应者
 *
 *  @return 结果
 */
- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    
    for (UIView *v in self.subviews) {
        if ([v findAndResignFirstResponder]) {
            return YES;
        }
    }
    
    return NO;
}
/**
 *  @brief  找到第一响应者
 *
 *  @return 第一响应者
 */
- (UIView *)findFirstResponder
{
    
    if (([self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]]) && (self.isFirstResponder)) {
        return self;
    }
    
    for (UIView *v in self.subviews) {
        UIView *fv = [v findFirstResponder];
        if (fv) {
            return fv;
        }
    }
    
    return nil;
}

/**
 *  @author CC, 16-02-26
 *  
 *  @brief 是否包含视图类型
 *
 *  @param cls 视图类型
 */
- (BOOL)containsSubViewOfClassType:(Class)cls
{
    for (UIView *view in [self subviews]) {
        if ([view isMemberOfClass:cls])
            return YES;
    }
    return NO;
}

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  清空View所子控件
 *
 *  @since 1.0
 */
- (void)removeAllSubviews
{
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}

/**
 *  @author CC, 16-02-26
 *  
 *  @brief 删除某项类型
 *
 *  @param cls 视图类型
 */
- (void)removeSubviewsWithSubviewClass:(Class)cls
{
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:cls])
            [view removeFromSuperview];
    }
}

/**
 *  @author CC, 16-03-23
 *  
 *  @brief 添加一组子View
 *
 *  @param subviews 子View集合
 */
-(void)cc_addSubviews:(NSArray *)subviews
{
    [subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:[UIView class]]) {
            [self addSubview:view];
        }
    }];
}


/**
 *  @brief  寻找子视图
 *
 *  @param recurse 回调
 *
 *  @return  Return YES from the block to recurse into the subview.
 Set stop to YES to return the subview.
 */
- (UIView *)findViewRecursively:(BOOL (^)(UIView *subview, BOOL *stop))recurse
{
    for (UIView *subview in self.subviews) {
        BOOL stop = NO;
        if (recurse(subview, &stop)) {
            return [subview findViewRecursively:recurse];
        } else if (stop) {
            return subview;
        }
    }
    
    return nil;
}


- (void)runBlockOnAllSubviews:(void (^)(UIView *view))block
{
    if (block)
        block(self);
    
    for (UIView *view in [self subviews]) {
        [view runBlockOnAllSubviews:block];
    }
}

- (void)runBlockOnAllSuperviews:(void (^)(UIView *superview))block
{
    if (block)
        block(self);
    
    if (self.superview) {
        [self.superview runBlockOnAllSuperviews:block];
    }
}

- (void)enableAllControlsInViewHierarchy
{
    [self runBlockOnAllSubviews:^(UIView *view) {
        
        if ([view isKindOfClass:[UIControl class]])
        {
            [(UIControl *)view setEnabled:YES];
        }
        else if ([view isKindOfClass:[UITextView class]])
        {
            [(UITextView *)view setEditable:YES];
        }
    }];
}

- (void)disableAllControlsInViewHierarchy
{
    [self runBlockOnAllSubviews:^(UIView *view) {
        
        if ([view isKindOfClass:[UIControl class]])
        {
            [(UIControl *)view setEnabled:NO];
        }
        else if ([view isKindOfClass:[UITextView class]])
        {
            [(UITextView *)view setEditable:NO];
        }
    }];
}

/**
 *  @brief  view截图
 *
 *  @return 截图
 */
- (UIImage *)screenshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshot;
}

/**
 *  @author Jakey
 *
 *  @brief  截图一个view中所有视图 包括旋转缩放效果
 *
 *  @param aView    一个view
 *  @param limitWidth 限制缩放的最大宽度 保持默认传0
 *
 *  @return 截图
 */
- (UIImage *)screenshot:(CGFloat)maxWidth
{
    CGAffineTransform oldTransform = self.transform;
    CGAffineTransform scaleTransform = CGAffineTransformIdentity;
    
    //    if (!isnan(scale)) {
    //        CGAffineTransform transformScale = CGAffineTransformMakeScale(scale, scale);
    //        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
    //    }
    if (!isnan(maxWidth) && maxWidth > 0) {
        CGFloat maxScale = maxWidth / CGRectGetWidth(self.frame);
        CGAffineTransform transformScale = CGAffineTransformMakeScale(maxScale, maxScale);
        scaleTransform = CGAffineTransformConcat(oldTransform, transformScale);
    }
    if (!CGAffineTransformEqualToTransform(scaleTransform, CGAffineTransformIdentity)) {
        self.transform = scaleTransform;
    }
    
    CGRect actureFrame = self.frame;   //已经变换过后的frame
    CGRect actureBounds = self.bounds; //CGRectApplyAffineTransform();
    
    //begin
    UIGraphicsBeginImageContextWithOptions(actureFrame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    CGContextTranslateCTM(context, actureFrame.size.width / 2, actureFrame.size.height / 2);
    CGContextConcatCTM(context, self.transform);
    CGPoint anchorPoint = self.layer.anchorPoint;
    CGContextTranslateCTM(context,
                          -actureBounds.size.width * anchorPoint.x,
                          -actureBounds.size.height * anchorPoint.y);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //end
    self.transform = oldTransform;
    
    return screenshot;
}


#pragma mark -
#pragma mark :. GestureCallback

const NSString *UIView_GestureCallback_gesturesKey = @"UIView_GestureCallback_gesturesKey";
const NSString *UIView_GestureCallback_gestureKeysHashKey = @"UIView_GestureCallback_gestureKeysHashKey";

#pragma mark tap gestures

- (NSString *)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback
{
    NSString *rand;
    do {
        rand = [self randomStringWithLength:12];
    } while ([self.gestures objectForKey:rand] != nil);
    
    [self addTapGestureRecognizer:tapCallback tapGestureId:rand];
    return rand;
}

- (NSString *)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback numberOfTapsRequired:(NSUInteger)numberOfTapsRequired numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
{
    NSString *rand;
    do {
        rand = [self randomStringWithLength:12];
    } while ([self.gestures objectForKey:rand] != nil);
    
    [self addTapGestureRecognizer:tapCallback tapGestureId:rand numberOfTapsRequired:numberOfTapsRequired numberOfTouchesRequired:numberOfTouchesRequired];
    return rand;
}

- (void)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback tapGestureId:(NSString *)tapGestureId
{
    [self addTapGestureRecognizer:tapCallback tapGestureId:tapGestureId numberOfTapsRequired:1 numberOfTouchesRequired:1];
}

- (void)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback tapGestureId:(NSString *)tapGestureId numberOfTapsRequired:(NSUInteger)numberOfTapsRequired numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
{
    UIGestureRecognizer *r = [self.gestures objectForKey:tapGestureId];
    if (r != nil) {
        [self removeTapGesture:tapGestureId];
    }
    
    UITapGestureRecognizer *tg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tg.numberOfTapsRequired = numberOfTapsRequired;
    tg.numberOfTouchesRequired = numberOfTouchesRequired;
    
    GestureCallbackValues *v = [GestureCallbackValues new];
    v.gesture = tg;
    v.tapCallback = tapCallback;
    v.gestureId = tapGestureId;
    
    [self.gestureKeysHash setValue:v forKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
    [self.gestures setValue:v forKey:tapGestureId];
    [self addGestureRecognizer:tg];
}

#pragma mark remove tap gestures

- (void)removeTapGesture:(NSString *)tapGestureId
{
    GestureCallbackValues *v = [self.gestures objectForKey:tapGestureId];
    if (v != nil) {
        [self.gestures removeObjectForKey:tapGestureId];
        [self.gestureKeysHash removeObjectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
        [self removeGestureRecognizer:v.gesture];
    }
}

- (void)removeAllTapGestures
{
    NSArray *arr = self.gestures.allValues;
    for (GestureCallbackValues *v in arr) {
        if ([v.gesture isMemberOfClass:[UITapGestureRecognizer class]]) {
            [self removeTapGesture:v.gestureId];
        }
    }
}

#pragma mark tap handler

- (void)tapHandler:(UITapGestureRecognizer *)recognizer
{
    GestureCallbackValues *v = [self.gestureKeysHash objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)recognizer.hash]];
    
    if (v != nil) {
        if (v.tapCallback != nil) {
            v.tapCallback((UITapGestureRecognizer *)v.gesture, v.gestureId);
        }
    }
}


#pragma mark :. PINCH


#pragma mark add pinch gestures

- (NSString *)addPinchGestureRecognizer:(void (^)(UIPinchGestureRecognizer *recognizer, NSString *gestureId))pinchCallback
{
    NSString *rand;
    do {
        rand = [self randomStringWithLength:12];
    } while ([self.gestures objectForKey:rand] != nil);
    
    [self addPinchGestureRecognizer:pinchCallback pinchGestureId:rand];
    return rand;
}

- (void)addPinchGestureRecognizer:(void (^)(UIPinchGestureRecognizer *recognizer, NSString *gestureId))pinchCallback pinchGestureId:(NSString *)pinchGestureId
{
    UIGestureRecognizer *r = [self.gestures objectForKey:pinchGestureId];
    if (r != nil) {
        [self removePinchGesture:pinchGestureId];
    }
    
    UIPinchGestureRecognizer *tg = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
    
    GestureCallbackValues *v = [GestureCallbackValues new];
    v.gesture = tg;
    v.pinchCallback = pinchCallback;
    v.gestureId = pinchGestureId;
    
    [self.gestureKeysHash setValue:v forKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
    [self.gestures setValue:v forKey:pinchGestureId];
    [self addGestureRecognizer:tg];
}


#pragma mark remove pinch gestures

- (void)removePinchGesture:(NSString *)pinchGestureId
{
    GestureCallbackValues *v = [self.gestures objectForKey:pinchGestureId];
    if (v != nil) {
        [self.gestures removeObjectForKey:pinchGestureId];
        [self.gestureKeysHash removeObjectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
        [self removeGestureRecognizer:v.gesture];
    }
}

- (void)removeAllPinchGestures
{
    NSArray *arr = self.gestures.allValues;
    for (GestureCallbackValues *v in arr) {
        if ([v.gesture isMemberOfClass:[UIPinchGestureRecognizer class]]) {
            [self removePinchGesture:v.gestureId];
        }
    }
}

#pragma mark pinch handler

- (void)pinchHandler:(UIPinchGestureRecognizer *)recognizer
{
    GestureCallbackValues *v = [self.gestureKeysHash objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)recognizer.hash]];
    
    if (v != nil) {
        if (v.pinchCallback != nil) {
            v.pinchCallback((UIPinchGestureRecognizer *)v.gesture, v.gestureId);
        }
    }
}


#pragma mark :. PAN


#pragma mark add pan gestures

- (NSString *)addPanGestureRecognizer:(void (^)(UIPanGestureRecognizer *recognizer, NSString *gestureId))panCallback
{
    return [self addPanGestureRecognizer:panCallback minimumNumberOfTouches:1 maximumNumberOfTouches:NSUIntegerMax];
}
- (NSString *)addPanGestureRecognizer:(void (^)(UIPanGestureRecognizer *recognizer, NSString *gestureId))panCallback minimumNumberOfTouches:(NSUInteger)minimumNumberOfTouches maximumNumberOfTouches:(NSUInteger)maximumNumberOfTouches
{
    NSString *rand;
    do {
        rand = [self randomStringWithLength:12];
    } while ([self.gestures objectForKey:rand] != nil);
    
    [self addPanGestureRecognizer:panCallback panGestureId:rand minimumNumberOfTouches:minimumNumberOfTouches maximumNumberOfTouches:maximumNumberOfTouches];
    return rand;
}

- (void)addPanGestureRecognizer:(void (^)(UIPanGestureRecognizer *recognizer, NSString *gestureId))panCallback panGestureId:(NSString *)panGestureId minimumNumberOfTouches:(NSUInteger)minimumNumberOfTouches maximumNumberOfTouches:(NSUInteger)maximumNumberOfTouches
{
    UIGestureRecognizer *r = [self.gestures objectForKey:panGestureId];
    if (r != nil) {
        [self removePanGesture:panGestureId];
    }
    
    UIPanGestureRecognizer *tg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    tg.minimumNumberOfTouches = minimumNumberOfTouches;
    tg.maximumNumberOfTouches = maximumNumberOfTouches;
    
    GestureCallbackValues *v = [GestureCallbackValues new];
    v.gesture = tg;
    v.panCallback = panCallback;
    v.gestureId = panGestureId;
    
    [self.gestureKeysHash setValue:v forKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
    [self.gestures setValue:v forKey:panGestureId];
    [self addGestureRecognizer:tg];
}


#pragma mark remove pan gestures

- (void)removePanGesture:(NSString *)panGestureId
{
    GestureCallbackValues *v = [self.gestures objectForKey:panGestureId];
    if (v != nil) {
        [self.gestures removeObjectForKey:panGestureId];
        [self.gestureKeysHash removeObjectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
        [self removeGestureRecognizer:v.gesture];
    }
}

- (void)removeAllPanGestures
{
    NSArray *arr = self.gestures.allValues;
    for (GestureCallbackValues *v in arr) {
        if ([v.gesture isMemberOfClass:[UIPanGestureRecognizer class]]) {
            [self removePanGesture:v.gestureId];
        }
    }
}

#pragma mark pan handler

- (void)panHandler:(UIPanGestureRecognizer *)recognizer
{
    GestureCallbackValues *v = [self.gestureKeysHash objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)recognizer.hash]];
    
    if (v != nil) {
        if (v.panCallback != nil) {
            v.panCallback((UIPanGestureRecognizer *)v.gesture, v.gestureId);
        }
    }
}


#pragma mark :. SWIPE

- (NSString *)addSwipeGestureRecognizer:(void (^)(UISwipeGestureRecognizer *recognizer, NSString *gestureId))swipeCallback direction:(UISwipeGestureRecognizerDirection)direction
{
    return [self addSwipeGestureRecognizer:swipeCallback direction:direction numberOfTouchesRequired:1];
}

- (NSString *)addSwipeGestureRecognizer:(void (^)(UISwipeGestureRecognizer *recognizer, NSString *gestureId))swipeCallback direction:(UISwipeGestureRecognizerDirection)direction numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
{
    NSString *rand;
    do {
        rand = [self randomStringWithLength:12];
    } while ([self.gestures objectForKey:rand] != nil);
    
    [self addSwipeGestureRecognizer:swipeCallback swipeGestureId:rand direction:direction numberOfTouchesRequired:numberOfTouchesRequired];
    return rand;
}

- (void)addSwipeGestureRecognizer:(void (^)(UISwipeGestureRecognizer *recognizer, NSString *gestureId))swipeCallback swipeGestureId:(NSString *)swipeGestureId direction:(UISwipeGestureRecognizerDirection)direction numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
{
    UIGestureRecognizer *r = [self.gestures objectForKey:swipeGestureId];
    if (r != nil) {
        [self removeSwipeGesture:swipeGestureId];
    }
    
    UISwipeGestureRecognizer *tg = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    tg.direction = direction;
    tg.numberOfTouchesRequired = numberOfTouchesRequired;
    
    GestureCallbackValues *v = [GestureCallbackValues new];
    v.gesture = tg;
    v.swipeCallback = swipeCallback;
    v.gestureId = swipeGestureId;
    
    [self.gestureKeysHash setValue:v forKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
    [self.gestures setValue:v forKey:swipeGestureId];
    [self addGestureRecognizer:tg];
}


#pragma mark remove swipe gestures

- (void)removeSwipeGesture:(NSString *)swipeGestureId
{
    GestureCallbackValues *v = [self.gestures objectForKey:swipeGestureId];
    if (v != nil) {
        [self.gestures removeObjectForKey:swipeGestureId];
        [self.gestureKeysHash removeObjectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
        [self removeGestureRecognizer:v.gesture];
    }
}

- (void)removeAllSwipeGestures
{
    NSArray *arr = self.gestures.allValues;
    for (GestureCallbackValues *v in arr) {
        if ([v.gesture isMemberOfClass:[UISwipeGestureRecognizer class]]) {
            [self removeSwipeGesture:v.gestureId];
        }
    }
}

#pragma mark swipe handler

- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer
{
    GestureCallbackValues *v = [self.gestureKeysHash objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)recognizer.hash]];
    
    if (v != nil) {
        if (v.swipeCallback != nil) {
            v.swipeCallback((UISwipeGestureRecognizer *)v.gesture, v.gestureId);
        }
    }
}


#pragma mark :. ROTATION

#pragma mark add rotation gestures

- (NSString *)addRotationGestureRecognizer:(void (^)(UIRotationGestureRecognizer *recognizer, NSString *gestureId))rotationCallback
{
    NSString *rand;
    do {
        rand = [self randomStringWithLength:12];
    } while ([self.gestures objectForKey:rand] != nil);
    
    [self addRotationGestureRecognizer:rotationCallback rotationGestureId:rand];
    return rand;
}

- (void)addRotationGestureRecognizer:(void (^)(UIRotationGestureRecognizer *recognizer, NSString *gestureId))rotationCallback rotationGestureId:(NSString *)rotationGestureId
{
    UIGestureRecognizer *r = [self.gestures objectForKey:rotationGestureId];
    if (r != nil) {
        [self removeRotationGesture:rotationGestureId];
    }
    
    UIRotationGestureRecognizer *tg = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationHandler:)];
    
    GestureCallbackValues *v = [GestureCallbackValues new];
    v.gesture = tg;
    v.rotationCallback = rotationCallback;
    v.gestureId = rotationGestureId;
    
    [self.gestureKeysHash setValue:v forKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
    [self.gestures setValue:v forKey:rotationGestureId];
    [self addGestureRecognizer:tg];
}


#pragma mark remove rotation gestures

- (void)removeRotationGesture:(NSString *)rotationGestureId
{
    GestureCallbackValues *v = [self.gestures objectForKey:rotationGestureId];
    if (v != nil) {
        [self.gestures removeObjectForKey:rotationGestureId];
        [self.gestureKeysHash removeObjectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
        [self removeGestureRecognizer:v.gesture];
    }
}

- (void)removeAllRotationGestures
{
    NSArray *arr = self.gestures.allValues;
    for (GestureCallbackValues *v in arr) {
        if ([v.gesture isMemberOfClass:[UIRotationGestureRecognizer class]]) {
            [self removeRotationGesture:v.gestureId];
        }
    }
}

#pragma mark rotation handler

- (void)rotationHandler:(UIRotationGestureRecognizer *)recognizer
{
    GestureCallbackValues *v = [self.gestureKeysHash objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)recognizer.hash]];
    
    if (v != nil) {
        if (v.rotationCallback != nil) {
            v.rotationCallback((UIRotationGestureRecognizer *)v.gesture, v.gestureId);
        }
    }
}


#pragma mark :. LONG PRESS

#pragma mark add longPress gestures

- (NSString *)addLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *recognizer, NSString *gestureId))longPressCallback
{
    return [self addLongPressGestureRecognizer:longPressCallback numberOfTapsRequired:0 numberOfTouchesRequired:1 minimumPressDuration:0.5 allowableMovement:10];
}

- (NSString *)addLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *recognizer, NSString *gestureId))longPressCallback
                       numberOfTapsRequired:(NSUInteger)numberOfTapsRequired
                    numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
                       minimumPressDuration:(CFTimeInterval)minimumPressDuration
                          allowableMovement:(CGFloat)allowableMovement
{
    NSString *rand;
    do {
        rand = [self randomStringWithLength:12];
    } while ([self.gestures objectForKey:rand] != nil);
    
    [self addLongPressGestureRecognizer:longPressCallback longPressGestureId:rand numberOfTapsRequired:numberOfTapsRequired numberOfTouchesRequired:numberOfTouchesRequired minimumPressDuration:minimumPressDuration allowableMovement:allowableMovement];
    return rand;
}

- (void)addLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *recognizer, NSString *gestureId))longPressCallback
                   longPressGestureId:(NSString *)longPressGestureId
                 numberOfTapsRequired:(NSUInteger)numberOfTapsRequired
              numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
                 minimumPressDuration:(CFTimeInterval)minimumPressDuration
                    allowableMovement:(CGFloat)allowableMovement
{
    UIGestureRecognizer *r = [self.gestures objectForKey:longPressGestureId];
    if (r != nil) {
        [self removeLongPressGesture:longPressGestureId];
    }
    
    UILongPressGestureRecognizer *tg = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    tg.numberOfTapsRequired = numberOfTapsRequired;
    tg.numberOfTouchesRequired = numberOfTouchesRequired;
    tg.minimumPressDuration = minimumPressDuration;
    tg.allowableMovement = allowableMovement;
    
    GestureCallbackValues *v = [GestureCallbackValues new];
    v.gesture = tg;
    v.longPressCallback = longPressCallback;
    v.gestureId = longPressGestureId;
    
    [self.gestureKeysHash setValue:v forKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
    [self.gestures setValue:v forKey:longPressGestureId];
    [self addGestureRecognizer:tg];
}


#pragma mark remove longPress gestures

- (void)removeLongPressGesture:(NSString *)longPressGestureId
{
    GestureCallbackValues *v = [self.gestures objectForKey:longPressGestureId];
    if (v != nil) {
        [self.gestures removeObjectForKey:longPressGestureId];
        [self.gestureKeysHash removeObjectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)v.gesture.hash]];
        [self removeGestureRecognizer:v.gesture];
    }
}

- (void)removeAllLongPressGestures
{
    NSArray *arr = self.gestures.allValues;
    for (GestureCallbackValues *v in arr) {
        if ([v.gesture isMemberOfClass:[UILongPressGestureRecognizer class]]) {
            [self removeLongPressGesture:v.gestureId];
        }
    }
}

#pragma mark longPress handler

- (void)longPressHandler:(UILongPressGestureRecognizer *)recognizer
{
    GestureCallbackValues *v = [self.gestureKeysHash objectForKey:[NSString stringWithFormat:@"%lu", (unsigned long)recognizer.hash]];
    
    if (v != nil) {
        if (v.longPressCallback != nil) {
            v.longPressCallback((UILongPressGestureRecognizer *)v.gesture, v.gestureId);
        }
    }
}


#pragma mark random string


- (NSString *)randomStringWithLength:(int)len
{
    const NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    
    for (int i = 0; i < len; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform((u_int32_t)[letters length])]];
    }
    
    return randomString;
}


#pragma mark :. getter/setters

- (NSMutableDictionary *)gestures
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &UIView_GestureCallback_gesturesKey);
    
    if (dict == nil) {
        dict = [NSMutableDictionary new];
        self.gestures = dict;
    }
    
    return dict;
}
- (void)setGestures:(NSMutableDictionary *)value
{
    objc_setAssociatedObject(self, &UIView_GestureCallback_gesturesKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)gestureKeysHash
{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, &UIView_GestureCallback_gestureKeysHashKey);
    
    if (dict == nil) {
        dict = [NSMutableDictionary new];
        self.gestureKeysHash = dict;
    }
    
    return dict;
}
- (void)setGestureKeysHash:(NSMutableDictionary *)value
{
    objc_setAssociatedObject(self, &UIView_GestureCallback_gestureKeysHashKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
#pragma mark :. Toast

/*
 *  CONFIGURE THESE VALUES TO ADJUST LOOK & FEEL,
 *  DISPLAY DURATION, ETC.
 */

// general appearance
static const CGFloat CSToastMaxWidth = 0.8;  // 80% of parent view width
static const CGFloat CSToastMaxHeight = 0.8; // 80% of parent view height
static const CGFloat CSToastHorizontalPadding = 10.0;
static const CGFloat CSToastVerticalPadding = 10.0;
static const CGFloat CSToastCornerRadius = 10.0;
static const CGFloat CSToastOpacity = 0.8;
static const CGFloat CSToastFontSize = 16.0;
static const CGFloat CSToastMaxTitleLines = 0;
static const CGFloat CSToastMaxMessageLines = 0;
static const NSTimeInterval CSToastFadeDuration = 0.2;

// shadow appearance
static const CGFloat CSToastShadowOpacity = 0.8;
static const CGFloat CSToastShadowRadius = 6.0;
static const CGSize CSToastShadowOffset = {4.0, 4.0};
static const BOOL CSToastDisplayShadow = YES;

// display duration
static const NSTimeInterval CSToastDefaultDuration = 3.0;

// image view size
static const CGFloat CSToastImageViewWidth = 80.0;
static const CGFloat CSToastImageViewHeight = 80.0;

// activity
static const CGFloat CSToastActivityWidth = 100.0;
static const CGFloat CSToastActivityHeight = 100.0;
static const NSString *CSToastActivityDefaultPosition = @"center";

// interaction
static const BOOL CSToastHidesOnTap = YES; // excludes activity views

// associative reference keys
static const NSString *CSToastTimerKey = @"CSToastTimerKey";
static const NSString *CSToastActivityViewKey = @"CSToastActivityViewKey";
static const NSString *CSToastTapCallbackKey = @"CSToastTapCallbackKey";

// positions
NSString *const CSToastPositionTop = @"top";
NSString *const CSToastPositionCenter = @"center";
NSString *const CSToastPositionBottom = @"bottom";


#pragma mark :. Toast Methods

- (void)makeToast:(NSString *)message
{
    [self makeToast:message
           duration:CSToastDefaultDuration
           position:nil];
}

- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
{
    UIView *toast = [self viewForMessage:message title:nil image:nil];
    [self showToast:toast
           duration:duration
           position:position];
}

- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
            title:(NSString *)title
{
    UIView *toast = [self viewForMessage:message title:title image:nil];
    [self showToast:toast
           duration:duration
           position:position];
}

- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
            image:(UIImage *)image
{
    UIView *toast = [self viewForMessage:message title:nil image:image];
    [self showToast:toast
           duration:duration
           position:position];
}

- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)duration
         position:(id)position
            title:(NSString *)title
            image:(UIImage *)image
{
    UIView *toast = [self viewForMessage:message title:title image:image];
    [self showToast:toast
           duration:duration
           position:position];
}

- (void)showToast:(UIView *)toast
{
    [self showToast:toast
           duration:CSToastDefaultDuration
           position:nil];
}


- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position
{
    [self showToast:toast
           duration:duration
           position:position
        tapCallback:nil];
}


- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)duration
         position:(id)position
      tapCallback:(void (^)(void))tapCallback
{
    toast.center = [self centerPointForPosition:position withToast:toast];
    toast.alpha = 0.0;
    
    if (CSToastHidesOnTap) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(handleToastTapped:)];
        [toast addGestureRecognizer:recognizer];
        toast.userInteractionEnabled = YES;
        toast.exclusiveTouch = YES;
    }
    
    [self addSubview:toast];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         toast.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(toastTimerDidFinish:) userInfo:toast repeats:NO];
                         // associate the timer with the toast view
                         objc_setAssociatedObject (toast, &CSToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         objc_setAssociatedObject (toast, &CSToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                     }];
}


- (void)hideToast:(UIView *)toast
{
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         toast.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [toast removeFromSuperview];
                     }];
}

#pragma mark :. Events

- (void)toastTimerDidFinish:(NSTimer *)timer
{
    [self hideToast:(UIView *)timer.userInfo];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer
{
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &CSToastTimerKey);
    [timer invalidate];
    
    void (^callback)(void) = objc_getAssociatedObject(self, &CSToastTapCallbackKey);
    if (callback) {
        callback();
    }
    [self hideToast:recognizer.view];
}

#pragma mark :. Toast Activity Methods

- (void)makeToastActivity
{
    [self makeToastActivity:CSToastActivityDefaultPosition];
}

- (void)makeToastActivity:(id)position
{
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) return;
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth, CSToastActivityHeight)];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = CSToastCornerRadius;
    
    if (CSToastDisplayShadow) {
        activityView.layer.shadowColor = [UIColor blackColor].CGColor;
        activityView.layer.shadowOpacity = CSToastShadowOpacity;
        activityView.layer.shadowRadius = CSToastShadowRadius;
        activityView.layer.shadowOffset = CSToastShadowOffset;
    }
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // associate the activity view with self
    objc_setAssociatedObject(self, &CSToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)hideToastActivity
{
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:CSToastFadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

#pragma mark :. Helpers

- (CGPoint)centerPointForPosition:(id)point withToast:(UIView *)toast
{
    if ([point isKindOfClass:[NSString class]]) {
        if ([point caseInsensitiveCompare:CSToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, (toast.frame.size.height / 2) + CSToastVerticalPadding);
        } else if ([point caseInsensitiveCompare:CSToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    // default to bottom
    return CGPointMake(self.bounds.size.width / 2, (self.bounds.size.height - (toast.frame.size.height / 2)) - CSToastVerticalPadding);
}

- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName : font, NSParagraphStyleAttributeName : paragraphStyle};
        CGRect boundingRect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [string sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
}

- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image
{
    // sanity
    if ((message == nil) && (title == nil) && (image == nil)) return nil;
    
    // dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = CSToastCornerRadius;
    
    if (CSToastDisplayShadow) {
        wrapperView.layer.shadowColor = [UIColor blackColor].CGColor;
        wrapperView.layer.shadowOpacity = CSToastShadowOpacity;
        wrapperView.layer.shadowRadius = CSToastShadowRadius;
        wrapperView.layer.shadowOffset = CSToastShadowOffset;
    }
    
    wrapperView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity];
    
    if (image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(CSToastHorizontalPadding, CSToastVerticalPadding, CSToastImageViewWidth, CSToastImageViewHeight);
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if (imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = CSToastHorizontalPadding;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = CSToastMaxTitleLines;
        titleLabel.font = [UIFont boldSystemFontOfSize:CSToastFontSize];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeTitle = [self sizeForString:title font:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = CSToastMaxMessageLines;
        messageLabel.font = [UIFont systemFontOfSize:CSToastFontSize];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * CSToastMaxWidth) - imageWidth, self.bounds.size.height * CSToastMaxHeight);
        CGSize expectedSizeMessage = [self sizeForString:message font:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if (titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = CSToastVerticalPadding;
        titleLeft = imageLeft + imageWidth + CSToastHorizontalPadding;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;
    
    if (messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + CSToastHorizontalPadding;
        messageTop = titleTop + titleHeight + CSToastVerticalPadding;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    
    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (CSToastHorizontalPadding * 2)), (longerLeft + longerWidth + CSToastHorizontalPadding));
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + CSToastVerticalPadding), (imageHeight + (CSToastVerticalPadding * 2)));
    
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
    
    if (titleLabel != nil) {
        titleLabel.frame = CGRectMake(titleLeft, titleTop, titleWidth, titleHeight);
        [wrapperView addSubview:titleLabel];
    }
    
    if (messageLabel != nil) {
        messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
        [wrapperView addSubview:messageLabel];
    }
    
    if (imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    return wrapperView;
}

#pragma mark -
#pragma mark :. CustomBorder

typedef NS_ENUM(NSInteger, EdgeType) {
    TopBorder = 10000,
    LeftBorder = 20000,
    BottomBorder = 30000,
    RightBorder = 40000
};


- (void)removeTopBorder
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        if (subView.tag == TopBorder) {
            [subView removeFromSuperview];
        }
    }];
}

- (void)removeLeftBorder
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        if (subView.tag == LeftBorder) {
            [subView removeFromSuperview];
        }
    }];
}

- (void)removeBottomBorder
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        if (subView.tag == BottomBorder) {
            [subView removeFromSuperview];
        }
    }];
}

- (void)removeRightBorder
{
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subView, NSUInteger idx, BOOL *stop) {
        if (subView.tag == RightBorder) {
            [subView removeFromSuperview];
        }
    }];
}

- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth
{
    [self addTopBorderWithColor:color width:borderWidth excludePoint:0 edgeType:0];
}


- (void)addLeftBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth
{
    [self addLeftBorderWithColor:color width:borderWidth excludePoint:0 edgeType:0];
}


- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth
{
    [self addBottomBorderWithColor:color width:borderWidth excludePoint:0 edgeType:0];
}


- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth
{
    [self addRightBorderWithColor:color width:borderWidth excludePoint:0 edgeType:0];
}


- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge
{
    [self removeTopBorder];
    
    UIView *border = [[UIView alloc] init];
    if (!self.translatesAutoresizingMaskIntoConstraints) {
        border.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    border.userInteractionEnabled = NO;
    border.backgroundColor = color;
    border.tag = TopBorder;
    
    [self addSubview:border];
    
    CGFloat startPoint = 0.0f;
    CGFloat endPoint = 0.0f;
    if (edge & ExcludeStartPoint) {
        startPoint += point;
    }
    
    if (edge & ExcludeEndPoint) {
        endPoint += point;
    }
    
    if (border.translatesAutoresizingMaskIntoConstraints) {
        CGFloat borderLenght = self.bounds.size.width - endPoint - startPoint;
        border.frame = CGRectMake(startPoint, 0.0, borderLenght, borderWidth);
        return;
    }
    
    // AutoLayout
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:startPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-endPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:borderWidth]];
}


- (void)addLeftBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge
{
    [self removeLeftBorder];
    
    UIView *border = [[UIView alloc] init];
    if (!self.translatesAutoresizingMaskIntoConstraints) {
        border.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    border.userInteractionEnabled = NO;
    border.backgroundColor = color;
    border.tag = LeftBorder;
    [self addSubview:border];
    
    CGFloat startPoint = 0.0f;
    CGFloat endPoint = 0.0f;
    if (edge & ExcludeStartPoint) {
        startPoint += point;
    }
    
    if (edge & ExcludeEndPoint) {
        endPoint += point;
    }
    
    if (border.translatesAutoresizingMaskIntoConstraints) {
        CGFloat borderLength = self.bounds.size.height - startPoint - endPoint;
        border.frame = CGRectMake(0.0, startPoint, borderWidth, borderLength);
        return;
    }
    
    // AutoLayout
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:startPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-endPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:borderWidth]];
}


- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge
{
    [self removeBottomBorder];
    
    UIView *border = [[UIView alloc] init];
    if (!self.translatesAutoresizingMaskIntoConstraints) {
        border.translatesAutoresizingMaskIntoConstraints = NO;
    }
    border.userInteractionEnabled = NO;
    border.backgroundColor = color;
    border.tag = BottomBorder;
    [self addSubview:border];
    
    CGFloat startPoint = 0.0f;
    CGFloat endPoint = 0.0f;
    if (edge & ExcludeStartPoint) {
        startPoint += point;
    }
    
    if (edge & ExcludeEndPoint) {
        endPoint += point;
    }
    
    
    if (border.translatesAutoresizingMaskIntoConstraints) {
        CGFloat borderLength = self.bounds.size.width - startPoint - endPoint;
        border.frame = CGRectMake(startPoint, self.bounds.size.height - borderWidth, borderLength, borderWidth);
        return;
    }
    
    // AutoLayout
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:startPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-endPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:borderWidth]];
}

- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge
{
    [self removeRightBorder];
    
    UIView *border = [[UIView alloc] init];
    if (!self.translatesAutoresizingMaskIntoConstraints) {
        border.translatesAutoresizingMaskIntoConstraints = NO;
    }
    border.userInteractionEnabled = NO;
    border.backgroundColor = color;
    border.tag = RightBorder;
    [self addSubview:border];
    
    CGFloat startPoint = 0.0f;
    CGFloat endPoint = 0.0f;
    if (edge & ExcludeStartPoint) {
        startPoint += point;
    }
    
    if (edge & ExcludeEndPoint) {
        endPoint += point;
    }
    
    if (border.translatesAutoresizingMaskIntoConstraints) {
        CGFloat borderLength = self.bounds.size.height - startPoint - endPoint;
        border.frame = CGRectMake(self.bounds.size.width - borderWidth, startPoint, borderWidth, borderLength);
        return;
    }
    
    // AutoLayout
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:startPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-endPoint]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:border attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:borderWidth]];
}

#pragma mark -
#pragma mark :. WebCacheOperation

static char loadOperationKey;

- (NSMutableDictionary *)operationDictionary
{
    NSMutableDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)cc_setImageLoadOperation:(id)operation forKey:(NSString *)key
{
    [self cc_cancelImageLoadOperationWithKey:key];
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary setObject:operation forKey:key];
}

- (void)cc_cancelImageLoadOperationWithKey:(NSString *)key
{
    // Cancel in progress downloader from queue
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    id operations = [operationDictionary objectForKey:key];
    if (operations) {
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id<SDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(SDWebImageOperation)]) {
            [(id<SDWebImageOperation>) operations cancel];
        }
        [operationDictionary removeObjectForKey:key];
    }
}

- (void)cc_removeImageLoadOperationWithKey:(NSString *)key {
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary removeObjectForKey:key];
}


#pragma mark -
#pragma mark :. CCRemoteImage

const char* const kCCURLPropertyKey   = "CCURLDownloadURLPropertyKey";
const char* const kCCLoadingStateKey  = "CCURLDownloadLoadingStateKey";
const char* const kCCLoadingViewKey   = "CCURLDownloadLoadingViewKey";

const char* const kCCActivityIndicatorViewKey   = "CCActivityIndicatorViewKey";

const char* const kCCMessageAvatarTypeKey   = "CCMessageAvatarTypeKey";

#define kCCActivityIndicatorViewSize 35

+ (id)imageViewWithURL:(NSURL *)url autoLoading:(BOOL)autoLoading {
    UIImageView *view = [self new];
    view.url = url;
    if(autoLoading) {
        [view load];
    }
    return view;
}

+ (id)indicatorImageView {
    UIImageView *view = [self new];
    [view setDefaultLoadingView];
    
    return view;
}

+ (id)indicatorImageViewWithURL:(NSURL *)url autoLoading:(BOOL)autoLoading {
    UIImageView *view = [self imageViewWithURL:url autoLoading:autoLoading];
    [view setDefaultLoadingView];
    
    return view;
}

#pragma mark :. Properties

- (dispatch_queue_t)cachingQueue {
    static dispatch_queue_t cachingQeueu;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachingQeueu = dispatch_queue_create("caching image and data", NULL);
    });
    return cachingQeueu;
}

- (void)setActivityIndicatorView:(UIActivityIndicatorView *)activityIndicatorView {
    objc_setAssociatedObject(self, kCCActivityIndicatorViewKey, activityIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)activityIndicatorView {
    return objc_getAssociatedObject(self, kCCActivityIndicatorViewKey);
}

- (void)setMessageAvatarType:(CCMessageAvatarType)messageAvatarType {
    objc_setAssociatedObject(self, &kCCMessageAvatarTypeKey, [NSNumber numberWithInteger:messageAvatarType], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CCMessageAvatarType)messageAvatarType {
    return (CCMessageAvatarType)([objc_getAssociatedObject(self, &kCCMessageAvatarTypeKey) integerValue]);
}

- (NSURL*)url {
    return objc_getAssociatedObject(self, kCCURLPropertyKey);
}

- (void)setUrl:(NSURL *)url {
    [self setImageUrl:url autoLoading:NO];
}

- (void)setImageUrl:(NSURL *)url autoLoading:(BOOL)autoLoading {
    if(![url isEqual:self.url]) {
        objc_setAssociatedObject(self, kCCURLPropertyKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (url) {
            self.loadingState = UIImageViewURLDownloadStateWaitingForLoad;
        }
        else {
            self.loadingState = UIImageViewURLDownloadStateUnknown;
        }
    }
    
    if(autoLoading) {
        [self load];
    }
}

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholer:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholer:(UIImage *)placeholerImage {
    [self setImageWithURL:url placeholer:placeholerImage showActivityIndicatorView:NO];
}

- (void)setImageWithURL:(NSURL *)url placeholer:(UIImage *)placeholerImage showActivityIndicatorView:(BOOL)show {
    [self _setupPlaecholerImage:placeholerImage showActivityIndicatorView:show];
    [self setImageUrl:url autoLoading:YES];
}

- (void)setImageWithURL:(NSURL *)url placeholer:(UIImage *)placeholerImage showActivityIndicatorView:(BOOL)show completionBlock:(void(^)(UIImage *image, NSURL *url, NSError *error))handler {
    [self _setupPlaecholerImage:placeholerImage showActivityIndicatorView:show];
    [self setImageUrl:url autoLoading:NO];
    [self loadWithCompletionBlock:handler];
}

- (void)_setupPlaecholerImage:(UIImage *)placeholerImage showActivityIndicatorView:(BOOL)show {
    if (placeholerImage) {
        [self setupImage:placeholerImage];
    }
    if (show) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.frame = CGRectMake(0, 0, kCCActivityIndicatorViewSize, kCCActivityIndicatorViewSize);
        activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [activityIndicatorView startAnimating];
        [self addSubview:activityIndicatorView];
        [self setActivityIndicatorView:activityIndicatorView];
    }
}

- (UIImageViewURLDownloadState)loadingState {
    return (NSUInteger)([objc_getAssociatedObject(self, kCCLoadingStateKey) integerValue]);
}

- (void)setLoadingState:(UIImageViewURLDownloadState)loadingState {
    objc_setAssociatedObject(self, kCCLoadingStateKey, @(loadingState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)loadingView {
    return objc_getAssociatedObject(self, kCCLoadingViewKey);
}

- (void)setLoadingView:(UIView *)loadingView {
    [self.loadingView removeFromSuperview];
    
    objc_setAssociatedObject(self, kCCLoadingViewKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    loadingView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    loadingView.alpha  = 0;
    [self addSubview:loadingView];
}

- (void)setDefaultLoadingView {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = self.frame;
    indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    indicator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.loadingView = indicator;
}

#pragma mark :. Setup Image

- (void)setupImage:(UIImage *)image {
    if (!image) {
        return;
    }
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *currentButton = (UIButton *)self;
        [currentButton setImage:image forState:UIControlStateNormal];
    } else if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *currentImageView = (UIImageView *)self;
        currentImageView.image = image;
    }
}

#pragma mark :. Loading view

- (void)showLoadingView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingView.alpha = 1;
        if([self.loadingView respondsToSelector:@selector(startAnimating)]) {
            [self.loadingView performSelector:@selector(startAnimating)];
        }
    });
}

- (void)hideLoadingView {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *activityIndicatorView = [self activityIndicatorView];
        if (activityIndicatorView) {
            [activityIndicatorView stopAnimating];
            [activityIndicatorView removeFromSuperview];
        }
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.loadingView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if([self.loadingView respondsToSelector:@selector(stopAnimating)]) {
                                 [self.loadingView performSelector:@selector(stopAnimating)];
                             }
                         }
         ];
    });
}

#pragma mark :. Image downloading

+ (NSOperationQueue *)downloadQueue {
    static NSOperationQueue *_sharedQueue = nil;
    
    if(_sharedQueue == nil) {
        _sharedQueue = [NSOperationQueue new];
        [_sharedQueue setMaxConcurrentOperationCount:3];
    }
    
    return _sharedQueue;
}

+ (void)dataWithContentsOfURL:(NSURL *)url completionBlock:(void (^)(NSURL *, NSData *, NSError *))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:5.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[self downloadQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(completion) {
                                   completion(url, data, connectionError);
                               }
                           }
     ];
}

- (void)load {
    [self loadWithCompletionBlock:nil];
}

- (void)loadWithCompletionBlock:(void(^)(UIImage *image, NSURL *url, NSError *error))handler {
    self.loadingState = UIImageViewURLDownloadStateNowLoading;
    
    [self showLoadingView];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.cachingQueue, ^{
        UIImage *cacheImage = [CCCacheManager imageWithURL:weakSelf.url storeMemoryCache:YES];
        if (weakSelf.messageAvatarType != CCMessageAvatarTypeNormal) {
            cacheImage = [CCMessageAvatarFactory avatarImageNamed:cacheImage messageAvatarType:weakSelf.messageAvatarType];
        }
        if (cacheImage) {
            [weakSelf setImage:cacheImage forURL:weakSelf.url];
            if (handler)
                handler(cacheImage, weakSelf.url, nil);
        } else {
            // It could be more better by replacing with a method that has delegates like a progress.
            [UIImageView dataWithContentsOfURL:weakSelf.url
                               completionBlock:^(NSURL *url, NSData *data, NSError *error) {
                                   UIImage *image = [weakSelf didFinishDownloadWithData:data forURL:url error:error];
                                   
                                   if(handler) {
                                       handler(image, url, error);
                                   }
                               }
             ];
        }
    });
}

- (void)cachingImageData:(NSData *)imageData url:(NSURL *)url {
    dispatch_async(self.cachingQueue, ^{
        if (imageData) {
            [CCCacheManager storeData:imageData forURL:url storeMemoryCache:NO];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image)
                [CCCacheManager storeMemoryCacheWithImage:image forURL:url];
        }
    });
}

- (UIImage *)didFinishDownloadWithData:(NSData *)data forURL:(NSURL *)url error:(NSError *)error {
    if (data) {
        [self cachingImageData:data url:url];
    }
    UIImage *image = [UIImage imageWithData:data];
    if (self.messageAvatarType != CCMessageAvatarTypeNormal) {
        image = [CCMessageAvatarFactory avatarImageNamed:image messageAvatarType:self.messageAvatarType];
    }
    if([url isEqual:self.url]) {
        if(error) {
            self.loadingState = UIImageViewURLDownloadStateFailed;
        } else {
            [self performSelectorOnMainThread:@selector(setupImage:) withObject:image waitUntilDone:NO];
            self.loadingState = UIImageViewURLDownloadStateLoaded;
        }
        [self hideLoadingView];
    }
    return image;
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)url {
    if([url isEqual:self.url]) {
        [self performSelectorOnMainThread:@selector(setupImage:) withObject:image waitUntilDone:NO];
        self.loadingState = UIImageViewURLDownloadStateLoaded;
        [self hideLoadingView];
    }
}

#pragma mark -
#pragma mark :.  CCBadgeView

static NSString const * CCBadgeViewKey = @"CCBadgeViewKey";
static NSString const * CCBadgeViewFrameKey = @"CCBadgeViewFrameKey";
static NSString const * CCCircleBadgeViewKey = @"CCCircleBadgeViewKey";

- (void)setBadgeViewFrame:(CGRect)badgeViewFrame {
    objc_setAssociatedObject(self, &CCBadgeViewFrameKey, NSStringFromCGRect(badgeViewFrame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)badgeViewFrame {
    return CGRectFromString(objc_getAssociatedObject(self, &CCBadgeViewFrameKey));
}

- (UIView *)badgeView {
    UIView *badgeView = objc_getAssociatedObject(self, &CCBadgeViewKey);
    if (badgeView)
        return badgeView;
    
    badgeView = [[UIView alloc] initWithFrame:self.badgeViewFrame];
    [self addSubview:badgeView];
    
    self.badgeView = badgeView;
    
    return badgeView;
}

- (void)setBadgeView:(UIView *)badgeView {
    objc_setAssociatedObject(self, &CCBadgeViewKey, badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)setupCircleBadge {
    self.opaque = NO;
    self.clipsToBounds = NO;
    CGRect circleViewFrame = CGRectMake(CGRectGetWidth(self.bounds) - 4, 0, 8, 8);
    
    CCCircleView *circleView = objc_getAssociatedObject(self, &CCCircleBadgeViewKey);
    if (!circleView) {
        circleView = [[CCCircleView alloc] initWithFrame:circleViewFrame];
        [self addSubview:circleView];
        objc_setAssociatedObject(self, &CCCircleBadgeViewKey, circleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    circleView.frame = circleViewFrame;
    circleView.hidden = NO;
    
    return circleView;
}

- (void)destroyCircleBadge {
    CCCircleView *circleView = objc_getAssociatedObject(self, &CCCircleBadgeViewKey);
    if (circleView) {
        circleView.hidden = YES;
    }
}

@end
