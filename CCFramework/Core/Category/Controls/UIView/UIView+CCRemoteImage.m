//
//  UIView+CCRemoteImage.m
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

#import "UIView+CCRemoteImage.h"
#import <objc/runtime.h>
#import "CCCacheManager.h"
#import "CCMessageAvatarFactory.h"

const char* const kCCURLPropertyKey   = "CCURLDownloadURLPropertyKey";
const char* const kCCLoadingStateKey  = "CCURLDownloadLoadingStateKey";
const char* const kCCLoadingViewKey   = "CCURLDownloadLoadingViewKey";

const char* const kCCActivityIndicatorViewKey   = "CCActivityIndicatorViewKey";

const char* const kCCMessageAvatarTypeKey   = "CCMessageAvatarTypeKey";

#define kCCActivityIndicatorViewSize 35


@implementation UIView (CCRemoteImage)

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

#pragma mark- Properties

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

#pragma mark - Setup Image

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

#pragma mark- Loading view

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

#pragma mark- Image downloading

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


@end
