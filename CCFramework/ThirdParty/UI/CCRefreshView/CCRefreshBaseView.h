//
//  CCRefreshBaseView.h
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


// 如果定义了NeedAudio这个宏，说明需要音频
// 依赖于AVFoundation.framework 和 AudioToolbox.framework
//#define NeedAudio

// view的高度
#define kViewHeight 65.0

//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CCLoadLogoView.h"

typedef enum {
	RefreshStatePulling = 1,
	RefreshStateNormal = 2,
	RefreshStateRefreshing = 3
} RefreshState;

typedef enum {
    RefreshViewTypeHeader = -1,
    RefreshViewTypeFooter = 1
} RefreshViewType;

@class CCRefreshBaseView;

typedef void (^BeginRefreshingBlock)(CCRefreshBaseView *refreshView);

@protocol CCRefreshBaseViewDelegate <NSObject>
@optional
- (void)refreshViewBeginRefreshing:(CCRefreshBaseView *)refreshView;
@end

@interface CCRefreshBaseView : UIView
{
    // 父控件
    __weak UIScrollView *_scrollView;
    // 代理
    __weak id<CCRefreshBaseViewDelegate> _delegate;
    // 回调
    BeginRefreshingBlock _beginRefreshingBlock;
    
    // 子控件
    __weak UILabel *_lastUpdateTimeLabel;
	__weak UILabel *_statusLabel;
    __weak UIImageView *_arrowImage;
	__weak CCLoadLogoView *_activityView;
    
    // 状态
    RefreshState _state;

#ifdef NeedAudio
    // 音效
    SystemSoundID _normalId;
    SystemSoundID _pullId;
    SystemSoundID _refreshingId;
    SystemSoundID _endRefreshId;
#endif
}

// 构造方法
- (id)initWithScrollView:(UIScrollView *)scrollView;

// 内部的控件
@property (nonatomic, weak, readonly) UILabel *lastUpdateTimeLabel;
@property (nonatomic, weak, readonly) UILabel *statusLabel;
@property (nonatomic, weak, readonly) UIImageView *arrowImage;

// 回调
@property (nonatomic, copy) BeginRefreshingBlock beginRefreshingBlock;
// 代理
@property (nonatomic, weak) id<CCRefreshBaseViewDelegate> delegate;
// 设置要显示的父控件
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

// 是否正在刷新
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
// 开始刷新
- (void)beginRefreshing;
// 结束刷新
- (void)endRefreshing;
// 结束使用、释放资源
- (void)free;

// 交给子类去实现
- (void)setState:(RefreshState)state;
@end