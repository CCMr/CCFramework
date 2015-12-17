//
//  CCPaintingLayer.h
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


@import UIKit;

@protocol CCPaintBrush;

@interface CCPaintingLayer : CALayer

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  能否撤销
 */
@property(nonatomic, readonly) BOOL canUndo;

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  能否恢复
 */
@property(nonatomic, readonly) BOOL canRedo;

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  画刷对象
 */
@property(nonatomic, strong) id<CCPaintBrush> paintBrush;

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  触摸事件响应,于四个触摸事件发生时调用此方法并将 UITouch 传入
 *
 *  @param touch 触摸
 */
- (void)touchAction:(UITouch *)touch;

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  清屏
 */
- (void)clear;

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  撤销
 */
- (void)undo;

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  恢复
 */
- (void)redo;

@end
