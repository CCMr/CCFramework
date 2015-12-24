//
//  CCPickerViewController.h
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

#import <UIKit/UIKit.h>
#import "Config.h"

@protocol CCPickerDelegate <NSObject>

/**
 *  @author CC, 2015-12-24
 *  
 *  @brief  选中图片委托
 *
 *  @param imageArray 选中照片集合
 */
- (void)pickerViewControllerCompleteImage:(NSArray *)imageArray;

@end

@interface CCPickerViewController : UIViewController

@property(nonatomic, weak) id<CCPickerDelegate> delegate;

/**
 *  @author CC, 2015-06-01 16:06:46
 *
 *  @brief  每次选择图片的最小数, 默认与最大数是9
 *
 *  @since 1.0
 */
@property(nonatomic, assign) NSInteger minCount;

/**
 *  @author CC, 2015-06-01 15:06:01
 *
 *  @brief  展示控制器
 *
 *  @since 1.0
 */
- (void)show;

/**
 *  @author CC, 2015-06-04 20:06:01
 *
 *  @brief 可以用代理来返回值或者用block来返回值
 *
 *  @param block <#block description#>
 *
 *  @since 1.0
 */
-(void)CompleteImage:(Completion)block;

@end
