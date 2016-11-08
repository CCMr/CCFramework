//
//  CCEmotionManagerView.h
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
#import "CCEmotionManager.h"

#define kCCEmotionPerRowItemCount 10
#define kCCEmotionPageControlHeight 20
#define kCCEmotionSectionBarHeight 39

@protocol CCEmotionManagerViewDelegate <NSObject>

@optional
/**
 *  第三方gif表情被点击的回调事件
 *
 *  @param emotion   被点击的gif表情Model
 *  @param indexPath 被点击的位置
 */
- (void)didSelecteEmotion:(CCEmotion *)emotion
              atIndexPath:(NSIndexPath *)indexPath;

/**
 *  @author CC, 2015-12-11
 *
 *  @brief  第三方(小)gif表情被点击的回调事件
 *
 *  @param emotion   被点击的gif表情Model
 *  @param indexPath 被点击的位置
 */
- (void)didSelecteSmallEmotion:(CCEmotion *)emotion
                   atIndexPath:(NSIndexPath *)indexPath;

/**
 *  @author CC, 2015-12-03
 *
 *  @brief  商店按钮
 */
- (void)didStore;

/**
 *  @author CC, 16-08-04
 *
 *  @brief 发送消息
 */
- (void)didSendMessage;

/**
 *  @author CC, 16-09-02
 *
 *  @brief 表情管理
 */
- (void)didEmojiManage;

@end

@protocol CCEmotionManagerViewDataSource <NSObject>

@required
/**
 *  通过数据源获取统一管理一类表情的回调方法
 *
 *  @param column 列数
 *
 *  @return 返回统一管理表情的Model对象
 */
- (CCEmotionManager *)emotionManagerForColumn:(NSInteger)column;

/**
 *  通过数据源获取一系列的统一管理表情的Model数组
 *
 *  @return 返回包含统一管理表情Model元素的数组
 */
- (NSArray *)emotionManagersAtManager;

/**
 *  通过数据源获取总共有多少类gif表情
 *
 *  @return 返回总数
 */
- (NSInteger)numberOfEmotionManagers;

@end


@interface CCEmotionManagerView : UIView

@property(nonatomic, weak) id<CCEmotionManagerViewDelegate> delegate;

@property(nonatomic, weak) id<CCEmotionManagerViewDataSource> dataSource;

/**
 *  是否显示表情商店的按钮
 */
@property(nonatomic, assign) BOOL isShowEmotionStoreButton; // default is YES

/**
 *  @author CC, 16-09-02
 *
 *  @brief 发送按钮是否可以点击
 */
@property(nonatomic, assign) BOOL isSendButton;

/**
 *  @author C C, 2016-10-04
 *  
 *  @brief  是否管理(默认 YES)
 */
@property(nonatomic, assign) BOOL isManager;

/**
 *  根据数据源刷新UI布局和数据
 */
- (void)reloadData;


@end
