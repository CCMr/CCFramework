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
#import "CCTextAttachment.h"
#include <objc/runtime.h>

@interface CCTeletTextLabel ()

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
    self.userInteractionEnabled = YES;

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    for (NSString *replaceStr in replaceAry)
        text = [attributedString.string stringByReplacingOccurrencesOfString:replaceStr withString:OBJECT_REPLACEMENT_CHARACTER];

    attributedString = [[NSMutableAttributedString alloc] initWithString:text];

    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:OBJECT_REPLACEMENT_CHARACTER options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    NSMutableSet *teletextAttachments = [NSMutableSet new];

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

        CCLink *link = [[CCLink alloc] init];
        link.linkURL = path;
        link.linkValue = [replaceAry objectAtIndex:i];
        link.linkSize = size;
        link.linkRange = [match range];
        if (!emojiImage)
            emojiImage = defalutImage;

        link.linkImage = emojiImage;

        if ([path rangeOfString:@"http://"].location != NSNotFound)
            [teletextAttachments addObject:link];

        NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:[CCTextAttachment initAttachmentWihtLink:link]];
        [attributedString replaceCharactersInRange:[match range]
                              withAttributedString:rep];
    }

    self.attributedText = attributedString;

    for (CCLink *link in teletextAttachments)
        [self downLoadImage:link];
}

- (void)downLoadImage:(CCLink *)link
{
    __weak __typeof(self) wself = self;
    [SDWebImageManager.sharedManager downloadImageWithURL:[NSURL URLWithString:link.linkURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {

    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        link.linkImage = image;
        [wself replaceImage:link];
    }];
}

- (void)replaceImage:(CCLink *)link
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];

    CGSize linkSize = link.linkSize;
    linkSize = CGSizeMake(link.linkImage.size.width < linkSize.width ? link.linkImage.size.width : linkSize.width, link.linkImage.size.height < linkSize.height ? link.linkImage.size.height : linkSize.height);
    link.linkSize = linkSize;

    NSAttributedString *rep = [NSAttributedString attributedStringWithAttachment:[CCTextAttachment initAttachmentWihtLink:link]];

    [attributedString replaceCharactersInRange:link.linkRange withAttributedString:rep];
    self.attributedText = attributedString;
    [self setNeedsDisplay];
}

#pragma mark :.

- (CGAffineTransform)cc_transformForCoreText
{
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bounds)), 1.f, -1.f);
}

- (CGRect)cc_getLineBounds:(CTLineRef)line point:(CGPoint)point
{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width =
    (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;

    return CGRectMake(point.x, point.y - descent, width, height);
}

- (CCLink *)linkAtPoint:(CGPoint)location
{
    // 创建CTFramesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    // 这里你需要创建一个用于绘制文本的路径区域,通过 self.bounds 使用整个视图矩形区域创建 CGPath 引用。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);

    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    CFRelease(path);


    CFArrayRef lines = CTFrameGetLines(frameRef);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);

    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);

        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);

            CCTextAttachment *attachment = [runAttributes objectForKey:@"NSAttachment"];
            if (attachment) {
                CGRect imgRect = attachment.imageBounds;
                CGRect rect = CGRectApplyAffineTransform(imgRect, [self cc_transformForCoreText]);
                if (CGRectContainsPoint(rect, location)) {
                    return attachment.link;
                }
            }
        }
    }

    return nil;
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

        if (![self.activeLink
              isEqual:[self linkAtPoint:[touch locationInView:self]]])
            self.activeLink = nil;
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        if (self.didClickLinkBlock)
            self.didClickLinkBlock(self, [self.activeLink cc_keyValues]);
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
