//
//  CCTeletTextLabel.m
//  CCFramework
//
//  Created by CC on 16/7/11.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCTeletTextLabel.h"
#import "SDWebImageManager.h"
#import "CCLink.h"
#include <objc/runtime.h>

@interface CCTeletTextLabel ()

@property(nonatomic, strong) NSMutableSet *teletextAttachments;
@property(nonatomic, strong) CCLink *activeLink;

@end

@implementation CCTeletTextLabel


/**
 *  @author CC, 16-07-11
 *
 *  @brief  图文混排
 *
 *  @param text         文本内容
 *  @param DefaultImage 默认图片
 *  @param replaceAry   替换标签
 *  @param teletextPath 图片地址
 *  @param teletextSize 图片大小
 *                      命名规则 @[@{ @"width" : 20, @"height" : 20}]
 */
- (void)coreTeletext:(NSString *)text
        DefaultImage:(UIImage *)defalutImage
          ReplaceAry:(NSArray<NSString *> *)replaceAry
        TeletextPath:(NSArray<NSString *> *)teletextPath
        teletextSize:(NSArray<NSDictionary *> *)teletextSize
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    for (NSString *replaceStr in replaceAry)
        text = [attributedString.string stringByReplacingOccurrencesOfString:replaceStr withString:OBJECT_REPLACEMENT_CHARACTER];

    attributedString = [[NSMutableAttributedString alloc] initWithString:text];

    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:OBJECT_REPLACEMENT_CHARACTER options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];


    for (int i = 0; i < resultArray.count; i++) {
        NSDictionary *sizeDic = [teletextSize objectAtIndex:i];
        NSTextCheckingResult *match = [resultArray objectAtIndex:i];

        NSString *path = @"";
        if (teletextPath.count && i < teletextPath.count)
            path = [teletextPath objectAtIndex:i];

        CGSize size = CGSizeMake([[sizeDic objectForKey:@"width"] integerValue], [[sizeDic objectForKey:@"height"] integerValue]);
        UIImage *emojiImage = [UIImage imageWithContentsOfFile:path];
        if (emojiImage)
            size = CGSizeMake(emojiImage.size.width < size.width ? emojiImage.size.width : size.width, emojiImage.size.height < size.height ? emojiImage.size.height : size.height);

        if (!emojiImage) {
            emojiImage = defalutImage;

            if ([path rangeOfString:@"http://"].location != NSNotFound) {
                [self.teletextAttachments addObject:[CCLink lintWith:path
                                                           LinkValue:path
                                                           LinkRange:[match range]
                                                           LinkWidth:size.width
                                                          LinkHeight:size.height]];
            }
        }

        NSTextAttachment *textAttachment = [NSTextAttachment new];
        textAttachment.image = emojiImage;
        textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);

        NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString replaceCharactersInRange:[match range] withAttributedString:rep];
    }

    self.attributedText = attributedString;

    for (CCLink *link in self.teletextAttachments)
        [self downLoadImage:link];
}

- (void)downLoadImage:(CCLink *)link
{
    __weak __typeof(self) wself = self;
    [SDWebImageManager.sharedManager downloadImageWithURL:link.linkURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {

    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [wself replaceImage:image
                      Range:link.linkRange
                       Size:CGSizeMake(link.linkWidth,link.linkHeight)];
    }];
}

- (void)replaceImage:(UIImage *)image
               Range:(NSRange)range
                Size:(CGSize)size
{
    NSTextAttachment *textAttachment = [NSTextAttachment new];
    textAttachment.image = image;
    textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];

    NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString replaceCharactersInRange:range withAttributedString:rep];

    self.attributedText = attributedString;
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];

    [self.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSTextAttachment *value, NSRange range, BOOL * _Nonnull stop) {
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {

        }
    }];
}

- (NSMutableSet *)teletextAttachments
{
    if (!_teletextAttachments) {
        _teletextAttachments = [NSMutableSet new];
    }
    return _teletextAttachments;
}

#pragma mark :.


- (CCLink *)linkAtPoint:(CGPoint)location
{
    if (self.teletextAttachments.count <= 0 || self.text.length == 0) {
        return nil;
    }

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);

    CGMutablePathRef Path = CGPathCreateMutable();

    CGPathAddRect(Path, NULL, self.bounds);

    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);

    CFArrayRef lines = CTFrameGetLines(frame);

    if (!lines) {
        return NO;
    }

    CFIndex count = CFArrayGetCount(lines);

    CGPoint origins[count];

    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);

    CGAffineTransform transform = [self cc_transformForCoreText];

    CGFloat verticalOffset = 0;

    for (CFIndex i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];

        CTLineRef line = CFArrayGetValueAtIndex(lines, i);

        CGRect flippedRect = [self cc_getLineBounds:line point:linePoint];

        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);

        rect = CGRectInset(rect, 0, 0);

        rect = CGRectOffset(rect, 0, verticalOffset);

        if (CGRectContainsPoint(rect, location)) {

            CGPoint relativePoint = CGPointMake(location.x - CGRectGetMinX(rect), location.y - CGRectGetMinY(rect));

            CFIndex index = CTLineGetStringIndexForPosition(line, relativePoint);

            CGFloat offset;

            CTLineGetOffsetForStringIndex(line, index, &offset);

            if (offset > relativePoint.x)
                index = index - 1;

            for (CCLink *link in self.teletextAttachments) {
                if (NSLocationInRange(index, link.linkRange)) {
                    NSLog(@"%d",index);
                    return link;
                }
            }
        }
    }

    return nil;
}

- (CGAffineTransform)cc_transformForCoreText
{
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
}

- (CGRect)cc_getLineBounds:(CTLineRef)line point:(CGPoint)point
{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;

    return CGRectMake(point.x, point.y - descent, width, height);
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.activeLink = [self linkAtPoint:[touch locationInView:self]];

    if (!self.activeLink)
        [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        UITouch *touch = [touches anyObject];

        if (![self.activeLink isEqual:[self linkAtPoint:[touch locationInView:self]]])
            self.activeLink = nil;
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        NSString *linkText = [self.text substringWithRange:self.activeLink.linkRange];
        if (self.didClickLinkBlock) {
            self.didClickLinkBlock(self.activeLink, linkText, self);
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        self.activeLink = nil;
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}


@end
