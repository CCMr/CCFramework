//
//  CCLabel.m
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

#import "CCLabel.h"

@implementation CCLabel

const NSStringDrawingOptions CCDrawingOptions = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;

#pragma mark -

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  初始化
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (instancetype)init
{
    return [self initWithFrame:CGRectZero edgeInsets:UIEdgeInsetsZero];
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  初始化
 *
 *  @param frame <#frame description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame edgeInsets:UIEdgeInsetsZero];
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  初始化设置
 *
 *  @param frame      <#frame description#>
 *  @param edgeInsets <#edgeInsets description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (instancetype)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)edgeInsets
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.clipsToBounds = NO;
        self.verticalAlignment = CCVerticalAlignmentCenter;
        self.edgeInsets = edgeInsets;
        self.font = [UIFont systemFontOfSize:12];
        self.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        self.lineBreakMode = NSLineBreakByWordWrapping;
        self.numberOfLines = 0;
    }
    
    return self;
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  计算任意文本给定宽度的高度。
 *
 *  @param width 鉴于宽度文本块来计算高度。
 *  @param text  文字高度计算。可以的NSString或NSAttributedString。
 *  @param font  字体为给定的文本。只有当使用文字是NSString类的。
 *
 *  @return 给定文本的宽度给予高度。
 *
 *  @since 1.0
 */
+ (CGFloat)heightForWidth:(CGFloat)width text:(id)text font:(UIFont *)font
{
    CGFloat height;
    
    if ([text isKindOfClass:[NSString class]]) {
        height = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:CCDrawingOptions attributes:@{NSFontAttributeName: font} context:nil].size.height;
    } else {
        height = [text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:CCDrawingOptions context:nil].size.height;
    }
    
    return ceilf(height);
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  更新内容模式
 *
 *  @since 1.0
 */
- (void)updateContentMode
{
    switch (self.verticalAlignment) {
        case CCVerticalAlignmentTop:
            switch (self.textAlignment) {
                case NSTextAlignmentLeft:
                    self.contentMode = UIViewContentModeTopLeft;
                    break;
                    
                case NSTextAlignmentCenter:
                case NSTextAlignmentJustified:
                case NSTextAlignmentNatural:
                    self.contentMode = UIViewContentModeTop;
                    break;
                    
                case NSTextAlignmentRight:
                    self.contentMode = UIViewContentModeTopRight;
                    break;
            }
            break;
            
        case CCVerticalAlignmentCenter:
            switch (self.textAlignment) {
                case NSTextAlignmentLeft:
                    self.contentMode = UIViewContentModeLeft;
                    break;
                    
                case NSTextAlignmentCenter:
                case NSTextAlignmentJustified:
                case NSTextAlignmentNatural:
                    self.contentMode = UIViewContentModeCenter;
                    break;
                    
                case NSTextAlignmentRight:
                    self.contentMode = UIViewContentModeRight;
                    break;
            }
            break;
            
        case CCVerticalAlignmentBottom:
            switch (self.textAlignment) {
                case NSTextAlignmentLeft:
                    self.contentMode = UIViewContentModeBottomLeft;
                    break;
                    
                case NSTextAlignmentCenter:
                case NSTextAlignmentJustified:
                case NSTextAlignmentNatural:
                    self.contentMode = UIViewContentModeBottom;
                    break;
                    
                case NSTextAlignmentRight:
                    self.contentMode = UIViewContentModeBottomRight;
                    break;
            }
            break;
    }
}

- (void)setVerticalAlignment:(CCVerticalAlignment)verticalAlignment
{
    _verticalAlignment = verticalAlignment;
    [self updateContentMode];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self updateContentMode];
    [self setNeedsDisplay];
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  插图从标签到文本的边缘。
 *
 *  @param edgeInsets <#edgeInsets description#>
 *
 *  @since 1.0
 */
- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    [self setNeedsDisplay];
}


- (CGSize)sizeThatFits:(CGSize)size
{
    UIEdgeInsets edgeInsets = self.edgeInsets;
    NSInteger numberOfLines = self.numberOfLines;
    
    CGSize insettedSize = CGSizeMake(size.width - edgeInsets.left - edgeInsets.right, size.height - edgeInsets.top - edgeInsets.bottom);
    CGRect rect = [self.attributedText boundingRectWithSize:insettedSize options:CCDrawingOptions context:nil];
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    if (numberOfLines > 0) {
        CGFloat maxHeight = self.font.lineHeight * numberOfLines;
        
        if (height > maxHeight) {
            height = maxHeight;
        }
    }
    
    width += edgeInsets.left + edgeInsets.right;
    height += edgeInsets.top + edgeInsets.bottom;
    
    return CGSizeMake(ceilf(width), ceilf(height));
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  计算接收器的`frame`矩形的当前文本和给定的宽度高度。
 *
 *  @param width 宽度reciiver`frame`矩形来计算高度，在分。
 *
 *  @return 在点来计算的高度。
 *
 *  @since 1.0
 */
- (CGFloat)heightForWidth:(CGFloat)width
{
    return [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  计算接收器的`frame`矩形的当前文本和给定的宽度和改变`frame`的大小此值的高度。
 *
 *  @param width 宽度reciiver`frame`矩形来计算高度，在分。
 *
 *  @return 在点来计算的高度。
 *
 *  @since 1.0
 */
- (CGFloat)heightAdjustedForWidth:(CGFloat)width
{
    CGFloat textHeight = [self heightForWidth:width];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, textHeight);
    
    return textHeight;
}


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    UIEdgeInsets edgeInsets = self.edgeInsets;
    CGRect insettedBounds = UIEdgeInsetsInsetRect(bounds, edgeInsets);
    CGRect textRect = CGRectZero;
    BOOL adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth && numberOfLines == 1;
    
    if (adjustsFontSizeToFitWidth) {
        textRect.size = [self.attributedText size];
    } else {
        textRect = [self.attributedText boundingRectWithSize:insettedBounds.size options:CCDrawingOptions context:nil];
    }
    
    CGFloat textWidth = ceilf(textRect.size.width);
    CGFloat textHeight = ceilf(textRect.size.height);
    
    if (!adjustsFontSizeToFitWidth) {
        if (textWidth > insettedBounds.size.width) {
            textWidth = insettedBounds.size.width;
        }
        
        if (textHeight > insettedBounds.size.height) {
            textHeight = insettedBounds.size.height;
        }
    }
    
    if (numberOfLines > 0) {
        CGFloat maxHeight = ceilf(self.font.lineHeight * numberOfLines);
        
        if (textHeight > maxHeight) {
            textHeight = maxHeight;
        }
    }
    
    CGFloat originX;
    CGFloat originY;
    
    switch (self.verticalAlignment) {
        case CCVerticalAlignmentTop:
            originY = insettedBounds.origin.y;
            break;
            
        case CCVerticalAlignmentCenter:
            originY = insettedBounds.origin.y + (insettedBounds.size.height - textHeight) / 2;
            break;
            
        case CCVerticalAlignmentBottom:
            originY = insettedBounds.origin.y + (insettedBounds.size.height - textHeight);
            break;
            
        default:
            break;
    }
    
    switch (self.textAlignment) {
        case NSTextAlignmentJustified:
        case NSTextAlignmentLeft:
        case NSTextAlignmentNatural:
            originX = insettedBounds.origin.x;
            break;
            
        case NSTextAlignmentCenter:
            originX = insettedBounds.origin.x + (insettedBounds.size.width - textWidth) / 2;
            break;
            
        case NSTextAlignmentRight:
            originX = insettedBounds.origin.x + (insettedBounds.size.width - textWidth);
            break;
            
        default:
            break;
    }
    
    return CGRectMake(originX, originY, textWidth, textHeight);
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  绘画文字
 *
 *  @param rect <#rect description#>
 *
 *  @since 1.0
 */
- (void)drawTextInRect:(CGRect)rect
{
    NSInteger numberOfLines = self.numberOfLines;
    
    CGRect textRect = [self textRectForBounds:rect limitedToNumberOfLines:numberOfLines];
    
    UIFont *savedFont;
    
    if (self.adjustsFontSizeToFitWidth && numberOfLines == 1) {
        
        CGRect insettedRect = UIEdgeInsetsInsetRect(rect, self.edgeInsets);
        
        if (textRect.size.width > insettedRect.size.width || textRect.size.height > insettedRect.size.height) {
            
            savedFont = self.font;
            CGFloat savedPointSize = savedFont.pointSize;
            
            CGFloat ratio = MIN(insettedRect.size.width / textRect.size.width, insettedRect.size.height / textRect.size.height);
            
            CGFloat currentFontSize = MAX(savedPointSize * ratio, savedPointSize * self.minimumScaleFactor);
            
            self.font = [UIFont fontWithName:savedFont.fontName size:currentFontSize];
            textRect = [self textRectForBounds:rect limitedToNumberOfLines:numberOfLines];
        }
    }
    
    if (self.highlighted && self.highlightedTextColor) {
        NSMutableAttributedString *highlightedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [highlightedString addAttribute:NSForegroundColorAttributeName value:self.highlightedTextColor range:NSMakeRange(0, highlightedString.length)];
        [highlightedString drawWithRect:textRect options:CCDrawingOptions context:nil];
    } else {
        [self.attributedText drawWithRect:textRect options:CCDrawingOptions context:nil];
    }
    
    if (savedFont) {
        self.font = savedFont;
    }
}


@end
