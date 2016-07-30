//
//  CCTextView.m
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

#import "CCTextView.h"
#import "UIColor+Additions.h"
#import "NSString+Additions.h"

#define placefonttag 1001

@interface CCTextView ()

@property(nonatomic, strong) UILabel *placeholderLabel;

@property(nonatomic, strong) UILabel *wordCountLabel;

- (void)textChanged:(NSNotification *)notification;

@end

@implementation CCTextView

- (void)initialization
{
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    self.placeholder = [NSString string];
    self.placeholderFont = self.font;
    self.maxLength = 100;
    self.showWordCountLabel = NO;
    [self addSubview:self.wordCountLabel];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}


- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderFont:(UIFont *)placeholderFont
{
    _placeholderFont = placeholderFont;
    [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    [self setNeedsDisplay];
}

- (void)setIsPlaceholder:(BOOL)IsPlaceholder
{
    _IsPlaceholder = IsPlaceholder;
    [self textChanged:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UITextView properties
- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textChanged:nil];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self textChanged:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    //需要解释
    if ([[self placeholder] length] == 0) {
        return;
    }
    
    if ([[self text] length] == 0) {
        [[self viewWithTag:placefonttag] setAlpha:1];
    } else {
        [[self viewWithTag:placefonttag] setAlpha:0];
    }
    if (self.showWordCountLabel) {
        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/%ld", (unsigned long)self.text.length, (long)self.maxLength];
        [self updateWordCountLabelFrame];
    }
}

- (void)updateWordCountLabelFrame
{
    if (self.text.length == 0) {
        _wordCountLabel.hidden = YES;
    } else {
        _wordCountLabel.hidden = NO;
    }
    
    if (self.text.length > self.maxLength) {
        self.wordCountLabel.textColor = [UIColor redColor];
    } else {
        self.wordCountLabel.textColor = [UIColor colorFromHexCode:@"999999"];
    }
    
    CGSize size = [self.wordCountLabel.text calculateTextWidthWidth:CGFLOAT_MAX Font:self.wordCountLabel.font];
    [self.wordCountLabel setFrame:CGRectMake(self.frame.size.width - size.width, self.frame.size.height - size.height, size.width, size.height)];
}


- (UILabel *)wordCountLabel
{
    if (!_wordCountLabel) {
        _wordCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _wordCountLabel.font = [UIFont systemFontOfSize:13];
        _wordCountLabel.textColor = [UIColor colorFromHexCode:@"999999"];
    }
    return _wordCountLabel;
}


- (void)setShowWordCountLabel:(BOOL)showWordCountLabel
{
    _showWordCountLabel = showWordCountLabel;
    if (showWordCountLabel) {
        [self updateWordCountLabelFrame];
        self.wordCountLabel.hidden = NO;
    } else {
        self.wordCountLabel.hidden = YES;
    }
}


- (void)drawRect:(CGRect)rect
{
    if ([[self placeholder] length] > 0) {
        if (self.placeholderLabel == nil) {
            self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, self.bounds.size.width, 0)];
            self.placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.placeholderLabel.numberOfLines = 0;
            self.placeholderLabel.font = self.placeholderFont;
            self.placeholderLabel.backgroundColor = [UIColor clearColor];
            self.placeholderLabel.textColor = self.placeholderColor;
            self.placeholderLabel.alpha = 0;
            self.placeholderLabel.tag = placefonttag;
            [self addSubview:self.placeholderLabel];
        }
        
        self.placeholderLabel.text = [self.placeholder stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [self.placeholderLabel sizeToFit];
        [self sendSubviewToBack:self.placeholderLabel];
    }
    
    if ([[self text] length] == 0 && [[self placeholder] length] > 0)
        [[self viewWithTag:placefonttag] setAlpha:1];
    
    self.textContainerInset = UIEdgeInsetsMake(1, -5, 0, 0);
    [super drawRect:rect];
}

//隐藏键盘，实现UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self resignFirstResponder];
        return NO;
    }
    return YES;
}


@end
