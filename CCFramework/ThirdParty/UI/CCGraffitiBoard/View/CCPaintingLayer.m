//
//  CCPaintingLayer.m
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


#import "CCPaintingLayer.h"
#import "CCPaintBrush.h"
#import "CCImageManger.h"

/** 是否显示重绘的矩形范围. */
#define SHOW_REDRAW_RECT 0

@interface CCPaintingLayer ()

/** 画板内容截图. */
@property(nonatomic, strong) UIImage *bitmap;

/** 画刷是否应该绘制. */
@property(nonatomic) BOOL brushShouldDraw;

/** 能否撤销. */
@property(nonatomic, readwrite) BOOL canUndo;

/** 能否恢复. */
@property(nonatomic, readwrite) BOOL canRedo;

@end


@implementation CCPaintingLayer

#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.drawsAsynchronously = YES;
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    return self;
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    // 绘制过程中 contents 会变动,返回 nil, 否则会有晃瞎狗眼的隐式动画.
    if ([event isEqualToString:@"contents"]) {
        return nil;
    }
    return [super actionForKey:event];
}

#pragma mark - 绘图

- (void)drawInContext:(CGContextRef)ctx
{
    // 将上次的图层内容作为位图渲染.
    if (self.bitmap) {
        // 翻转坐标系为原点在左下角的 CG 坐标系.
        CGContextTranslateCTM(ctx, 0, CGRectGetHeight(self.bounds));
        CGContextScaleCTM(ctx, 1, -1);
        
        CGContextDrawImage(ctx, self.bounds, self.bitmap.CGImage);
        
        // 翻转回原点在左上角的 UI 坐标系.
        CGContextScaleCTM(ctx, 1, -1);
        CGContextTranslateCTM(ctx, 0, -CGRectGetHeight(self.bounds));
    }
    
    // 使用画刷对象绘图.
    if (self.brushShouldDraw) {
        [self.paintBrush drawInContext:ctx];
    }
    
#if SHOW_REDRAW_RECT
    { // 这段代码可以显示每次的重绘区域.
        CGRect redrawRect = CGRectInset(CGContextGetClipBoundingBox(ctx), 0.5, 0.5);
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, 1, 0, 0, 1);
        CGContextStrokeRect(ctx, redrawRect);
    }
#endif
}

#pragma mark - 触摸处理

- (void)touchAction:(UITouch *)touch
{
    if (!self.paintBrush) return;
    
    CGPoint point = [self convertPoint:[touch locationInView:touch.view] fromLayer:touch.view.layer];
    
    switch (touch.phase) {
        case UITouchPhaseMoved:
            
            [self.paintBrush moveToPoint:point];
            
            break;
            
        case UITouchPhaseBegan:
            
            self.brushShouldDraw = YES;
            [self.paintBrush beginAtPoint:point];
            
            break;
            
        case UITouchPhaseEnded:
        case UITouchPhaseCancelled:
            
            [self.paintBrush end];
            
            self.brushShouldDraw = NO;
            self.canUndo = YES;
            self.canRedo = NO;
            
            // 截取图层当前的图像,下次直接作为位图绘制.
            // 这里必须为 NO, 由于重绘区域是个矩形,路径是条线条,如果为不透明则使用橡皮时矩形剩余部分都会渲染为黑色.
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
            [self renderInContext:UIGraphicsGetCurrentContext()];
            self.bitmap = UIGraphicsGetImageFromCurrentImageContext();
            [[CCImageManger sharedImageManger] addImage:self.bitmap];
            UIGraphicsEndImageContext();
            
            break;
            
        case UITouchPhaseStationary:
            break; // 占位用,不然有警告...
    }
    
    if (self.paintBrush.needsDraw) {
        [self setNeedsDisplayInRect:self.paintBrush.redrawRect];
    }
}

#pragma mark :. 操作

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  清屏
 */
- (void)clear
{
    if (!self.bitmap) return;
    
    self.bitmap = nil;
    self.canUndo = NO;
    self.canRedo = NO;
    
    [[CCImageManger sharedImageManger] removeAllImages];
    
    [self setNeedsDisplay];
}

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  撤销
 */
- (void)undo
{
    if (!self.canUndo) return;
    
    self.bitmap = [[CCImageManger sharedImageManger] imageForUndo];
    self.canUndo = [[CCImageManger sharedImageManger] canUndo];
    self.canRedo = YES;
    
    [self setNeedsDisplay];
}

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  恢复
 */
- (void)redo
{
    if (!self.canRedo) return;
    
    self.bitmap  = [[CCImageManger sharedImageManger] imageForRedo];
    self.canRedo = [[CCImageManger sharedImageManger] canRedo];
    self.canUndo = YES;
    
    [self setNeedsDisplay];
}

@end
