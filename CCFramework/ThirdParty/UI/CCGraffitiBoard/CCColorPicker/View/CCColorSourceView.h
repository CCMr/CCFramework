//
//  CCColorSourceView.h
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

@class CCDragChip;
@class CCColor;

@interface CCColorSourceView : UIView

@property(nonatomic, assign) CGPoint initialTap;

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  拖动核心
 */
@property(nonatomic, strong) CCDragChip *dragChip;

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  最后目标
 */
@property(nonatomic, strong) id lastTarget;

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  是否移动
 */
@property(nonatomic, readonly) BOOL moved;

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  拖动结束
 */
- (void)dragEnded;

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  颜色
 *
 *  @return 返回颜色
 */
- (CCColor *)color;

@end
