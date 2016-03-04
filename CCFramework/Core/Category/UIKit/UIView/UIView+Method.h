//
//  UIView+Method.h
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

#import <UIKit/UIKit.h>

@interface CCCircleView : UIView

@end


@interface UIView (Method)

#pragma mark -
#pragma mark :. NIB

/**
 *  @brief  找到当前view所在的viewcontroler
 */
@property(readonly) UIViewController *viewController;

+ (UINib *)loadNib;
+ (UINib *)loadNibNamed:(NSString *)nibName;
+ (UINib *)loadNibNamed:(NSString *)nibName bundle:(NSBundle *)bundle;
+ (instancetype)loadInstanceFromNib;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner;
+ (instancetype)loadInstanceFromNibWithName:(NSString *)nibName owner:(id)owner bundle:(NSBundle *)bundle;

#pragma mark -
#pragma mark :. Method

/**
 *  @brief  找到指定类名的SubVie对象
 *
 *  @param clazz SubVie类名
 *
 *  @return view对象
 */
- (id)findSubViewWithSubViewClass:(Class)clazz;
/**
 *  @brief  找到指定类名的SuperView对象
 *
 *  @param clazz SuperView类名
 *
 *  @return view对象
 */
- (id)findSuperViewWithSuperViewClass:(Class)clazz;

/**
 *  @brief  找到并且resign第一响应者
 *
 *  @return 结果
 */
- (BOOL)findAndResignFirstResponder;
/**
 *  @brief  找到第一响应者
 *
 *  @return 第一响应者
 */
- (UIView *)findFirstResponder;

/**
 *  @author CC, 16-02-26
 *  
 *  @brief 是否包含视图类型
 *
 *  @param cls 视图类型
 */
- (BOOL)containsSubViewOfClassType:(Class)cls;

/**
 *  @author CC, 2015-07-16
 *
 *  @brief  清空View所子控件
 *
 *  @since 1.0
 */
- (void)removeAllSubviews;

/**
 *  @author CC, 16-02-26
 *  
 *  @brief 删除某项类型
 *
 *  @param cls 视图类型
 */
- (void)removeSubviewsWithSubviewClass:(Class)cls;

/**
 *  @brief  打印视图层级
 *
 *  @return 打印视图层级字符串
 */
- (NSString *)recursiveView;

/**
 *  @brief  打印约束
 *
 *  @return 打印约束字符串
 */
- (NSString *)constraintsDescription;

/**
 *  @brief  打印整个autolayout树的字符串
 *
 *  @return 打印整个autolayout树的字符串
 */
- (NSString *)autolayoutTraceDescription;

/**
 *  @brief  寻找子视图
 *
 *  @param recurse 回调
 *
 *  @return  Return YES from the block to recurse into the subview.
 Set stop to YES to return the subview.
 */
- (UIView *)findViewRecursively:(BOOL (^)(UIView *subview, BOOL *stop))recurse;

- (void)runBlockOnAllSubviews:(void (^)(UIView *view))block;
- (void)runBlockOnAllSuperviews:(void (^)(UIView *superview))block;
- (void)enableAllControlsInViewHierarchy;
- (void)disableAllControlsInViewHierarchy;

/**
 *  @brief  view截图
 *
 *  @return 截图
 */
- (UIImage *)screenshot;

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
- (UIImage *)screenshot:(CGFloat)maxWidth;

#pragma mark -
#pragma mark :. GestureCallback

@property(nonatomic) NSMutableDictionary *gestures;
@property(nonatomic) NSMutableDictionary *gestureKeysHash;


// tap
- (NSString *)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback;
- (NSString *)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback numberOfTapsRequired:(NSUInteger)numberOfTapsRequired numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired;
- (void)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback tapGestureId:(NSString *)tapGestureId;
- (void)addTapGestureRecognizer:(void (^)(UITapGestureRecognizer *recognizer, NSString *gestureId))tapCallback tapGestureId:(NSString *)tapGestureId numberOfTapsRequired:(NSUInteger)numberOfTapsRequired numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired;
- (void)removeTapGesture:(NSString *)tapGestureId;
- (void)removeAllTapGestures;
- (void)tapHandler:(UITapGestureRecognizer *)recognizer;


// pinch
- (NSString *)addPinchGestureRecognizer:(void (^)(UIPinchGestureRecognizer *recognizer, NSString *gestureId))pinchCallback;
- (void)addPinchGestureRecognizer:(void (^)(UIPinchGestureRecognizer *recognizer, NSString *gestureId))pinchCallback pinchGestureId:(NSString *)pinchGestureId;
- (void)removePinchGesture:(NSString *)pinchGestureId;
- (void)removeAllPinchGestures;
- (void)pinchHandler:(UIPinchGestureRecognizer *)recognizer;


// pan
- (NSString *)addPanGestureRecognizer:(void (^)(UIPanGestureRecognizer *recognizer, NSString *gestureId))panCallback;
- (NSString *)addPanGestureRecognizer:(void (^)(UIPanGestureRecognizer *recognizer, NSString *gestureId))panCallback minimumNumberOfTouches:(NSUInteger)minimumNumberOfTouches maximumNumberOfTouches:(NSUInteger)maximumNumberOfTouches;
- (void)addPanGestureRecognizer:(void (^)(UIPanGestureRecognizer *recognizer, NSString *gestureId))panCallback panGestureId:(NSString *)panGestureId minimumNumberOfTouches:(NSUInteger)minimumNumberOfTouches maximumNumberOfTouches:(NSUInteger)maximumNumberOfTouches;
- (void)removePanGesture:(NSString *)panGestureId;
- (void)removeAllPanGestures;
- (void)panHandler:(UIPanGestureRecognizer *)recognizer;


//swipe
- (NSString *)addSwipeGestureRecognizer:(void (^)(UISwipeGestureRecognizer *recognizer, NSString *gestureId))swipeCallback direction:(UISwipeGestureRecognizerDirection)direction;
- (NSString *)addSwipeGestureRecognizer:(void (^)(UISwipeGestureRecognizer *recognizer, NSString *gestureId))swipeCallback direction:(UISwipeGestureRecognizerDirection)direction numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired;
- (void)addSwipeGestureRecognizer:(void (^)(UISwipeGestureRecognizer *recognizer, NSString *gestureId))swipeCallback swipeGestureId:(NSString *)swipeGestureId direction:(UISwipeGestureRecognizerDirection)direction numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired;
- (void)removeSwipeGesture:(NSString *)swipeGestureId;
- (void)removeAllSwipeGestures;
- (void)swipeHandler:(UISwipeGestureRecognizer *)recognizer;


//rotation
- (NSString *)addRotationGestureRecognizer:(void (^)(UIRotationGestureRecognizer *recognizer, NSString *gestureId))rotationCallback;
- (void)addRotationGestureRecognizer:(void (^)(UIRotationGestureRecognizer *recognizer, NSString *gestureId))rotationCallback rotationGestureId:(NSString *)rotationGestureId;
- (void)removeRotationGesture:(NSString *)rotationGestureId;
- (void)removeAllRotationGestures;
- (void)rotationHandler:(UIRotationGestureRecognizer *)recognizer;


//long press
- (NSString *)addLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *recognizer, NSString *gestureId))longPressCallback;
- (NSString *)addLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *recognizer, NSString *gestureId))longPressCallback
                       numberOfTapsRequired:(NSUInteger)numberOfTapsRequired
                    numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
                       minimumPressDuration:(CFTimeInterval)minimumPressDuration
                          allowableMovement:(CGFloat)allowableMovement;
- (void)addLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *recognizer, NSString *gestureId))longPressCallback
                   longPressGestureId:(NSString *)longPressGestureId
                 numberOfTapsRequired:(NSUInteger)numberOfTapsRequired
              numberOfTouchesRequired:(NSUInteger)numberOfTouchesRequired
                 minimumPressDuration:(CFTimeInterval)minimumPressDuration
                    allowableMovement:(CGFloat)allowableMovement;

- (void)removeLongPressGesture:(NSString *)longPressGestureId;
- (void)removeAllLongPressGestures;
- (void)longPressHandler:(UILongPressGestureRecognizer *)recognizer;


#pragma mark -
#pragma mark :. Toast

extern NSString *const CSToastPositionTop;
extern NSString *const CSToastPositionCenter;
extern NSString *const CSToastPositionBottom;

// each makeToast method creates a view and displays it as toast
- (void)makeToast:(NSString *)message;
- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position;

- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            image:(UIImage *)image;

- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            title:(NSString *)title;

- (void)makeToast:(NSString *)message
         duration:(NSTimeInterval)interval
         position:(id)position
            title:(NSString *)title
            image:(UIImage *)image;

// displays toast with an activity spinner
- (void)makeToastActivity;
- (void)makeToastActivity:(id)position;
- (void)hideToastActivity;

// the showToast methods display any view as toast
- (void)showToast:(UIView *)toast;
- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)interval
         position:(id)point;

- (void)showToast:(UIView *)toast
         duration:(NSTimeInterval)interval
         position:(id)point
      tapCallback:(void (^)(void))tapCallback;


#pragma mark -
#pragma mark :. CustomBorder

typedef NS_OPTIONS(NSUInteger, ExcludePoint) {
    ExcludeStartPoint = 1 << 0,
    ExcludeEndPoint = 1 << 1,
    ExcludeAllPoint = ~0UL
};

- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth;
- (void)addLeftBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth;
- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth;
- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth;

- (void)removeTopBorder;
- (void)removeLeftBorder;
- (void)removeBottomBorder;
- (void)removeRightBorder;


- (void)addTopBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge;
- (void)addLeftBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge;
- (void)addBottomBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge;
- (void)addRightBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth excludePoint:(CGFloat)point edgeType:(ExcludePoint)edge;

#pragma mark -
#pragma mark :. WebCacheOperation

/**
 *  Set the image load operation (storage in a UIView based dictionary)
 *
 *  @param operation the operation
 *  @param key       key for storing the operation
 */
- (void)cc_setImageLoadOperation:(id)operation forKey:(NSString *)key;

/**
 *  Cancel all operations for the current UIView and key
 *
 *  @param key key for identifying the operations
 */
- (void)cc_cancelImageLoadOperationWithKey:(NSString *)key;

/**
 *  Just remove the operations corresponding to the current UIView and key without cancelling them
 *
 *  @param key key for identifying the operations
 */
- (void)cc_removeImageLoadOperationWithKey:(NSString *)key;


#pragma mark -
#pragma mark :. CCRemoteImage

/**
 *  @author C C, 15-08-17
 *
 *  @brief  加载图片状态
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, UIImageViewURLDownloadState) {
    UIImageViewURLDownloadStateUnknown = 0,
    UIImageViewURLDownloadStateLoaded,
    UIImageViewURLDownloadStateWaitingForLoad,
    UIImageViewURLDownloadStateNowLoading,
    UIImageViewURLDownloadStateFailed,
};

/**
 *  @author C C, 15-08-17
 *
 *  @brief  头像状态
 *
 *  @since 1.0
 */
typedef NS_ENUM(NSInteger, CCMessageAvatarType) {
    CCMessageAvatarTypeNormal = 0,
    CCMessageAvatarTypeSquare,
    CCMessageAvatarTypeCircle
};


// url
@property(nonatomic, strong) NSURL *url;

// download state
@property(nonatomic, readonly) UIImageViewURLDownloadState loadingState;

//
@property(nonatomic, assign) CCMessageAvatarType messageAvatarType;

// UI
@property(nonatomic, strong) UIView *loadingView;
// Set UIActivityIndicatorView as loadingView
- (void)setDefaultLoadingView;

// instancetype
+ (id)imageViewWithURL:(NSURL *)url autoLoading:(BOOL)autoLoading;

// Get instance that has UIActivityIndicatorView as loadingView by default
+ (id)indicatorImageView;
+ (id)indicatorImageViewWithURL:(NSURL *)url autoLoading:(BOOL)autoLoading;

// Download
- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url placeholer:(UIImage *)placeholerImage;
- (void)setImageWithURL:(NSURL *)url placeholer:(UIImage *)placeholerImage showActivityIndicatorView:(BOOL)show;
- (void)setImageWithURL:(NSURL *)url placeholer:(UIImage *)placeholerImage showActivityIndicatorView:(BOOL)show completionBlock:(void (^)(UIImage *image, NSURL *url, NSError *error))handler;

- (void)setImageUrl:(NSURL *)url autoLoading:(BOOL)autoLoading;
- (void)load;

#pragma mark -
#pragma mark :.  CCBadgeView

@property (nonatomic, assign) CGRect badgeViewFrame;
@property (nonatomic, strong, readonly) UIView *badgeView;

- (CCCircleView *)setupCircleBadge;

- (void)destroyCircleBadge;


@end
