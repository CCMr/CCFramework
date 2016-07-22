//
//  CCTeletTextLabel+Utils.m
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCTeletTextLabel+Utils.h"
#import "NSMutableAttributedString+FrameRef.h"
#import "CCTeletTextLink.h"
#import "CCTeletTextImage.h"

@implementation CCTeletTextLabel (Utils)
@dynamic frameRef;
@dynamic linkArr;
@dynamic imageArr;

/**
 * 检测点击位置是否在链接上
 * ->若在链接上，返回CCTeletTextLink
 *   包含超文本内容和range
 * ->如果没点中反回nil
 */
- (CCTeletTextLink *)touchLinkWithPosition:(CGPoint)position
{
    // 0.判断linkArr是否有值
    if (!self.linkArr || !self.linkArr.count) return nil;

    // 1.获取点击位置转换成字符串的偏移量，如果没有找到，则返回-1
    CFIndex index = [self touchPosition:position];

    // 2.如果没找到对应的索引，直接返回nil
    if (index == -1) return nil;

    // 3.返回被选中的链接所对应的数据模型，如果没选中SXTAttributedLink为nil
    return [self linkAtIndex:index];
}

/**
 * 获取点击位置转换成字符串的偏移量，如果没有找到，则返回-1
 */
- (CFIndex)touchPosition:(CGPoint)position
{
    // 1.获取LineRef的行数
    CFArrayRef lines = CTFrameGetLines(self.frameRef);

    // 2.若lines不存在，返回－1
    if (!lines) return -1;

    // 3.获取lineRef的个数
    CFIndex lineCount = CFArrayGetCount(lines);

    // 4.准备旋转用的transform
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);

    // 5.获取每一行的位置的数组
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);

    // 6.遍历lines，处理每一行可能会对应的偏移值索引
    NSInteger index = -1;
    for (CFIndex idx = 0; idx < lineCount; idx++) {
        // 6.1获取每一行的lineRef
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, idx);
        // 6.2获取每一行的rect
        CGRect flippedRect = CTLineGetTypographicBoundsAsRect(lineRef, lineOrigins[idx]);
        // 6.3翻转坐标系
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);

        // 6.4判断点中的点是否在这一行中
        if (CGRectContainsPoint(rect, position)) {
            // 6.5将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(position.x - CGRectGetMinX(rect),
                                                position.y - CGRectGetMinY(rect));
            // 6.6获取点击位置所处的字符位置，就是相当于点击了第几个字符
            index = CTLineGetStringIndexForPosition(lineRef, relativePoint);
        }
    }
    
    return index;
}

/**
 * 监测点击的位置是否在图片上
 * ->若在链接上，返回CCTeletTextImage
 * ->如果没点中反回nil
 */
- (CCTeletTextImage *)touchContentOffWithPosition:(CGPoint)position
{
    // 1.获取LineRef的行数
    CFArrayRef lines = CTFrameGetLines(self.frameRef);

    // 2.若lines不存在，返回－1
    if (!lines) return nil;

    // 3.获取lineRef的个数
    CFIndex lineCount = CFArrayGetCount(lines);

    // 4.准备旋转用的transform
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, self.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);

    // 5.获取每一行的位置的数组
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.frameRef, CFRangeMake(0, 0), lineOrigins);

    // 6.遍历lines，处理每一行可能会对应的偏移值索引
    NSInteger index = -1;
    for (CFIndex idx = 0; idx < lineCount; idx++) {
        // 6.1获取每一行的lineRef
        CTLineRef lineRef = CFArrayGetValueAtIndex(lines, idx);
        CFArrayRef runs = CTLineGetGlyphRuns(lineRef);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CTRunRef runRef = CFArrayGetValueAtIndex(runs, j);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(runRef);
            // 3.2.3获取对应runRef的CTRunDelegateRef
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            // 3.2.3如果不存在，直接退出本次遍历
            // ->证明不是图片，因为我们只给图片设置了CTRunDelegateRef
            if (nil == delegate) continue;

            CCTeletTextImage *imageData = (CCTeletTextImage *)CTRunDelegateGetRefCon(delegate);
            CGRect imgRect = imageData.imageRect;
            CGRect rect = CGRectApplyAffineTransform(imgRect, transform);
            if (CGRectContainsPoint(rect, position)) {
                return imageData;
            }
        }
    }
    return nil;
}


/**
 * 返回被选中的链接所对应的数据模型
 * 如果没选中SXTAttributedLink为nil
 */
- (CCTeletTextLink *)linkAtIndex:(CFIndex)index
{
    CCTeletTextLink *link = nil;

    for (CCTeletTextLink *linkData in self.linkArr) {
        // 如果index在data.range中，这证明点中链接
        if (NSLocationInRange(index, linkData.linkRange)) {
            link = linkData;
            break;
        }
    }
    return link;
}


@end
