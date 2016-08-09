//
//  CCTeletTextLabel.m
//  CCFramework
//
//  Created by CC on 16/7/11.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCTeletTextLabel.h"
#import "NSMutableAttributedString+Image.h"
#import "NSMutableAttributedString+FrameRef.h"
#import "NSMutableAttributedString+Link.h"
#import "NSMutableAttributedString+Attribute.h"
#import "CCTeletTextLabel+Utils.h"
#import "CCTeletTextLabel+Draw.h"

#import "CCTeletTextLink.h"
#import "CCTeletTextImage.h"


#define REGULAREXPRESSION_OPTION(regularExpression, regex, option)                                                                        \
\
static NSRegularExpression *k##regularExpression()                                                                                       \
{                                                                                                                                        \
static NSRegularExpression *_##regularExpression = nil;                                                                                 \
static dispatch_once_t onceToken;                                                                                                       \
dispatch_once(&onceToken, ^{ _##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex)options:(option)error:nil]; }); \
\
return _##regularExpression;                                                                                                            \
}

#define REGULAREXPRESSION(regularExpression, regex) REGULAREXPRESSION_OPTION(regularExpression, regex, NSRegularExpressionCaseInsensitive)

REGULAREXPRESSION(URLRegularExpression, @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)")
REGULAREXPRESSION(PhoneNumerRegularExpression, @"^1[3|4|5|7|8][0-9]\\d{8}$")
REGULAREXPRESSION(TelephoneNumber, @"^(\\d{3,4}-)\\d{7,8}$")
REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")
REGULAREXPRESSION(UserHandleRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+")
REGULAREXPRESSION(HashtagRegularExpression, @"#([\\u4e00-\\u9fa5\\w\\-]+)")


#define kDefaultLinkColorForMLLinkLabel [UIColor colorWithRed:0.061 green:0.515 blue:0.862 alpha:1.000]
#define kDefaultActiveLinkBackgroundColorForMLLinkLabel [UIColor colorWithWhite:0.215 alpha:0.300]


#import "SDWebImageManager.h"
#import "CCLink.h"
#import "CCTextAttachment.h"
#include <objc/runtime.h>

@interface CCTeletTextLabel ()

@property(nonatomic, strong) NSArray *imageArr;
@property(nonatomic, strong) NSArray *linkArr;
@property(nonatomic, assign) CTFrameRef frameRef;

@property(nonatomic, copy) didClickLinkBlock didClickLinkBlock;
@property(nonatomic, strong) CCTeletTextLink *activeLink;
@property(nonatomic, strong) CCTeletTextImage *activeImage;

@property(nonatomic, strong) NSMutableAttributedString *mutableAttributedText;
@property(nonatomic, strong) NSMutableArray *teletextAttachments;

@end

@implementation CCTeletTextLabel

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialization];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.font = [UIFont systemFontOfSize:16];
    self.textColor = [UIColor blackColor];
    self.adjustType = ImageAdjustTypeDefault;
    self.highlightColor = [UIColor lightGrayColor];
}

- (void)setText:(NSString *)text
{
    NSAttributedString *attString = [NSMutableAttributedString attributedString:text textColor:self.textColor font:self.font];
    [self setAttributedText:attString];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    self.mutableAttributedText = [attributedText mutableCopy];

    if (!self.replaceAdjustType) {
        NSMutableArray *adArray = [NSMutableArray array];
        for (NSInteger i = 0; i < self.replaceLabel.count; i++)
            [adArray addObject:@(self.adjustType)];
        self.replaceAdjustType = adArray;
    }

    self.imageArr = [self.mutableAttributedText analysisImage:self.font
                                                 ReplaceLabel:self.replaceLabel
                                                  ReplacePath:self.replacePath
                                                  ReplaceSize:self.replaceSize
                                                   AdjustType:self.replaceAdjustType];
    [self analysisLinks];
    self.size = [self.mutableAttributedText sizeWithWidth:self.width
                                            numberOfLines:self.numberOfLines];
    [self setNeedsDisplay];
}

#pragma mark -
#pragma mark 设置属性
- (void)setFont:(UIFont *)font
{
    _font = font;
    _linkFont = font;

    // 设置属性字体
    [self.mutableAttributedText setFont:font];
    // 刷新
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    _linkColor = textColor;

    // 设置颜色
    [self.mutableAttributedText setTextColor:textColor];
    // 刷新
    [self setNeedsDisplay];
}

- (void)setLinkFont:(UIFont *)linkFont
{
    _linkFont = linkFont;

    // 设置超文本字体
    [self.mutableAttributedText setFont:linkFont links:self.linkArr];
}

- (void)setLinkColor:(UIColor *)linkColor
{
    _linkColor = linkColor;

    // 设置超文本颜色
    [self.mutableAttributedText setTextColor:linkColor links:self.linkArr];
}

#pragma mark -
#pragma mark 根据文本计算size大小
- (CGSize)sizeThatFits:(CGSize)size
{
    // 根据文本计算size大小
    CGSize newSize = [self.mutableAttributedText sizeWithWidth:size.width numberOfLines:self.numberOfLines];

    // 返回自适应的size
    return newSize;
}

#pragma mark - 正则匹配相关
static NSArray *kAllRegexps()
{
    static NSArray *_allRegexps = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _allRegexps = @[kURLRegularExpression(),kTelephoneNumber(),kPhoneNumerRegularExpression(),kEmailRegularExpression(),kUserHandleRegularExpression(),kHashtagRegularExpression()];
    });
    return _allRegexps;
}

- (NSArray *)regexpsWithDataDetectorTypes:(MLDataDetectorTypes)dataDetectorTypes
{
    CCDataDetectorTypes const allDataDetectorTypes[] = {CCDataDetectorTypeURL, CCDataDetectorTypePhoneNumber, CCDataDetectorTypeEmail, CCDataDetectorTypeUserHandle, CCDataDetectorTypeHashtag};
    NSArray *allRegexps = kAllRegexps();

    NSMutableArray *regexps = [NSMutableArray array];
    for (NSInteger i = 0; i < allRegexps.count; i++) {
        if (dataDetectorTypes & (allDataDetectorTypes[i])) {
            [regexps addObject:allRegexps[i]];
        }
    }
    return regexps.count > 0 ? regexps : nil;
}

//根据dataDetectorTypes和string获取其linkType
- (CCLinkType)linkTypeOfString:(NSString *)string withDataDetectorTypes:(CCDataDetectorTypes)dataDetectorTypes
{
    if (dataDetectorTypes == CCDataDetectorTypeNone) {
        return CCLinkTypeOther;
    }

    NSArray *allRegexps = kAllRegexps();
    NSArray *regexps = [self regexpsWithDataDetectorTypes:dataDetectorTypes];

    NSRange textRange = NSMakeRange(0, string.length);
    for (NSRegularExpression *regexp in regexps) {
        NSTextCheckingResult *result = [regexp firstMatchInString:string options:NSMatchingAnchored range:textRange];
        if (result && NSEqualRanges(result.range, textRange)) {
            //这个type确定
            CCLinkType linkType = [allRegexps indexOfObject:regexp] + 1;
            return linkType;
        }
    }

    return CCLinkTypeOther;
}

- (void)analysisLinks
{
    if (self.dataDetectorTypes == CCDataDetectorTypeNone || !self.mutableAttributedText.string)
        return;

    NSString *plainText = self.mutableAttributedText.string;
    if (plainText.length <= 0)
        return;

    NSMutableArray *links = [NSMutableArray array];
    if (self.dataDetectorTypes & CCDataDetectorTypeAttributedLink)
        [links addObjectsFromArray:[self.mutableAttributedText analysisLinkColor:kDefaultLinkColorForMLLinkLabel linkFont:self.font]];

    [links addObjectsFromArray:[self.mutableAttributedText analysisLinkRegexps:kAllRegexps() Regexps:[self regexpsWithDataDetectorTypes:self.dataDetectorTypes] Links:links]];

    self.linkArr = links.count > 0 ? links : nil;
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect
{
    // 1.获取图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 2.翻转坐标系
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.size.height), 1.f, -1.f);
    CGContextConcatCTM(context, transform);

    self.frameRef = [self.mutableAttributedText prepareFrameRefWithRect:rect];

    [self drawHighlightedColor];
    [self frameLineDraw];
    [self drawImages];
}

#pragma mark -
#pragma mark 触摸事件响应

- (void)didClickLinkBlock:(didClickLinkBlock)linkBlock
{
    self.userInteractionEnabled = YES;
    self.didClickLinkBlock = linkBlock;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint position = [[touches anyObject] locationInView:self];

    self.activeLink = [self touchLinkWithPosition:position];

    self.activeImage = [self touchContentOffWithPosition:position];

    if (!self.activeLink && !self.activeImage)
        [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink) {
        UITouch *touch = [touches anyObject];
        CGPoint position = [[touches anyObject] locationInView:self];

        if (![self.activeLink isEqual:[self touchLinkWithPosition:position]])
            self.activeLink = nil;

        if (![self.activeImage isEqual:[self touchContentOffWithPosition:position]])
            self.activeImage = nil;
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink || self.activeImage) {
        if (self.didClickLinkBlock) {

            if (self.activeLink)
                self.didClickLinkBlock(self, @{ @"linkValue" : self.activeLink.text });
            else if (self.activeImage) {
                NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
                [eventDic setObject:self.activeImage.imagePath forKey:@"imagePath"];
                [eventDic setObject:self.activeImage.imageLabel forKey:@"imageLabel"];
                [eventDic setObject:self.activeImage.image forKey:@"image"];
                [eventDic setObject:NSStringFromCGSize(self.activeImage.imageSize) forKey:@"imageSize"];
                [eventDic setObject:self.activeImage.imageView forKeyedSubscript:@"imageView"];
                self.didClickLinkBlock(self, eventDic);
            }
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.activeLink || self.activeImage) {
        self.activeLink = nil;
        self.activeImage = nil;
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}


@end
