//
//  CCMessageTableViewCell.h
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


#import "BaseTableViewCell.h"
#import "CCMessageModel.h"
#import "CCMessageBubbleView.h"
#import "CCBadgeView.h"
#import "CCMessageAvatarFactory.h"
#import "CCConfigurationHelper.h"
#import "UIView+CCRemoteImage.h"

@class CCMessageTableViewCell;

@protocol CCMessageTableviewCellDelegate <NSObject>

@optional

/**
 *  点击多媒体消息的时候统一触发这个回调
 *
 *  @param message   被操作的目标消息Model
 *  @param indexPath 该目标消息在哪个IndexPath里面
 *  @param messageTableViewCell 目标消息在该Cell上
 */
- (void)multiMediaMessageDidSelectedOnMessage:(id <CCMessageModel>)message atIndexPath:(NSIndexPath *)indexPath onMessageTableViewCell:(CCMessageTableViewCell *)messageTableViewCell;

/**
 *  双击文本消息，触发这个回调
 *
 *  @param message   被操作的目标消息Model
 *  @param indexPath 该目标消息在哪个IndexPath里面
 */
- (void)didDoubleSelectedOnTextMessage:(id <CCMessageModel>)message atIndexPath:(NSIndexPath *)indexPath;

/**
 *  点击消息发送者的头像回调方法
 *
 *  @param indexPath 该目标消息在哪个IndexPath里面
 */
- (void)didSelectedAvatarOnMessage:(id <CCMessageModel>)message atIndexPath:(NSIndexPath *)indexPath;

/**
 *  Menu Control Selected Item
 *
 *  @param bubbleMessageMenuSelecteType 点击item后，确定点击类型
 */
- (void)menuDidSelectedAtBubbleMessageMenuSelecteType:(CCBubbleMessageMenuSelecteType)bubbleMessageMenuSelecteType;

/**
 *  @author CC, 15-09-15
 *
 *  @brief  未发送成功消息重新发送回调方法
 *
 *  @since 1.0
 */
- (void)didSelectedSendNotSuccessfulCallback;

@end

@interface CCMessageTableViewCell : BaseTableViewCell

@property (nonatomic, weak) id <CCMessageTableviewCellDelegate> delegate;

/**
 *  自定义多媒体消息内容View
 */
@property (nonatomic, weak, readonly) CCMessageBubbleView *messageBubbleView;

/**
 *  头像按钮
 */
@property (nonatomic, weak, readonly) UIButton *avatarButton;

/**
 *  用户名标签
 */
@property (nonatomic, weak, readonly) UILabel *userNameLabel;

/**
 *  时间轴Label
 */
@property (nonatomic, weak, readonly) CCBadgeView *timestampLabel;

/**
 *  Cell所在的位置，用于Cell delegate回调
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

/**
 *  获取消息类型
 *
 *  @return 返回消息类型，比如是发送消息，又或者是接收消息
 */
- (CCBubbleMessageType)bubbleMessageType;

/**
 *  初始化Cell的方法，必须先调用这个，不然不会初始化显示控件
 *
 *  @param message          需显示的目标消息Model
 *  @param displayTimestamp 预先告知是否需要显示时间轴Label
 *  @param cellIdentifier   重用Cell的标识
 *
 *  @return 返回消息Cell对象
 */
- (instancetype)initWithMessage:(id <CCMessageModel>)message
              displaysTimestamp:(BOOL)displayTimestamp
                reuseIdentifier:(NSString *)cellIdentifier;

/**
 *  根据消息Model配置Cell的显示内容
 *
 *  @param message          目标消息Model
 *  @param displayTimestamp 配置的时候告知是否需要显示时间轴Label
 */
- (void)configureCellWithMessage:(id <CCMessageModel>)message
               displaysTimestamp:(BOOL)displayTimestamp;

/**
 *  根据消息Model计算Cell的高度
 *
 *  @param message          目标消息Model
 *  @param displayTimestamp 是否显示时间轴Label
 *
 *  @return 返回Cell所需要的高度
 */
+ (CGFloat)calculateCellHeightWithMessage:(id <CCMessageModel>)message
                        displaysTimestamp:(BOOL)displayTimestamp;

@end
