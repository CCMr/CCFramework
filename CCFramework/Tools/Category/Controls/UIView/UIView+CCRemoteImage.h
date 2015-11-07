//
//  UIView+CCRemoteImage.h
//  CCFramework
//
//  Created by C C on 15/8/17.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@interface UIView (CCRemoteImage)

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


@end
