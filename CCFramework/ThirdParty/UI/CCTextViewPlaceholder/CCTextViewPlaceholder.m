//
//  CCTextViewPlaceholder.m
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

#import "CCTextViewPlaceholder.h"

@interface CCTextViewPlaceholder()

@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation CCTextViewPlaceholder

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  初始化设置
 *
 *  @param frame <#frame description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  初始化提示语控件
 *
 *  @since 1.0
 */
- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTextViewChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    float left = 5,top = 2,hegiht = 30;
    
    _placeholderColor = [UIColor lightGrayColor];
    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, CGRectGetWidth(self.frame) - 2 * left, hegiht)];
    _placeholderLabel.font = _placeholderFont ? _placeholderFont : self.font;
    _placeholderLabel.textColor = self.placeholderColor;
    [self addSubview:_placeholderLabel];
    _placeholderLabel.text = _placeholder;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholderLabel.text = placeholder;
}

-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderLabel.textColor = placeholderColor;
}

-(void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderLabel.font = placeholderFont ? placeholderFont : self.font;
}

- (void)didTextViewChange:(NSNotification *)notification
{
    if (_placeholder.length == 0 || [_placeholder isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    }
    
    _placeholderLabel.hidden = NO;
    if (self.text.length > 0) {
        _placeholderLabel.hidden = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_placeholderLabel removeFromSuperview];
}

@end
