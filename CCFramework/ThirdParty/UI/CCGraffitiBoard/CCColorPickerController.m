//
//  CCColorPickerController.m
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

#import "CCColorPickerController.h"
#import "CCColor.h"
#import "CCColorComparator.h"
#import "CCColorWheel.h"
#import "CCColorSquare.h"
#import "CCSwatches.h"
#import "CCColorSlider.h"
#import "CCMatrix.h"
#import "UIView+BUIView.h"
#import "config.h"

#define bottomToolHeight 44
#define alphaSliderHeight 30
#define viewHeigth (CGRectGetHeight(self.view.bounds) - bottomToolHeight - 80) / 2

typedef void (^Complete)(CCColor *color);

@interface CCColorPickerController () <CCSwatchesDelegate>

@property(nonatomic, strong) CCColor *color;
@property(nonatomic, strong) CCColorComparator *colorComparator;
@property(nonatomic, strong) CCColorWheel *colorWheel;
@property(nonatomic, strong) CCColorSquare *colorSquare;
@property(nonatomic, strong) CCSwatches *swatches;
@property(nonatomic, strong) CCColorSlider *alphaSlider;

@property(nonatomic, strong) CCMatrix *matrix;
@property(nonatomic, strong) UIView *firstCell;
@property(nonatomic, strong) UIView *secondCell;

@property(nonatomic, strong) Complete selectedColor;

@end

@implementation CCColorPickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initControl];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
    self.contentSizeForViewInPopover = self.view.frame.size;
    
    self.swatches.delegate = self;
    
    CCColor *color = [CCColor blackColor];
    if (_paintColor)
        color = _paintColor;
    self.initialColor = color;
    
    if (isiPhone) {
        
        CGRect matrixFrame = iPhone4 ? self.view.frame : CGRectInset(self.view.frame, 10, 10);
        _matrix = [[CCMatrix alloc] initWithFrame:matrixFrame];
        _matrix.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_matrix atIndex:0];
        _matrix.columns = 1;
        _matrix.rows = 2;
        
        self.secondCell.backgroundColor = nil;
        self.secondCell.opaque = NO;
        
        self.alphaSlider.superview.backgroundColor = nil;
        
        [_matrix setCellViews:@[ self.firstCell, self.secondCell ]];
    }
}

- (void)initControl
{
    [self.view addSubview:self.colorWheel];
    [self.colorWheel addSubview:self.colorComparator];
    
    [self.view addSubview:self.secondCell];
    [self.secondCell addSubview:self.colorSquare];
    [self.secondCell addSubview:self.alphaSlider];
    
    UIView *buttomToolView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - bottomToolHeight, CGRectGetWidth(self.view.bounds), bottomToolHeight)];
    buttomToolView.backgroundColor = [UIColor colorWithWhite:0.667f alpha:0.667f];
    [self.view addSubview:buttomToolView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:CCResourceImage(@"dismiss") forState:UIControlStateNormal];
    [button setImage:CCResourceImage(@"dismiss") forState:UIControlStateHighlighted];
    button.frame = CGRectMake(buttomToolView.width - (bottomToolHeight + 10), 0, bottomToolHeight, bottomToolHeight);
    [button addTarget:self action:@selector(doubleTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttomToolView addSubview:button];
}

#pragma mark :.  初始化属性
/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  色轮
 */
- (CCColorWheel *)colorWheel
{
    if (!_colorWheel) {
        _colorWheel = [[CCColorWheel alloc] initWithFrame:CGRectMake(50, 0, CGRectGetWidth(self.view.bounds) - 100, viewHeigth)];
        _colorWheel.backgroundColor = [UIColor clearColor];
        _firstCell = _colorWheel;
        [_colorWheel addTarget:self action:@selector(takeHueFrom:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
    }
    return _colorWheel;
}

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  颜色比较
 */
- (CCColorComparator *)colorComparator
{
    if (!_colorComparator) {
        CGFloat size = self.colorWheel.width / 2;
        _colorComparator = [[CCColorComparator alloc] initWithFrame:CGRectMake(size / 2, size / 2, size, size)];
        _colorComparator.target = self;
        _colorComparator.action = @selector(takeColorFromComparator:);
    }
    return _colorComparator;
}

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  第二块色值
 */
- (UIView *)secondCell
{
    if (!_secondCell) {
        _secondCell = [[UIView alloc] initWithFrame:CGRectMake(50, viewHeigth, CGRectGetWidth(self.view.bounds) - 100, viewHeigth)];
    }
    return _secondCell;
}

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  颜色方块
 */
- (CCColorSquare *)colorSquare
{
    if (!_colorSquare) {
        _colorSquare = [[CCColorSquare alloc] initWithFrame:CGRectMake(0, 0, self.secondCell.width, self.secondCell.height - alphaSliderHeight)];
        [_colorSquare addTarget:self action:@selector(takeBrightnessAndSaturationFrom:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
    }
    return _colorSquare;
}

/**
 *  @author CC, 2015-12-18
 *  
 *  @brief  透明滑块
 */
- (CCColorSlider *)alphaSlider
{
    if (!_alphaSlider) {
        _alphaSlider = [[CCColorSlider alloc] initWithFrame:CGRectMake(0, self.colorSquare.height + 10, self.secondCell.width, alphaSliderHeight - 10)];
        _alphaSlider.mode = CCColorSliderModeAlpha;
        [_alphaSlider addTarget:self action:@selector(takeAlphaFrom:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
    }
    return _alphaSlider;
}

#pragma mark :. 委托处理

- (void)doubleTapped:(id)sender
{
    if (_selectedColor)
        _selectedColor(_color);
    
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)takeColorFromComparator:(id)sender
{
    [self setColor:(CCColor *)[sender color]];
}

- (void)takeHueFrom:(id)sender
{
    float hue = [(CCColorWheel *)sender hue];
    CCColor *newColor = [CCColor colorWithHue:hue
                                   saturation:[_color saturation]
                                   brightness:[_color brightness]
                                        alpha:[_color alpha]];
    
    [self setColor:newColor];
}

- (void)takeBrightnessAndSaturationFrom:(id)sender
{
    float saturation = [(CCColorSquare *)sender saturation];
    float brightness = [(CCColorSquare *)sender brightness];
    
    CCColor *newColor = [CCColor colorWithHue:[_color hue]
                                   saturation:saturation
                                   brightness:brightness
                                        alpha:[_color alpha]];
    
    [self setColor:newColor];
}

- (void)takeAlphaFrom:(CCColorSlider *)slider
{
    float alpha = slider.floatValue;
    
    CCColor *newColor = [CCColor colorWithHue:[_color hue]
                                   saturation:[_color saturation]
                                   brightness:[_color brightness]
                                        alpha:alpha];
    [self setColor:newColor];
}

- (void)takeBrightnessFrom:(CCColorSlider *)slider
{
    float brightness = slider.floatValue;
    
    CCColor *newColor = [CCColor colorWithHue:[_color hue]
                                   saturation:[_color saturation]
                                   brightness:brightness
                                        alpha:[_color alpha]];
    
    [self setColor:newColor];
}

- (void)takeSaturationFrom:(CCColorSlider *)slider
{
    float saturation = slider.floatValue;
    
    CCColor *newColor = [CCColor colorWithHue:[_color hue]
                                   saturation:saturation
                                   brightness:[_color brightness]
                                        alpha:[_color alpha]];
    
    [self setColor:newColor];
}

- (void)set_color:(CCColor *)color
{
    _color = color;
    
    [self.colorWheel setColor:_color];
    [self.colorComparator setCurrentColor:_color];
    [self.colorSquare setColor:_color];
    [self.alphaSlider setColor:_color];
}

- (void)setInitialColor:(CCColor *)color
{
    [self.colorComparator setInitialColor:color];
    [self set_color:color];
}

- (void)setColor:(CCColor *)color
{
    [self set_color:color];
    //    [WDActiveState sharedInstance].paintColor = color;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        if (iPhone4) {
            _matrix.frame = CGRectOffset(CGRectInset(self.view.frame, 5, 20), 0, -5);
        } else {
            _matrix.frame = self.view.frame;
        }
        
        _matrix.columns = 2;
        _matrix.rows = 1;
    } else {
        if (iPhone4) {
            _matrix.frame = CGRectOffset(CGRectInset(self.view.frame, 5, 20), 0, -15);
        } else {
            _matrix.frame = CGRectOffset(CGRectInset(self.view.frame, 0, 5), 0, -5);
        }
        
        _matrix.columns = 1;
        _matrix.rows = 2;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didSelectedColor:(void (^)(CCColor *))block
{
    _selectedColor = block;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
