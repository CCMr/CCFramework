//
//  CCMessageTextView.m
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

#import "CCMessageTextView.h"


@implementation CCMessageTextView

#pragma mark - setters

- (void)setPlaceholder:(NSString *)placeholder
{
    if ([placeholder isEqualToString:_placeholder])
        return;

    NSUInteger maxChars = [CCMessageTextView maxCharactersPerLine];
    if ([placeholder length] > maxChars) {
        placeholder = [placeholder substringToIndex:maxChars - 8];
        placeholder = [[placeholder stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingString:@"..."];
    }

    _placeholder = placeholder;
    [self setNeedsDisplay];
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    if ([placeholderTextColor isEqual:_placeholderTextColor])
        return;

    _placeholderTextColor = placeholderTextColor;
    [self setNeedsDisplay];
}

#pragma mark - Message TextView
- (NSUInteger)numberOfLinesOfText
{
    return [CCMessageTextView numberOfLinesForMessage:self.text];
}

+ (NSInteger)maxCharactersPerLine
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 33 : 109;
}

+ (NSInteger)numberOfLinesForMessage:(NSString *)text
{
    return (text.length / [self maxCharactersPerLine]) + 1;
}

#pragma mark - Text view overrides

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    //    [super setContentInset:contentInset];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

#pragma mark - Life cycle

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];

    _placeholderTextColor = [UIColor lightGrayColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    self.textAlignment = NSTextAlignmentLeft;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    _placeholder = nil;
    _placeholderTextColor = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

- (void)deleteBackward
{
    NSInteger stringLength = self.text.length;
    if (stringLength) {
        if ([@"\uFFFC" isEqualToString:[self.text substringFromIndex:stringLength - 1]]) {
            if ([self.cc_delegate respondsToSelector:@selector(didDeleteBackward)])
                [self.cc_delegate didDeleteBackward];
        }
    }

    [super deleteBackward];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    if ([self.text length] == 0 && self.placeholder) {
        CGRect placeHolderRect = CGRectMake(10.0f, 7.0f, rect.size.width, rect.size.height);
        [self.placeholderTextColor set];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            paragraphStyle.alignment = self.textAlignment;

            [self.placeholder drawInRect:placeHolderRect
                          withAttributes:@{NSFontAttributeName : self.font,
                                           NSForegroundColorAttributeName : self.placeholderTextColor,
                                           NSParagraphStyleAttributeName : paragraphStyle}];
        } else {
            [self.placeholder drawInRect:placeHolderRect
                                withFont:self.font
                           lineBreakMode:NSLineBreakByTruncatingTail
                               alignment:self.textAlignment];
        }
    }
    [super drawRect:rect];
}


@end
