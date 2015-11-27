/*
 *  CCPhoto.h
 *  CCPhoto
 *
 * Copyright (c) 2015 CC (http://www.ccskill.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface CCPhoto : NSObject

@property(nonatomic, strong) NSURL *url;
/**
 *  @author CC, 2015-11-27
 *  
 *  @brief  保存图片图片
 */
@property(nonatomic, copy) NSString *savePath;
@property(nonatomic, strong) UIImage *image;		// 完整的图片
@property(nonatomic, strong) UIImage *thumbImage;       //缩略图
@property(nonatomic, strong) UIImageView *srcImageView; // 来源view
@property(nonatomic, strong) UIImage *Placeholder;
@property(nonatomic, strong, readonly) UIImage *capture;

/**
 *  @author CC, 2015-06-04 17:06:32
 *
 *  @brief  用于相册选择查看
 *
 *  @since 1.0
 */
@property(nonatomic, strong) ALAsset *assets;

/**
 *  @author CC, 2015-06-04 18:06:38
 *
 *  @brief  用于相册查看记录选中对应index
 *
 *  @since 1.0
 */
@property(nonatomic, assign) NSInteger asssetIndex;

/**
 *  @author CC, 2015-06-04 19:06:22
 *
 *  @brief  用于传递选中小标
 *
 *  @since 1.0
 */
@property(nonatomic, assign) BOOL IsIndex;

//是否显示
@property(nonatomic, assign) BOOL firstShow;
//是否被选中
@property(nonatomic, assign) BOOL selectd;

// 是否已经保存到相册
@property(nonatomic, assign) BOOL save;
@property(nonatomic, assign) int index; // 索引

/**
 *  @author CC, 2015-11-26
 *  
 *  @brief  压缩图片
 *
 *  @param size 最大像素大小
 */
-(UIImage *)compressionWithMaxPixelSize:(NSUInteger)size;

@end