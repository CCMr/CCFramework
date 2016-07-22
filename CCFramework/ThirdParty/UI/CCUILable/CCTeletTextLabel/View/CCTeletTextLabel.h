//
//  CCTeletTextLabel.h
//  CCFramework
//
//  Created by CC on 16/7/11.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <CCFramework/CCFramework.h>

typedef NS_ENUM(NSInteger, ImageAdjustType) {
    /** 默认不调整(显示给予固定大小) */
    ImageAdjustTypeDefault = 0,
    /** 自适应(图片大小) */
    ImageAdjustTypeImageSize = 1,
    /** 固定宽(显示给予固定宽，高度等比调整) */
    ImageAdjustTypeWidth = 2,
    /** 固定高(显示给予固定高，宽度等比调整) */
    ImageAdjustTypeHeigth = 3,
};

typedef NS_OPTIONS(NSUInteger, CCDataDetectorTypes) {
    CCDataDetectorTypeURL = 1 << 1,	 // 链接，不用link定义，是因为link作为统称
    CCDataDetectorTypePhoneNumber = 1 << 0, // 电话
    CCDataDetectorTypeNone = 0,		 // 禁用
    CCDataDetectorTypeAll = NSUIntegerMax,  // 所有
    CCDataDetectorTypeEmail = 1 << 4,       // 邮箱
    CCDataDetectorTypeUserHandle = 1 << 5,  //@
    CCDataDetectorTypeHashtag = 1 << 6,     //#..#

    //上面是个性化的匹配
    //这个是对内容里带有Link属性的检测，至于为什么31，预留上面空间以添加新的个性化
    //这个东西和dataDetectorTypesOfAttributedLinkValue对应起来，会对带有NSLinkAttributeName区间的value进行检测，匹配则给予对应的LinkType，找不到则为Other
    CCDataDetectorTypeAttributedLink = 1 << 31,
};

typedef NS_ENUM(NSUInteger, CCLinkType) {
    CCLinkTypeNone = 0,
    CCLinkTypeURL = 1,	 // 链接
    CCLinkTypePhoneNumber = 2, // 电话
    CCLinkTypeEmail = 3,       // 邮箱
    CCLinkTypeUserHandle = 4,  //@
    CCLinkTypeHashtag = 5,     //#..#
    CCLinkTypeOther = 31,      //这个一般是和CCDataDetectorTypeAttributedLink对应的，但是也可以自己随意添加啦，不过是一个标识而已，至于为什么31，随便定的，预留上面空间以添加新的个性化
};

@class CCTeletTextLabel;

typedef void (^didClickLinkBlock)(CCTeletTextLabel *teletTextLabel, NSDictionary *teletTextEvent);

@interface CCTeletTextLabel : UIView

//默认为CCDataDetectorTypeURL|CCDataDetectorTypePhoneNumber|CCDataDetectorTypeEmail|CCDataDetectorTypeAttributedLink，自动检测除了@和#话题的全部类型并且转换为链接
@property(nonatomic, assign) CCDataDetectorTypes dataDetectorTypes;

@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) UIImage *defaultImage;
@property(nonatomic, strong) NSArray<NSString *> *replaceLabel;
@property(nonatomic, strong) NSArray<NSString *> *replacePath;
@property(nonatomic, strong) NSArray<NSDictionary *> *replaceSize;

@property (nonatomic,copy) NSAttributedString *attributedText;

/**
 * 选中超文本选中颜色
 */
@property (nonatomic, strong) UIColor *highlightColor;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIFont *linkFont;

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, strong) UIColor *linkColor;

@property (nonatomic, assign) NSUInteger numberOfLines;


/**
 *  @author CC, 16-07-15
 *
 *  @brief 图片适应类型
 */
@property(nonatomic, assign) ImageAdjustType adjustType;

- (void)didClickLinkBlock:(didClickLinkBlock)linkBlock;

@end
