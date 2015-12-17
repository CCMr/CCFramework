//
//  CCColorAdjuster.m
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
#import "CCColorAdjuster.h"
#import "RSColorPickerView.h"


@interface CCColorAdjuster () <RSColorPickerViewDelegate>

/** 预览窗. */
@property(nonatomic, strong) IBOutlet UIView *previewView;

/** RGBA 标签. */
@property(nonatomic, strong) IBOutlet UILabel *RGBALabel;

/** 透明度调节滑块. */
@property(nonatomic, strong) IBOutlet UISlider *opacitySlider;

/** 亮度调节滑块. */
@property(nonatomic, strong) IBOutlet UISlider *brightnessSlider;

/** 颜色选择器. */
@property(nonatomic, strong) IBOutlet RSColorPickerView *colorPicker;

@end


@implementation CCColorAdjuster

#pragma mark - 设置预览窗边框

- (void)setPreviewView:(UIView *)previewView
{
    _previewView = previewView;
    
    _previewView.layer.borderColor = [UIColor grayColor].CGColor;
    _previewView.layer.cornerRadius = CGRectGetHeight(_previewView.bounds) / 4;
}

#pragma mark - 配置调色盘

- (void)setColorPicker:(RSColorPickerView *)colorPicker
{
    _colorPicker = colorPicker;
    
    colorPicker.selectionColor = self.paletteColor;
    
    self.opacitySlider.value = self.colorPicker.opacity;
    self.brightnessSlider.value = self.colorPicker.brightness;
}

- (void)setOpacitySlider:(UISlider *)opacitySlider
{
    _opacitySlider = opacitySlider;
    
    opacitySlider.value = self.colorPicker.opacity;
}

- (void)setBrightnessSlider:(UISlider *)brightnessSlider
{
    _brightnessSlider = brightnessSlider;
    
    brightnessSlider.value = self.colorPicker.brightness;
}

#pragma mark - 调节亮度

- (IBAction)brightnessChangeAction:(UISlider *)sender
{
    self.colorPicker.brightness = sender.value;
}

#pragma mark - 调节透明度

- (IBAction)alphaChangeAction:(UISlider *)sender
{
    self.colorPicker.opacity = sender.value;
}

#pragma mark - RSColorPickerViewDelegate

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)colorPicker
{
    UIColor *color = [colorPicker selectionColor];
    
    CGFloat red, green, blue, alpha;
    [[colorPicker selectionColor] getRed:&red green:&green blue:&blue alpha:&alpha];
    
    self.paletteColor = color;
    
    self.previewView.backgroundColor = color;
    
    self.RGBALabel.text = [NSString stringWithFormat:@"RGBA: %ld, %ld, %ld, %.2f",
                           (long)(red * 255), (long)(green * 255), (long)(blue * 255), alpha];
}

@end