//
//  CCPickerGroup.h
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
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface CCPickerGroup : NSObject

/**
 *  @author CC, 2015-06-01 14:06:06
 *
 *  @brief  组名
 *
 *  @since 1.0
 */
@property (nonatomic , copy) NSString *groupName;

/**
 *  @author CC, 2015-06-01 14:06:28
 *
 *  @brief  组的真实名
 *
 *  @since 1.0
 */
@property (nonatomic , copy) NSString *realGroupName;

/**
 *  @author CC, 2015-06-01 14:06:49
 *
 *  @brief  缩略图
 *
 *  @since 1.0
 */
@property (nonatomic , strong) UIImage *thumbImage;

/**
 *  @author CC, 2015-06-01 14:06:02
 *
 *  @brief  组里面的图片个数
 *
 *  @since 1.0
 */
@property (nonatomic , assign) NSInteger assetsCount;

/**
 *  @author CC, 2015-06-01 14:06:20
 *
 *  @brief  类型 : Saved Photos...
 *
 *  @since 1.0
 */
@property (nonatomic , copy) NSString *type;

@property (nonatomic , strong) ALAssetsGroup *group;

@end
