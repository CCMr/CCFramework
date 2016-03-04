//
//  UIViewController+Additions.h
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

@interface UIViewController (Additions)

- (void)backButtonTouched:(void (^)(UIViewController *vc))backButtonHandler;

/**
 *  @brief  视图层级
 *
 *  @return 视图层级字符串
 */
- (NSString *)recursiveDescription;

#pragma mark -
#pragma mark :. PopupViewController

typedef NS_ENUM(NSInteger, CCPopupViewAnimation) {
    CCPopupViewAnimationFade = 0,
    CCPopupViewAnimationSlideBottomTop = 1,
    CCPopupViewAnimationSlideBottomBottom,
    CCPopupViewAnimationSlideTopTop,
    CCPopupViewAnimationSlideTopBottom,
    CCPopupViewAnimationSlideLeftLeft,
    CCPopupViewAnimationSlideLeftRight,
    CCPopupViewAnimationSlideRightLeft,
    CCPopupViewAnimationSlideRightRight,
};

@property(nonatomic, retain) UIViewController *popupViewController;
@property(nonatomic, retain) UIView *popupBackgroundView;

- (void)presentPopupViewController:(UIViewController *)popupViewController
                     animationType:(CCPopupViewAnimation)animationType;

- (void)presentPopupViewController:(UIViewController *)popupViewController
                     animationType:(CCPopupViewAnimation)animationType
                   backgroundTouch:(BOOL)enable
                         dismissed:(void (^)(void))dismissed;

- (void)dismissPopupViewControllerWithanimationType:(CCPopupViewAnimation)animationType;

#pragma mark -
#pragma mark :. ScrollingStatusBar

- (void)enableStatusBarScrollingAlongScrollView:(UIScrollView *)scrollView;
- (void)disableStatusBarScrollingAlongScrollView:(UIScrollView *)scrollView;


#pragma mark -
#pragma makk :.StoreKit

@property NSString *campaignToken;
@property(nonatomic, copy) void (^loadingStoreKitItemBlock)(void);
@property(nonatomic, copy) void (^loadedStoreKitItemBlock)(void);

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 跳转商店
 *
 *  @param itemIdentifier 上架Identifier
 */
- (void)presentStoreKitItemWithIdentifier:(NSInteger)itemIdentifier;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 拼接上架地址
 *
 *  @param identifier 商店Identifier
 */
+ (NSURL *)appURLForIdentifier:(NSInteger)identifier;

+ (void)openAppURLForIdentifier:(NSInteger)identifier;

+ (void)openAppReviewURLForIdentifier:(NSInteger)identifier;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 校验是否是商店地址
 *
 *  @param URLString 网址
 */
+ (BOOL)containsITunesURLString:(NSString *)URLString;

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 商店地址获取Identifier
 *
 *  @param URLString 商店地址
 */
+ (NSInteger)IDFromITunesURL:(NSString *)URLString;

@end
