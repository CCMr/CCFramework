//
//  UIView+CCRemoteImage.h
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
