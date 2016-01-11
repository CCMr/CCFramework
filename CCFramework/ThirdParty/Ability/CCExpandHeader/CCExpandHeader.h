//
//  CCExpandHeader.h
//  CCFramework
//
// Copyright (c) 2016 CC ( http://www.ccskill.com )
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

@interface CCExpandHeader : NSObject

#pragma mark - 类方法
/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 生成一个CCExpandHeader实例
 *
 *  @param scrollView 滑动控件
 *  @param expandView 伸展的背景View
 */
+ (id)expandWithScrollView:(UIScrollView *)scrollView
                expandView:(UIView *)expandView;


#pragma mark - 成员方法
/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 扩展滑动事件
 *
 *  @param scrollView 滑动控件
 *  @param expandView 伸展的背景View  
 */
- (void)expandWithScrollView:(UIScrollView *)scrollView
                  expandView:(UIView *)expandView;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 监听scrollViewDidScroll方法
 *
 *  @param scrollView 伸展的背景View
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;

@end
