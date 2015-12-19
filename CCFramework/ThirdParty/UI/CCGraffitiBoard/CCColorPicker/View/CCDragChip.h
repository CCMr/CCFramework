//
//  CCDragChip.h
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

@class CCColor;

@interface CCDragChip : UIView

@property(nonatomic, strong) CCColor *color;

@end

@protocol CCColorDragging <NSObject>

@optional

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  拖动
 *
 *  @param touch  触控视图
 *  @param chip   拖动核心
 *  @param source 拖动源
 */
- (void)dragMoved:(UITouch *)touch
        colorChip:(CCDragChip *)chip
      colorSource:(id)source;

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  拖动结束
 */
- (void)dragExited;

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  拖动停止
 *
 *  @param touch  触控视图
 *  @param chip   拖动核心
 *  @param source 拖动源
 *  @param flyLoc 位置
 *
 *  @return 是否结束
 */
- (BOOL)dragEnded:(UITouch *)touch
        colorChip:(CCDragChip *)chip
      colorSource:(id)source
      destination:(CGPoint *)flyLoc;
@end
