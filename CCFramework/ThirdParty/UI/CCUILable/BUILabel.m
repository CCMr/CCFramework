//
//  BUILabel.m
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

#import "BUILabel.h"

@interface BUILabel()

@property (nonatomic, strong)  NSMutableAttributedString *attString;

@end

@implementation BUILabel

- (void)setText:(NSString *)text{
    [super setText:text];
    _attString = nil;
    if (text)
        _attString = [[NSMutableAttributedString alloc] initWithString:text];
}

-(void)setAlignmentCenter:(NSTextAlignment)Alignment{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:Alignment];
    [_attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
}

// 设置某段字的颜色
-(void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.text.length-1||length+location>self.text.length)
        return;
    [_attString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)color.CGColor range:NSMakeRange(location, length)];
}

// 设置某段字的字体
-(void)setFont:(UIFont *)font fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.text.length-1||length+location>self.text.length)
        return;
    [_attString addAttribute:(NSString *)kCTFontAttributeName value:(id)CFBridgingRelease(CTFontCreateWithName((CFStringRef)font.fontName,font.pointSize,NULL)) range:NSMakeRange(location, length)];
}

// 设置某段字的风格
-(void)setStyle:(CTUnderlineStyle)style fromIndex:(NSInteger)location length:(NSInteger)length{
    if (location < 0||location>self.text.length-1||length+location>self.text.length)
        return;
    [_attString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:style] range:NSMakeRange(location, length)];
}

/**
 *  @author CC, 2015-06-05 14:06:12
 *
 *  @brief  设置下划线
 *
 *  @param location <#location description#>
 *  @param length   <#length description#>
 *
 *  @since 1.0
 */
-(void)setUnderline:(NSInteger)location length:(NSInteger)length{
    [_attString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(location, length)];
}

#pragma  mark - 横线
-(void)drawTextInRect:(CGRect)rect{
    if (_strikeThroughEnabled) {
        [super drawTextInRect:rect];
        
        CGSize textSize = [[self text] sizeWithFont:[self font]];
        CGFloat strikeWidth = textSize.width;
        CGRect lineRect;
        
        if ([self textAlignment] == NSTextAlignmentRight)
            lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, 1);
        else if ([self textAlignment] == NSTextAlignmentCenter)
            lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, 1);
        else
            lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, 1);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, lineRect);
    }
}

/**
 *  @author CC, 2015-07-31
 *
 *  @brief  设置下划线
 *
 *  @param strikeThroughEnabled <#strikeThroughEnabled description#>
 *
 *  @since 1.0
 */
- (void)setStrikeThroughEnabled:(BOOL)strikeThroughEnabled {
    
    _strikeThroughEnabled = strikeThroughEnabled;
    
    NSString *tempText = [self.text copy];
    self.text = @"";
    self.text = tempText;
}

#pragma mark - 文字颜色与大小
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (!_strikeThroughEnabled) {
        if (_attString) {
            CGContextRef context = UIGraphicsGetCurrentContext();//注，像许多低级别的API，核心文本使用的Y翻转坐标系 更杯具的是，内容是也渲染的翻转向下！
            //手动翻转,注，每次使用可将下面三句话复制粘贴过去。必用
            CGContextSetTextMatrix(context, CGAffineTransformIdentity);
            CGContextTranslateCTM(context, 0, self.bounds.size.height);
            CGContextScaleCTM(context, 1.0, -1.0);
            
            CGMutablePathRef path = CGPathCreateMutable();//1,外边框。mac支持矩形和圆，ios仅支持矩形。本例中使用self.bounds作为path的reference
            CGPathAddRect(path, NULL, self.bounds);
            
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_attString);//3CTFramesetter是最重要的类时使用的绘图核心文本。管理您的字体引用和绘制文本框。就目前而言，你需要知道什么是CTFramesetterCreateWithAttributedString为您将创建一个CTFramesetter的，保留它，并使用附带的属性字符串初始化。在本节中，你有framesetter后你创建一个框架，你给CTFramesetterCreateFrame，呈现了一系列的字符串（我们选择这里的整个字符串）和矩形绘制文本时会出现。
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_attString length]), path, NULL);
            CTFrameDraw(frame, context);//4绘制
            
            CFRelease(frame);//5
            CFRelease(path);
            CFRelease(framesetter);
        }
    }
}


@end
