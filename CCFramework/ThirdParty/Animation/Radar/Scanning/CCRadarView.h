//
//  CCRadarView.h
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

@class CCRadarIndicatorView;
@class CCRadarPointView;
@class CCRadarView;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  数据源
 */
@protocol CCRadarViewDataSource <NSObject>

@optional

- (NSInteger)numberOfSectionsInRadarView:(CCRadarView *)radarView;
- (NSInteger)numberOfPointsInRadarView:(CCRadarView *)radarView;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  自定义目标点视图
 *
 *  @param radarView <#radarView description#>
 *  @param index     <#index description#>
 *
 *  @return <#return value description#>
 */
- (CCRadarPointView *)radarView:(CCRadarView *)radarView viewForIndex:(NSUInteger)index;


@end

/**
 *  @author CC, 15-09-30
 *
 *  @brief  委托
 */
@protocol CCRadarViewDelegate <NSObject>

@optional

/**
 *  @author CC, 15-09-30
 *
 *  @brief  点击事件
 *
 *  @param radarView <#radarView description#>
 *  @param index     <#index description#>
 */
- (void)radarView:(CCRadarView *)radarView didSelectItemAtIndex:(NSUInteger)index;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  退出回调
 */
- (void)didDropOut;

@end



@interface CCRadarView : UIView

/**
 *  @author CC, 15-09-30
 *
 *  @brief  半径
 */
@property (nonatomic, assign) CGFloat radius;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  中间个人头像的半径
 */
@property (nonatomic, assign) CGFloat imageRadius;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  背景图片
 */
@property (nonatomic, strong) UIImage *backgroundImage;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  背景图片
 */
@property (nonatomic, strong) UIImage *PersonImage;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  退出按钮
 */
@property (nonatomic, strong) UIButton *dropOutButton;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  提示标签
 */
@property (nonatomic, strong) UILabel *textLabel;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  提示文字
 */
@property (nonatomic, strong) NSString *labelText;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  目标点视图
 */
@property (nonatomic, strong) UIView *pointsView;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  指针
 */
@property (nonatomic, strong) CCRadarIndicatorView *indicatorView;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  数据源
 */
@property (nonatomic, assign) id <CCRadarViewDataSource> dataSource;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  委托
 */
@property (nonatomic, assign) id <CCRadarViewDelegate> delegate;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  启动扫描
 */
-(void)startScanning;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  停止扫描
 */
-(void)stopScanning;

/**
 *  @author CC, 15-09-30
 *
 *  @brief  刷新数据源
 */
-(void)reloadData;

@end