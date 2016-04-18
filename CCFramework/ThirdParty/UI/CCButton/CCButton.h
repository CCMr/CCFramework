//
//  CCButton.h
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

/**
 *  @author CC, 16-04-18
 *  
 *  @brief 图标和文本位置变化
 */
typedef NS_ENUM(NSInteger, CCAlignmentStatus) {
    /** 正常 */
    CCAlignmentStatusNormal,
    /** 左对齐 */
    CCAlignmentStatusLeft,
    /** 居中对齐 */
    CCAlignmentStatusCenter,
    /** 右对齐 */
    CCAlignmentStatusRight,
    /** 图标在上，文本在下(居中) */
    CCAlignmentStatusTop,
    /** 图标在下，文本在上(居中) */
    CCAlignmentStatusBottom,
};

@interface CCButton : UIButton

/**
 *  @author CC, 16-04-18
 *  
 *  @brief  外界通过设置按钮的status属性，创建不同类型的按钮
 */
@property(nonatomic, assign) CCAlignmentStatus status;

+ (instancetype)cc_shareButton;

- (instancetype)initWithAlignmentStatus:(CCAlignmentStatus)status;

@end
