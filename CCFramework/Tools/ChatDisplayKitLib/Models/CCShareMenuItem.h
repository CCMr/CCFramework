//
//  CCShareMenuItem.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EnumConfig.h"

#define kCCShareMenuItemWidth 60
#define KCCShareMenuItemHeight 80

@interface CCShareMenuItem : NSObject

/**
 *  正常显示图片
 */
@property (nonatomic, strong) UIImage *normalIconImage;

/**
 *  第三方按钮的标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  @author CC, 15-08-18
 *
 *  @brief  按钮类型
 *
 *  @since 1.0
 */
@property (nonatomic, assign) CCShareMenuItemType itemType;

/**
 *  根据正常图片和标题初始化一个Model对象
 *
 *  @param normalIconImage 正常图片
 *  @param title           标题
 *
 *  @return 返回一个Model对象
 */
- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title
                           MenuItemType:(CCShareMenuItemType)itemType;

@end
