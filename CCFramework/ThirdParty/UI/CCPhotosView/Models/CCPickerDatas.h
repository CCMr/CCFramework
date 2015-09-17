//
//  CCPickerDatas.h
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
#import "CCPickerGroup.h"

// 回调
typedef void(^callBackBlock)(id obj);

@interface CCPickerDatas : NSObject

/**
 *  @author CC, 2015-06-01 14:06:32
 *
 *  @brief  获取所有组
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (instancetype) defaultPicker;

/**
 *  @author CC, 2015-06-01 14:06:48
 *
 *  @brief  获取所有组对应的图片
 *
 *  @param callBack <#callBack description#>
 *
 *  @since 1.0
 */
- (void) getAllGroupWithPhotos:(callBackBlock)callBack;

/**
 *  @author CC, 2015-06-01 14:06:59
 *
 *  @brief  传入一个组获取组里面的Asset
 *
 *  @param pickerGroup <#pickerGroup description#>
 *  @param callBack    <#callBack description#>
 *
 *  @since 1.0
 */
- (void) getGroupPhotosWithGroup:(CCPickerGroup *)pickerGroup Finished:(callBackBlock)callBack;

@end
