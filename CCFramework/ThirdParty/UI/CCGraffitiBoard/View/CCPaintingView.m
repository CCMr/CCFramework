//
//  CCPaintingView.m
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


#import "CCPaintingView.h"
#import "CCPaintingLayer.h"

@import AssetsLibrary;

/** 对图片像素进行向下舍入取整,不然截图边界可能会有很细的线. */
static inline CGFloat CCPixelRoundDown(CGFloat x, CGFloat scale)
{
    return (scale == 2.0) ? (NSInteger)(x * 2) / 2 : (NSInteger)x;
}

/** 保存失败弹窗标题. */
#define CC_SAVE_FAILURE_TITLE @"哎呀"

/** 保存失败弹窗内容. */
#define CC_SAVE_FAILURE_UNAUTHORIZED_MESSAGE @"没有相册权限,需要先去设置里开启才行的!"
#define CC_SAVE_FAILURE_DISK_INSUFFICIENT_MESSAGE @"存储空间不足了..."

/** 保存失败弹窗按钮标题. */
#define CC_SAVE_FAILURE_ACTION_TITLE @"好吧..."

/** 保存成功弹窗标题. */
#define CC_SAVE_SUCCESS_TITLE @"保存成功!"

/** 保存成功弹窗按钮标题. */
#define CC_SAVE_SUCCESS_ACTION_TITLE @"太好了~"


@interface CCPaintingView ()

/** 照片图层. */
@property(nonatomic, strong) CALayer *imageLayer;

/** 涂鸦图层. */
@property(nonatomic, strong) CCPaintingLayer *paintingLayer;

/** 能否撤销. */
@property(nonatomic, readwrite) BOOL canUndo;

/** 能否恢复. */
@property(nonatomic, readwrite) BOOL canRedo;

/** 是否应该开始触摸系列事件. */
@property(nonatomic) BOOL touchShouldBegin;

@end

@implementation CCPaintingView

@dynamic backgroundImage, paintBrush;

#pragma mark - 初始化

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_commonInit];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
- (void)p_commonInit
{
    _paintingLayer = [CCPaintingLayer layer];
    _imageLayer = [CALayer layer];
    _imageLayer.contentsScale = [UIScreen mainScreen].scale;
    
    [_imageLayer addSublayer:_paintingLayer];
    [self.layer addSublayer:_imageLayer];
    
    [_paintingLayer addObserver:self
                     forKeyPath:@"canUndo"
                        options:(NSKeyValueObservingOptions)kNilOptions
                        context:NULL];
    [_paintingLayer addObserver:self
                     forKeyPath:@"canRedo"
                        options:(NSKeyValueObservingOptions)kNilOptions
                        context:NULL];
}
#pragma clang diagnostic pop

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.imageLayer.frame)) {
        self.imageLayer.frame = self.bounds;
        self.paintingLayer.frame = self.bounds;
    }
}

#pragma mark - 触摸事件处理

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [self.imageLayer convertPoint:[touches.anyObject locationInView:self]
                                        fromLayer:self.layer];
    
    self.touchShouldBegin = CGRectContainsPoint(self.imageLayer.bounds, point);
    
    if (self.touchShouldBegin) {
        [self.paintingLayer touchAction:touches.anyObject];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchShouldBegin) {
        [self.paintingLayer touchAction:touches.anyObject];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchShouldBegin) {
        [self.paintingLayer touchAction:touches.anyObject];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.touchShouldBegin) {
        [self.paintingLayer touchAction:touches.anyObject];
    }
}

#pragma mark - 配置画板

- (void)setBackgroundImage:(UIImage *)image
{
    if (!image && !self.imageLayer.contents) return;
    
    [self.paintingLayer clear];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGFloat layerWidth = CGRectGetWidth(self.bounds);
    CGFloat layerHeight = CGRectGetHeight(self.bounds);
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    // 图片超出画板.
    if (!(imageWidth <= layerWidth && imageHeight <= layerHeight)) {
        
        // 令图片宽等于画板宽度,根据纵横比计算此时的图片高度.
        imageHeight = layerWidth * imageHeight / imageWidth;
        
        // 若算出的高度超出了画板高度,则说明假设不成立.这时令图片高度等于画板高度,据此计算高度即可.
        if (imageHeight > layerHeight) {
            imageHeight = layerHeight;
            imageWidth = imageHeight * imageWidth / image.size.height;
        } else {
            imageWidth = layerWidth;
        }
        
        // 对图片宽高进行向下舍入的像素取整.
        CGFloat scale = [UIScreen mainScreen].scale;
        imageWidth = CCPixelRoundDown(imageWidth, scale);
        imageHeight = CCPixelRoundDown(imageHeight, scale);
    }
    
    // 调整照片图层以及涂鸦图层,使之匹配图片大小.
    self.imageLayer.position = (CGPoint){layerWidth / 2, layerHeight / 2};
    self.imageLayer.bounds = (CGRect){.size = {imageWidth ?: layerWidth, imageHeight ?: layerHeight}};
    self.paintingLayer.frame = self.imageLayer.bounds;
    
    self.imageLayer.contents = (__bridge id)image.CGImage;
    
    [CATransaction commit];
}

- (UIImage *)backgroundImage
{
    return [UIImage imageWithCGImage:(__bridge CGImageRef)(self.imageLayer.contents)];
}

- (void)setPaintBrush:(id<CCPaintBrush>)paintBrush
{
    self.paintingLayer.paintBrush = paintBrush;
}

- (id<CCPaintBrush>)paintBrush
{
    return self.paintingLayer.paintBrush;
}

#pragma mark - 清屏和撤销
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"canUndo"]) {
        self.canUndo = [object canUndo];
    } else if ([keyPath isEqualToString:@"canRedo"]) {
        self.canRedo = [object canRedo];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-property-ivar"
- (BOOL)canUndo
{
    return self.paintingLayer.canUndo;
}

- (BOOL)canRedo
{
    return self.paintingLayer.canRedo;
}
#pragma clang diagnostic pop

- (void)clear
{
    [self.paintingLayer clear];
}

- (void)undo
{
    [self.paintingLayer undo];
}

- (void)redo
{
    [self.paintingLayer redo];
}

#pragma mark - 保存图片

- (void)saveToPhotosAlbum
{
    UIGraphicsBeginImageContextWithOptions(self.imageLayer.bounds.size, YES, 0);
    if (self.imageLayer.contents) {
        [self.imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    } else {
        // 没有图片时需用父图层渲染,用 imageLayer 会黑乎乎一片.而且不知为何 paintingLayer 渲染出来也是黑的.
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       @selector(p_image:didFinishSavingWithError:contextInfo:),
                                       NULL);
    });
}

- (void)p_image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *title, *message, *actionTitle;
    if (error) {
        title = CC_SAVE_FAILURE_TITLE;
        if (error.code == ALAssetsLibraryWriteDiskSpaceError) { // 磁盘空间不足.
            message = CC_SAVE_FAILURE_DISK_INSUFFICIENT_MESSAGE;
        } else if (error.code == ALAssetsLibraryDataUnavailableError) { // 没有相册访问权限.
            message = CC_SAVE_FAILURE_UNAUTHORIZED_MESSAGE;
        }
        actionTitle = CC_SAVE_FAILURE_ACTION_TITLE;
    } else {
        title = CC_SAVE_SUCCESS_TITLE;
        actionTitle = CC_SAVE_SUCCESS_ACTION_TITLE;
    }
    
    // FIXME: dismiss 弹窗后会有个 NSMutableArray 对象(貌似是储存 action 用的)出现内存泄露.网上说这是个 bug.
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:actionTitle
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

@end
