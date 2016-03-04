//
//  CCGraffitiBoardView.m
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

#import "CCGraffitiBoardView.h"
#import "UIButton+Additions.h"
#import "UIControl+Additions.h"
#import "config.h"
#import "CCPaintingView.h"
#import "CCBaseBrush.h"
#import "CCColorWell.h"
#import "CCBrushView.h"
#import "CCColorPickerController.h"
#import "CCColor.h"
#import "CCToolButton.h"

#define BottomNavigationBarHeigth 44

@interface CCGraffitiBoardView ()

/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  底部菜单导航
 */
@property(nonatomic, weak) UIScrollView *bottomNavigationBarScrollView;

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  颜色
 */
@property(nonatomic, strong) CCColorWell *colorWell;

/** 涂鸦板. */
@property(nonatomic, strong) CCPaintingView *paintingView;

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  画笔
 */
@property(nonatomic, strong) UIButton *brushStyleButton;

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  撤销
 */
@property(nonatomic, strong) UIButton *undoButton;

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  重做
 */
@property(nonatomic, strong) UIButton *redoButton;

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  笔画大小
 */
@property(nonatomic, assign) NSInteger lineWidthSlider;

/**
 *  @author CC, 2015-12-19
 *  
 *  @brief  画笔
 */
@property(nonatomic, strong) id<CCPaintBrush> paintingPen;

@end

@implementation CCGraffitiBoardView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    [self initControl];
}

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelAlert;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
}

- (void)hide
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelNormal;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view removeFromSuperview];
}

- (void)initControl
{
    [self IntiPaintBrush];
    [self InitBarItems];
    [self.view addSubview:self.bottomNavigationBarScrollView];
}

- (CCPaintingView *)paintingView
{
    if (!_paintingView) {
        CCPaintingView *paintingView = [[CCPaintingView alloc] initWithFrame:CGRectMake(0, 44, winsize.width, winsize.height - 88)];
        paintingView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:paintingView];
        _paintingView = paintingView;
    }
    return _paintingView;
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  初始化画板
 */
- (void)IntiPaintBrush
{
    // 创建并设置画刷.
    _paintingPen = [CCBaseBrush brushWithType:CCBrushTypePencil];
    _paintingPen.lineWidth = 10;
    _paintingPen.lineColor = [UIColor blackColor];
    self.paintingView.paintBrush = _paintingPen;
    
    // 注册 KVO 方便更新按钮状态.
    [self.paintingView addObserver:self
                        forKeyPath:@"canUndo"
                           options:(NSKeyValueObservingOptions)kNilOptions
                           context:NULL];
    [self.paintingView addObserver:self
                        forKeyPath:@"canRedo"
                           options:(NSKeyValueObservingOptions)kNilOptions
                           context:NULL];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"canUndo"]) {
        self.undoButton.enabled = self.paintingView.canUndo;
    } else if ([keyPath isEqualToString:@"canRedo"]) {
        self.redoButton.enabled = self.paintingView.canRedo;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark :. 预览画笔
- (void)previewBrush
{
    CALayer *previewLayer = self.brushStyleButton.layer.sublayers.lastObject;
    if (!previewLayer) {
        previewLayer = [CALayer layer];
        previewLayer.position = (CGPoint){CGRectGetMidX(self.brushStyleButton.bounds), CGRectGetMidY(self.brushStyleButton.bounds)};
        [self.brushStyleButton.layer addSublayer:previewLayer];
    }
    previewLayer.bounds = (CGRect){.size = {_lineWidthSlider, _lineWidthSlider}};
    previewLayer.cornerRadius = CGRectGetWidth(previewLayer.bounds) / 2;
    previewLayer.backgroundColor = [self.colorWell.color CGColor];
}

#pragma mark :. 属性
/**
 *  @author CC, 2015-12-16
 *  
 *  @brief  底部菜单导航
 */
- (UIScrollView *)bottomNavigationBarScrollView
{
    if (!_bottomNavigationBarScrollView) {
        UIScrollView *bottomNavigationBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - BottomNavigationBarHeigth, CGRectGetWidth(self.view.bounds), BottomNavigationBarHeigth)];
        bottomNavigationBarScrollView.backgroundColor = [UIColor colorWithWhite:0.667f alpha:0.667f];
        bottomNavigationBarScrollView.showsHorizontalScrollIndicator = NO;
        bottomNavigationBarScrollView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:bottomNavigationBarScrollView];
        _bottomNavigationBarScrollView = bottomNavigationBarScrollView;
    }
    return _bottomNavigationBarScrollView;
}


/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  初始化菜单
 */
- (void)InitBarItems
{
    
    UIView *topToolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    topToolView.backgroundColor = [UIColor colorWithWhite:0.667f alpha:0.667f];
    [self.view addSubview:topToolView];
    
    UIButton *backButton = [UIButton buttonWith];
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton setImage:CCResourceImage(@"returns") forState:UIControlStateNormal];
    [backButton setImage:CCResourceImage(@"returns") forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [topToolView addSubview:backButton];
    
    //画笔
    UIButton *brushButton = [CCToolButton buttonWithType:UIButtonTypeCustom];
    brushButton.frame = CGRectMake(winsize.width - 108, 0, 44, 44);
    [brushButton setImage:CCResourceImage(@"brush") forState:UIControlStateNormal];
    [brushButton setImage:CCResourceImage(@"brush") forState:UIControlStateHighlighted];
    brushButton.selected = YES;
    [brushButton addTarget:self action:@selector(didSelectBrush:) forControlEvents:UIControlEventTouchUpInside];
    [topToolView addSubview:brushButton];
    
    //橡皮擦
    UIButton *eraserButton = [CCToolButton buttonWithType:UIButtonTypeCustom];
    eraserButton.frame = CGRectMake(winsize.width - 54, 0, 44, 44);
    [eraserButton setImage:CCResourceImage(@"eraser") forState:UIControlStateNormal];
    [eraserButton setImage:CCResourceImage(@"eraser") forState:UIControlStateHighlighted];
    [eraserButton addTarget:self action:@selector(didEraser:) forControlEvents:UIControlEventTouchUpInside];
    [topToolView addSubview:eraserButton];
    
    //颜色
    _colorWell = [[CCColorWell alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [_colorWell addTarget:self action:@selector(showColorPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavigationBarScrollView addSubview:_colorWell];
    
    //画笔
    _brushStyleButton = [UIButton buttonWith];
    [_brushStyleButton setImage:CCResourceImage(@"style") forState:UIControlStateNormal];
    [_brushStyleButton setImage:CCResourceImage(@"style") forState:UIControlStateHighlighted];
    _brushStyleButton.frame = CGRectMake(44, 0, 44, 44);
    [_brushStyleButton addTarget:self action:@selector(showBrushPanel:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavigationBarScrollView addSubview:_brushStyleButton];
    
    //清除
    UIButton *clearButton = [UIButton buttonWithTitle:@"♻️"];
    clearButton.frame = CGRectMake(88, 0, 44, 44);
    [clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavigationBarScrollView addSubview:clearButton];
    
    //撤销
    UIButton *undoButton = [UIButton buttonWith];
    undoButton.frame = CGRectMake(132, 0, 44, 44);
    [undoButton setImage:CCResourceImage(@"undo") forState:UIControlStateNormal];
    [undoButton setImage:CCResourceImage(@"undo") forState:UIControlStateHighlighted];
    undoButton.enabled = NO;
    [undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavigationBarScrollView addSubview:self.undoButton = undoButton];
    
    //重做
    UIButton *redoButton = [UIButton buttonWith];
    redoButton.frame = CGRectMake(176, 0, 44, 44);
    [redoButton setImage:CCResourceImage(@"redo") forState:UIControlStateNormal];
    [redoButton setImage:CCResourceImage(@"redo") forState:UIControlStateHighlighted];
    redoButton.enabled = NO;
    [redoButton addTarget:self action:@selector(redoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavigationBarScrollView addSubview:self.redoButton = redoButton];
}

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  选择画笔
 */
- (void)didSelectBrush:(id)sender
{
    self.paintingView.paintBrush = _paintingPen;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CCActiveToolDidChange" object:nil userInfo:nil];
}

/**
 *  @author CC, 2015-12-19
 *  
 *  @brief  橡皮擦
 */
- (void)didEraser:(id)sender
{
    id<CCPaintBrush> paintBrush = [CCBaseBrush brushWithType:CCBrushTypeEraser];
    paintBrush.lineWidth = _paintingPen.lineWidth;
    paintBrush.lineColor = _paintingPen.lineColor;
    self.paintingView.paintBrush = paintBrush;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CCActiveToolDidChange" object:nil userInfo:nil];
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  设置颜色
 *
 *  @param sender 按钮
 */
- (void)showColorPicker:(id)sender
{
    CCColorPickerController *viewController = [[CCColorPickerController alloc] init];
    viewController.paintColor = self.colorWell.color;
    @weakify(self);
    [viewController didSelectedColor:^(CCColor *color) {
        @strongify(self);
        self.paintingPen.lineColor = color.UIColor;
        self.colorWell.color = color;
    }];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.windowLevel = UIWindowLevelAlert;
    [window addSubview:viewController.view];
    [window.rootViewController addChildViewController:viewController];
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  设置画笔
 *
 *  @param sender 按钮
 */
- (void)showBrushPanel:(id)sender
{
    CCBrushView *brushView = [[CCBrushView alloc] initWithFrame:self.view.bounds];
    brushView.currentValue = self.paintingPen.lineWidth;
    @weakify(self);
    [brushView didSelectBrush:^(float lineSize, CCBrushType type) {
        @strongify(self);
        
        id<CCPaintBrush> paintBrush = self.paintingPen;
        if (self.paintingView.paintBrush.currentType != type) {
            paintBrush = [CCBaseBrush brushWithType:type];
            paintBrush.lineColor = self.paintingPen.lineColor;
        }
        paintBrush.lineWidth = lineSize;
        
        self.paintingView.paintBrush = paintBrush;
    }];
    [brushView show];
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  撤销
 *
 *  @param sender 按钮
 */
- (void)undoAction:(id)sender
{
    [self.paintingView undo];
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  清除
 *
 *  @param sender 按钮
 */
- (void)clearAction:(id)sender
{
    [self.paintingView clear];
}

/**
 *  @author CC, 2015-12-17
 *  
 *  @brief  重做
 *
 *  @param sender 按钮
 */
- (void)redoAction:(id)sender
{
    [self.paintingView redo];   
}

@end
