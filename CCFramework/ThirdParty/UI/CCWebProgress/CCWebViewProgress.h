//
//  CCWebViewProgress.h
//  CC
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#undef CC_weak
#if __has_feature(objc_arc_weak)
#define CC_weak weak
#else
#define CC_weak unsafe_unretained
#endif

extern const float CCInitialProgressValue;
extern const float CCInteractiveProgressValue;
extern const float CCFinalProgressValue;

typedef void (^CCWebViewProgressBlock)(float progress);

@protocol CCWebViewProgressDelegate;

@interface CCWebViewProgress : NSObject<UIWebViewDelegate>

@property (nonatomic, CC_weak) id<CCWebViewProgressDelegate> progressDelegate;
@property (nonatomic, CC_weak) id<UIWebViewDelegate> webViewProxyDelegate;
@property (nonatomic, copy) CCWebViewProgressBlock progressBlock;
@property (nonatomic, readonly) float progress; // 0.0..1.0

- (void)reset;

@end

@protocol CCWebViewProgressDelegate <NSObject>

- (void)webViewProgress:(CCWebViewProgress *)webViewProgress updateProgress:(float)progress;

@end


