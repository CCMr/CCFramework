//
//  NSMutableAttributedString+Image.m
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "NSMutableAttributedString+Image.h"
#import "CCTeletTextImage.h"

// 图片与文字上下左右的间距
#define imageInset UIEdgeInsetsMake(0.f, 1.f, 0.f, 1.f)

@implementation NSMutableAttributedString (Image)

/**
 * 获取图片的Ascent
 * height = ascent + descent
 */
static CGFloat ascentCallback(void *ref)
{
    // 1.获取imageData
    CCTeletTextImage *imageData = (__bridge CCTeletTextImage *)ref;

    // 2.获取图片的高度
    CGFloat imageHeight = attributedImageSize(imageData).height;

    // 3.获取图片对应占位属性字符串的Ascent和Descent
    CGFloat fontAscent = CTFontGetAscent(imageData.fontRef);
    CGFloat fontDescent = CTFontGetDescent(imageData.fontRef);

    // 4.计算基线->Ascent和Descent分割线
    CGFloat baseLine = (fontAscent + fontDescent) / 2.f - fontDescent;

    // 5.获得正确的Ascent
    return imageHeight / 2.f + baseLine;
}

/**
 * 获取图片的Descent
 * height = ascent + descent
 */
static CGFloat descentCallback(void *ref)
{
    // 1.获取imageData
    CCTeletTextImage *imageData = (__bridge CCTeletTextImage *)ref;

    // 2.获取图片的高度
    CGFloat imageHeight = attributedImageSize(imageData).height;

    // 3.获取图片对应占位属性字符串的Ascent和Descent
    CGFloat fontAscent = CTFontGetAscent(imageData.fontRef);
    CGFloat fontDescent = CTFontGetDescent(imageData.fontRef);

    // 4.计算基线->Ascent和Descent分割线
    CGFloat baseLine = (fontAscent + fontDescent) / 2.f - fontDescent;

    // 5.获得正确的Ascent
    return imageHeight / 2.f - baseLine;
}

/**
 * 获取图片的宽度
 */
static CGFloat widthCallback(void *ref)
{
    // 1.获取imageData
    CCTeletTextImage *imageData = (__bridge CCTeletTextImage *)ref;
    // 2.获取图片宽度
    return attributedImageSize(imageData).width;
}

/**
 * 获取占位图片的最终大小
 */
static CGSize attributedImageSize(CCTeletTextImage *imageData)
{
    CGFloat width = imageData.imageSize.width + imageData.imageInsets.left + imageData.imageInsets.right;
    CGFloat height = imageData.imageSize.height + imageData.imageInsets.top + imageData.imageInsets.bottom;
    return CGSizeMake(width, height);
}

/**
 * 获取图片占位的属性字符串
 */
+ (NSAttributedString *)attributedStringWithImageData:(CCTeletTextImage *)imageData
{
    // 1.设置runDelegate的回调信息
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;

    // 2.创建CTRun回调
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(imageData));

    // 3.使用 0xFFFC 作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *string = [NSString stringWithCharacters:&objectReplacementChar length:1];

    // 4.初始化占位符空属性字符串
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:string];

    // 5.设置占位符空属性字符串的kCTRunDelegateAttributeName
    [attString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];

    // 6.释放
    CFRelease(runDelegate);

    return attString;
}

- (NSArray *)analysisImage:(UIFont *)font
              ReplaceLabel:(NSArray<NSString *> *)replaceLabel
               ReplacePath:(NSArray<NSString *> *)replacePath
               ReplaceSize:(NSArray<NSDictionary *> *)replaceSize
                AdjustType:(NSArray *)adjustType
{
    NSString *text = self.string;

    unichar objectReplacementChar = 0xFFFC;
    NSString *string = [NSString stringWithCharacters:&objectReplacementChar length:1];

    for (NSString *replaceStr in replaceLabel)
        text = [text stringByReplacingOccurrencesOfString:replaceStr withString:string];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:string options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];


    NSMutableArray *imageArray = [NSMutableArray array];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    for (int i = 0; i < resultArray.count; i++) {
        NSDictionary *sizeDic = [replaceSize objectAtIndex:i];
        NSTextCheckingResult *match = [resultArray objectAtIndex:i];

        NSString *path = @"";
        if (replacePath.count && i < replacePath.count)
            path = [replacePath objectAtIndex:i];

        CGSize size = CGSizeMake([[sizeDic objectForKey:@"width"] integerValue], [[sizeDic objectForKey:@"height"] integerValue]);
        UIImage *emojiImage = [UIImage imageWithContentsOfFile:path];
        if (emojiImage)
            size = CGSizeMake(emojiImage.size.width < size.width ? emojiImage.size.width : size.width, emojiImage.size.height < size.height ? emojiImage.size.height : size.height);

        CCTeletTextImage *imageData = [CCTeletTextImage new];
        imageData.fontRef = fontRef;
        imageData.adjustType = [[adjustType objectAtIndex:i] integerValue];
        imageData.imageInsets = imageInset;
        imageData.imagePath = path;
        imageData.imageSize = size;
        imageData.imageLabel = [replaceLabel objectAtIndex:i];
        NSRange range = match.range;
        imageData.position = range.location;
        imageData.imageType = CCImagePNGTppe;
        if (!emojiImage)
            imageData.imageType = CCImageURLType;

//        if (adjustType != 0)
//            [imageData setURLImageSize];

        [imageArray addObject:imageData];

        NSAttributedString *attSring = [NSMutableAttributedString attributedStringWithImageData:imageData];
        range.length = imageData.imageLabel.length;
        [self replaceCharactersInRange:range withAttributedString:attSring];
    }
    return imageArray;
}

@end
