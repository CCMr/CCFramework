//
//  CCTeletTextImage.h
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CCImageTppe) {
    CCImagePNGTppe = 0, // -> 本地图片
    CCImageURLType      // -> 网络图片
};


@interface CCTeletTextImage : NSObject

/**
 *  @author CC, 16-07-20
 *
 *  @brief 图片View
 */
@property(nonatomic, copy, readonly) UIImageView *imageView;

/**
 *  @author CC, 16-07-20
 *
 *  @brief 图片
 */
@property(nonatomic, copy) UIImage *image;

/**
 *  @author CC, 16-07-20
 *
 *  @brief 图片替换标签
 */
@property(nonatomic, copy) NSString *imageLabel;

/**
 *  @author CC, 16-07-20
 *
 *  @brief 图片地址
 */
@property(nonatomic, copy) NSString *imagePath;

/**
 *  @author CC, 16-07-19
 *
 *  @brief 图片名字
 */
@property(nonatomic, copy) NSString *imageName;

/**
 *  @author CC, 16-07-20
 *
 *  @brief 图片显示位置
 */
@property(nonatomic, assign) CGRect imageRect;

/**
 *  @author CC, 16-07-19
 *
 *  @brief 图片大小
 */
@property(nonatomic, assign) CGSize imageSize;

/**
 *  @author CC, 16-07-19
 *
 *  @brief 图片的位置
 */
@property(nonatomic, assign) NSInteger position;

/**
 *  @author CC, 16-07-20
 *
 *  @brief 图片类型
 */
@property(nonatomic, assign) CCImageTppe imageType;

/**
 *  @author CC, 16-07-20
 *
 *  @brief 图片显示类型
 */
@property(nonatomic, assign) NSUInteger adjustType;

/**
 *  @author CC, 16-07-19
 *
 *  @brief 占位图片属性字符的字体fontRef
 *         ->此处为方便计算Ascent和Descent
 */
@property(nonatomic, assign) CTFontRef fontRef;

/**
 *  @author CC, 16-07-19
 *
 *  @brief 图片与文字的上下左右的间距
 */
@property(nonatomic, assign) UIEdgeInsets imageInsets;

/**
 *  @author CC, 16-07-20
 *
 *  @brief 设置网络图片大小
 *         imagePath、imageSize必须先设置值
 */
- (void)setURLImageSize;

@end
