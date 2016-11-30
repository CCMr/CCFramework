//
//  CCPhotoBrowser.h
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
 *  @author CC, 16-03-18
 *
 *  @brief 朋友圈说说权限
 */
typedef NS_ENUM(NSInteger, PhotoBrowserType) {
    /** 弹出 */
    PhotoBrowserTypeShow = 0,
    /** Psuh */
    PhotoBrowserTypePush = 1,
    /** Psuh显示系统导航栏 */
    PhotoBrowserTypePushNavigationBar = 2,
    /** Psuh显示系统导航栏带删除 */
    PhotoBrowserTypePushNavigationBarDelete = 3,
};

@protocol CCPhotoBrowserDelegate;

@interface CCPhotoBrowser : UIViewController <UIScrollViewDelegate>

// 代理
@property(nonatomic, weak) id<CCPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property(nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property(nonatomic, assign) NSUInteger currentPhotoIndex;

@property(nonatomic, copy) void (^backPhotoBlock)(NSArray *photoAry);

/**
 *  @author CC, 16-08-23
 *
 *  @brief 隐藏回调事件
 */
@property(nonatomic, copy) void (^hidePhotoBlock)(CCPhotoBrowser *browser);

/**
 长按相片回调事件
 */
@property(nonatomic, copy) void (^pressPhotoBlock)(UIImage *photoImage,CCPhotoBrowser *photoBrwser);

/**
 *  @author CC, 16-03-29
 *
 *  @brief 底部工具条提供自定义
 */
@property(nonatomic, weak) UIView *bottomBar;

/**
 *  @author CC, 16-07-28
 *
 *  @brief 顶部工具条
 */
@property(nonatomic, strong) UIView *topBar;

- (instancetype)initWithBarType:(PhotoBrowserType)type;

/**
 *  @author CC, 16-07-01
 *
 *  @brief 设置右按钮
 */
- (void)setRightButton:(UIButton *)button;

/**
 设置导航栏右边按钮
 */
-(void)setNavigationRightButton:(UIButton *)button;

// 显示
- (void)show;

-(void)hide;
@end

@protocol CCPhotoBrowserDelegate <NSObject>

@optional
// 切换到某一页图片
- (void)photoBrowser:(CCPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

- (void)didSelectd:(NSUInteger)index; //选中或取消对象委托
- (void)didComplete:(NSUInteger)index;//如已有选中的对象，index不使用。

@end
