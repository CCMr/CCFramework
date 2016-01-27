//
//  CCBannerView.h
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

@interface CCBannerView : UIView

/** 是否需要循环滚动, 默认为 NO */
@property(nonatomic, assign) IBInspectable BOOL shouldLoop;

/** 是否显示footer, 默认为 NO (此属性为YES时, shouldLoop会被置为NO) */
@property(nonatomic, assign) IBInspectable BOOL showFooter;

/** 是否自动滑动, 默认为 NO */
@property(nonatomic, assign) IBInspectable BOOL autoScroll;

/** 自动滑动间隔时间(s), 默认为 3.0 */
@property(nonatomic, assign) IBInspectable NSTimeInterval scrollInterval;

/** pageControl, 可自由配置其属性 */
@property(nonatomic, strong, readonly) UIPageControl *pageControl;

/**
 *  @author CC, 16-01-27
 *  
 *  @brief 占位图片
 */
@property(nonatomic, strong) UIImage *placeImage;

@property(nonatomic, copy) NSArray *bannerImageAry;

@property(nonatomic, copy) NSArray *bannerTitleAry;

/**
 *  @author CC, 16-01-27
 *  
 *  @brief 空闲标签
 */
@property(nonatomic, copy) NSString *idleTitle;

/**
 *  @author CC, 16-01-27
 *  
 *  @brief 触发跳转标签
 */
@property(nonatomic, copy) NSString *triggerTitle;

@property(nonatomic, copy) void (^CCBannerDidTapAtIndex)(NSInteger index);

@property (nonatomic,copy) void(^CCBannerFooterDidTrigger)(CCBannerView *banner);

@end
