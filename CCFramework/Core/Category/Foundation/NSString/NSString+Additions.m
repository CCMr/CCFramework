//
//  NSString+BNSString.m
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

#import "NSString+Additions.h"
#import <objc/runtime.h>
#import "CCBase64.h"
#import "QRCodeGenerator.h"
#import "NSData+Additions.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>


@interface NSString (RubyPrivate)

NSString *_stringRepresentationOf(id<Concatenatable> object);
- (NSString *)_delete:(NSString *)first remaining:(va_list)args;

@end

@implementation NSString (Additions)

/**
 *  @brief  获取随机 UUID 例如 E621E1F8-C36C-495A-93FC-0C247A3E6E5F
 *
 *  @return 随机 UUID
 */
+ (NSString *)UUID
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.0) {
        return [[NSUUID UUID] UUIDString];
    } else {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuid = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        return (__bridge_transfer NSString *)uuid;
    }
}

/**
 *
 *  @brief  毫秒时间戳 例如 1443066826371
 *
 *  @return 毫秒时间戳
 */
+ (NSString *)UUIDTimestamp
{
    return [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] stringValue];
}

/**
 *  @author CC, 2015-12-11
 *  
 *  @brief  根据值生成唯一ID
 */
- (NSString *)pathForTemporaryFileWithPrefix
{
    NSString *result;
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", self, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}


/**
 *  @brief  JSON字符串转成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryValue
{
    NSError *errorJson;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&errorJson];
    if (errorJson != nil) {
#ifdef DEBUG
        NSLog(@"fail to get dictioanry from JSON: %@, error: %@", self, errorJson);
#endif
    }
    return jsonDict;
}

#pragma mark-
#pragma mark :. QueryDictionary

- (NSDictionary *)cc_URLQueryDictionary
{
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [self componentsSeparatedByString:@"&"]) {
        NSArray *components = [query componentsSeparatedByString:@"="];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = nil;
        if (components.count == 1) {
            // key with no value
            value = [NSNull null];
        }
        if (components.count == 2) {
            value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // cover case where there is a separator, but no actual value
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2) {
            // invalid - ignore this pair. is this best, though?
            continue;
        }
        mute[key] = value ?: [NSNull null];
    }
    return mute.count ? mute.copy : nil;
}


#pragma mark-
#pragma mark :. XML

/**
 *  @brief  xml字符串转换成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryFromXML
{
    //TURN THE STRING INTO DATA
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    //INTIALIZE NECESSARY HELPER VARIABLES
    self.currentDictionaries = [[NSMutableArray alloc] init];
    self.currentText = [[NSMutableString alloc] init];
    
    //INITIALIZE WITH A DICTIONARY TO START WITH
    [self.currentDictionaries addObject:[NSMutableDictionary dictionary]];
    
    //DO PARSING
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    //RETURNS
    if (success)
        return [self.currentDictionaries objectAtIndex:0];
    else
        return nil;
}

#pragma mark -
#pragma mark ASSOCIATIVE OVERRIDES

#define ASSOCIATIVE_CURRENT_DICTIONARY_KEY @"ASSOCIATIVE_CURRENT_DICTIONARY_KEY"
#define ASSOCIATIVE_CURRENT_TEXT_KEY @"ASSOCIATIVE_CURRENT_TEXT_KEY"

- (void)setCurrentDictionaries:(NSMutableArray *)currentDictionaries
{
    objc_setAssociatedObject(self, ASSOCIATIVE_CURRENT_DICTIONARY_KEY, currentDictionaries, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableArray *)currentDictionaries
{
    return objc_getAssociatedObject(self, ASSOCIATIVE_CURRENT_DICTIONARY_KEY);
}

- (void)setCurrentText:(NSMutableString *)currentText
{
    objc_setAssociatedObject(self, ASSOCIATIVE_CURRENT_TEXT_KEY, currentText, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableString *)currentText
{
    return objc_getAssociatedObject(self, ASSOCIATIVE_CURRENT_TEXT_KEY);
}

#pragma mark -
#pragma mark NSXMLPARSER DELEGATE

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //GET THE LAST DICTIONARY
    NSMutableDictionary *parent = [self.currentDictionaries lastObject];
    
    //CREATE A NEW DICTIONARY AND SET ALL THE ATTRIBUTES
    NSMutableDictionary *child = [NSMutableDictionary dictionary];
    [child addEntriesFromDictionary:attributeDict];
    
    id currentValue = [parent objectForKey:elementName];
    
    //SHOULD BE AN ARRAY IF WE ALREADY HAVE ONE FOR THIS KEY, OTHERWISE JUST ADD IT IN
    if (currentValue) {
        NSMutableArray *array = nil;
        
        //IF CURRENTVALUE IS ALREADY AN ARRAY USE IT, OTHERWISE, MAKE ONE
        if ([currentValue isKindOfClass:[NSMutableArray class]])
            array = (NSMutableArray *)currentValue;
        else {
            array = [NSMutableArray array];
            [array addObject:currentValue];
            
            //REPLACE DICTIONARY WITH ARRAY IN PARENT
            [parent setObject:array forKey:elementName];
        }
        
        [array addObject:child];
    } else
        [parent setObject:child forKey:elementName];
    
    //ADD NEW OBJECT
    [self.currentDictionaries addObject:child];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //UPDATE PARENT INFO
    NSMutableDictionary *dictInProgress = [self.currentDictionaries lastObject];
    
    if ([self.currentText length] > 0) {
        //REMOVE WHITE SPACE
        [dictInProgress setObject:self.currentText forKey:@"text"];
        
        self.currentText = nil;
        self.currentText = [[NSMutableString alloc] init];
    }
    
    //NO LONGER NEED THIS DICTIONARY, AS WE'RE DONE WITH IT
    [self.currentDictionaries removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    //WILL RETURN NIL FOR ERROR
}


#pragma mark--- 转换

/**
 *  @author CC, 15-09-25
 *
 *  @brief  base64编码
 *
 *  @return 返回编码后的字符串
 */
- (NSString *)encodeBase64String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [CCBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

/**
 *  @author CC, 15-09-25
 *
 *  @brief  base64解码
 *
 *  @return 返回编码后的字符串
 */
- (NSString *)decodeBase64String
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [CCBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

/**
 *  @author CC, 2015-07-21
 *
 *  @brief  字符串转换日期
 *
 *  @param strFormat 字符串格式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)convertingStringsToDate:(NSString *)strFormat
{
    NSDateFormatter *mDateFormatter = [[NSDateFormatter alloc] init];
    [mDateFormatter setDateFormat:strFormat];
    return [mDateFormatter dateFromString:self];
}

/**
 *  @author CC, 2015-12-02
 *  
 *  @brief  字符串转换日期带'T'
 */
- (NSDate *)convertingTStringsToDate
{
    NSDateFormatter *mDateFormatter = [[NSDateFormatter alloc] init];
    [mDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [mDateFormatter dateFromString:self];
    ;
}

/**
 *  @author CC, 2015-07-22
 *
 *  @brief  转换货币格式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)convertingCurrencyFormat
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    //    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    [nf setPositiveFormat:@"###,##0.00;"];
    return [nf stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
}

/**
 *  @author CC, 15-08-27
 *
 *  @brief  字符串解码Image
 *
 *  @return 返回解码之后Image
 *
 *  @since <#1.0#>
 */
- (UIImage *)decodedImage
{
    NSData *datas = [[NSData alloc] initWithBase64Encoding:self];
    return [UIImage imageWithData:datas];
}

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  生成二维码图像
 *
 *  @param width  图像宽
 *  @param height 图像高
 *
 *  @return 二维码图片
 */
- (UIImage *)becomeQRCodeWithQRstring:(float)size
{
    return [QRCodeGenerator qrImageForString:self
                                   imageSize:size];
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  转换Data
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (NSData *)convertingData
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 *  @author CC, 15-09-22
 *
 *  @brief  转换64位字符串
 *
 *  @return 返回转换data
 */
- (NSData *)convertingBase64Encoded
{
    return [[NSData alloc] initWithBase64Encoding:self];
}

/**
 *  @author CC, 15-09-21
 *
 *  @brief  序列化Json
 *
 *  @return 返回对象键值
 */
- (NSDictionary *)serialization
{
    return [NSJSONSerialization JSONObjectWithData:[self convertingData]
                                           options:NSJSONReadingAllowFragments
                                             error:nil];
}

#pragma mark--- 取值
/**
 *  @author CC, 15-08-14
 *
 *  @brief  获取字符串行数
 *
 *  @return 返回行数
 *
 *  @since <#1.0#>
 */
- (NSInteger)numberOfLines
{
    return [[self componentsSeparatedByString:@"\n"] count] + 1;
}

/**
 *  @author C C, 2015-09-28
 *
 *  @brief  计算文字长宽
 *
 *  @return 返回长宽
 */
- (CGSize)calculateTextWidthWidth:(CGFloat)MaxWith
                              Font:(UIFont *)font
{
    return [self sizeWithFont:font
            constrainedToSize:CGSizeMake(MaxWith, MAXFLOAT)
                lineBreakMode:NSLineBreakByWordWrapping];
}

/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                     NSParagraphStyleAttributeName : paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                 NSParagraphStyleAttributeName : paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.height);
}

/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                     NSParagraphStyleAttributeName : paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                 NSParagraphStyleAttributeName : paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.width);
}

/**
 *  @brief 计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                     NSParagraphStyleAttributeName : paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                 NSParagraphStyleAttributeName : paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

/**
 *  @brief 计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                     NSParagraphStyleAttributeName : paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName : textFont,
                                 NSParagraphStyleAttributeName : paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

/**
 *  @brief  反转字符串
 *
 *  @param strSrc 被反转字符串
 *
 *  @return 反转后字符串
 */
+ (NSString *)reverseString:(NSString *)strSrc
{
    NSMutableString *reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [strSrc length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[strSrc substringWithRange:subStrRange]];
    }
    return reverseString;
}

#pragma mark--- 加密
/**
 *  @author CC, 15-08-17
 *
 *  @brief  MD5Hash加密
 *
 *  @return 返回加密字符串
 *
 *  @since 1.0
 */
- (NSString *)MD5Hash
{
    if (self.length == 0) return nil;
    
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5],
            result[6], result[7], result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  MD5 32位加密
 *
 *  @return 返回加密字符串
 *
 *  @since 1.0
 */
- (NSString *)MD532
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return [result copy];
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  SHA加密
 *
 *  @return 返回加密字符串
 *
 *  @since 1.0
 */
- (NSString *)SHA
{
    const char *cStr = [self UTF8String];
    NSData *data = [NSData dataWithBytes:cStr length:self.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *result =
    [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return [result copy];
}

#pragma mark--- 文件
/**
 *  @author CC, 15-08-21
 *
 *  @brief  document根文件夹
 *
 *  @return 返回文件夹路径
 *
 *  @since 1.0
 */
+ (NSString *)documentFolder
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 *  @author CC, 15-08-21
 *
 *  @brief  caches根文件夹
 *
 *  @return 返回文件夹路径
 *
 *  @since 1.0
 */
+ (NSString *)cachesFolder
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 *  @author CC, 15-08-21
 *
 *  @brief 生成子文件夹(如果子文件夹不存在，则直接创建；如果已经存在，则直接返回)
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 返回文件夹路径
 *
 *  @since 1.0
 */
- (NSString *)createSubFolder:(NSString *)subFolder
{
    NSString *subFolderPath = [NSString stringWithFormat:@"%@/%@", self, subFolder];
    
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL existed = [fileManager fileExistsAtPath:subFolderPath isDirectory:&isDir];
    
    if (!(isDir == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:subFolderPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    return subFolderPath;
}

#pragma mark -
#pragma mark :. 处理

/**
 *  @author CC, 2015-10-20
 *
 *  @brief  拼接字符串
 *
 *  @param format 多个参数
 *
 *  @return 返回拼接完成的字符串
 */
- (NSString *)appendFormats:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2)
{
    NSMutableString *mutableString = [NSMutableString string];
    
    if (self)
        mutableString = [NSMutableString stringWithString:self];
    
    if (format) {
        va_list arguments;
        va_start(arguments, format);
        NSString *apS = [[NSString alloc] initWithFormat:format arguments:arguments];
        va_end(arguments);
        
        [mutableString appendString:apS];
    }
    
    return mutableString;
}

/**
 *  @author CC, 2015-10-20
 *
 *  @brief  添加字符串
 *
 *  @param aString 字符喘
 *
 *  @return 返回添加之后的字符串
 */
- (NSString *)appendStrings:(NSString *)aString
{
    NSMutableString *mutableString = [NSMutableString string];
    
    if (self)
        mutableString = [NSMutableString stringWithString:self];
    
    [mutableString appendString:aString];
    
    return mutableString;
}

/**
 *  @brief  清除html标签
 *
 *  @return 清除后的结果
 */
- (NSString *)stringByStrippingHTML
{
    return [self stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

/**
 *  @brief  清除js脚本
 *
 *  @return 清楚js后的结果
 */
- (NSString *)stringByRemovingScriptsAndStrippingHTML
{
    NSMutableString *mString = [self mutableCopy];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>[\\w\\W]*</script>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:mString options:NSMatchingReportProgress range:NSMakeRange(0, [mString length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [mString replaceCharactersInRange:match.range withString:@""];
    }
    return [mString stringByStrippingHTML];
}

/**
 *  @brief  去除空格
 *
 *  @return 去除空格后的字符串
 */
- (NSString *)trimmingWhitespace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/**
 *  @brief  去除字符串与空行
 *
 *  @return 去除字符串与空行的字符串
 */
- (NSString *)trimmingWhitespaceAndNewlines
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 *  @brief  urlEncode
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncode
{
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}

/**
 *  @brief  urlEncode
 *
 *  @param encoding encoding模式
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)self, NULL, (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding));
}

/**
 *  @brief  urlDecode
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecode
{
    return [self urlDecodeUsingEncoding:NSUTF8StringEncoding];
}

/**
 *  @brief  urlDecode
 *
 *  @param encoding encoding模式
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                 (__bridge CFStringRef)self, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(encoding));
}

/**
 *  @brief  url query转成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryFromURLParameters
{
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

#pragma mark -
#pragma mark :. Base64

+ (NSString *)stringWithBase64EncodedString:(NSString *)string
{
    NSData *data = [NSData dataWithBase64EncodedString:string];
    if (data) {
        return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedString];
}

- (NSString *)base64DecodedString
{
    return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData
{
    return [NSData dataWithBase64EncodedString:self];
}

#pragma mark-
#pragma mark :. Contains

/**
 *  @brief  判断URL中是否包含中文
 *
 *  @return 是否包含中文
 */
- (BOOL)isContainChinese
{
    NSUInteger length = [self length];
    for (NSUInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
}

/**
 *  @brief  是否包含空格
 *
 *  @return 是否包含空格
 */
- (BOOL)isContainBlank
{
    NSRange range = [self rangeOfString:@" "];
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

//Unicode编码的字符串转成NSString
- (NSString *)makeUnicodeToString
{
    NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    //NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListMutableContainersAndLeaves format:NULL error:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

- (BOOL)containsCharacterSet:(NSCharacterSet *)set
{
    NSRange rang = [self rangeOfCharacterFromSet:set];
    if (rang.location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}
/**
 *  @brief 是否包含字符串
 *
 *  @param string 字符串
 *
 *  @return YES, 包含; Otherwise
 */
- (BOOL)containsaString:(NSString *)string
{
    NSRange rang = [self rangeOfString:string];
    if (rang.location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

/**
 *  @brief 获取字符数量
 */
- (int)wordsCount
{
    NSInteger n = self.length;
    int i;
    int l = 0, a = 0, b = 0;
    unichar c;
    for (i = 0; i < n; i++) {
        c = [self characterAtIndex:i];
        if (isblank(c)) {
            b++;
        } else if (isascii(c)) {
            a++;
        } else {
            l++;
        }
    }
    if (a == 0 && l == 0) {
        return 0;
    }
    return l + (int)ceilf((float)(a + b) / 2.0);
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  去除所有空格
 *
 *  @return 返回当前字符串
 *
 *  @since 1.0
 */
- (NSString *)deleteSpace
{
    NSMutableString *strM = [NSMutableString stringWithString:self];
    [strM replaceOccurrencesOfString:@" "
                          withString:@""
                             options:NSLiteralSearch
                               range:NSMakeRange(0, strM.length)];
    return strM;
}

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  字符串字节长度
 */
- (NSInteger)byteLength
{
    NSInteger strlength = 0;
    char *p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }
    
    return (strlength + 1) / 2;
}

#pragma mark-
#pragma mark :. Emoji

static NSDictionary *s_unicodeToCheatCodes = nil;
static NSDictionary *s_cheatCodesToUnicode = nil;

+ (void)initializeEmojiCheatCodes
{
    NSDictionary *forwardMap = @{
                                 @"😄" : @":smile:",
                                 @"😆" : @[ @":laughing:", @":D" ],
                                 @"😊" : @":blush:",
                                 @"😃" : @[ @":smiley:", @":)", @":-)" ],
                                 @"☺" : @":relaxed:",
                                 @"😏" : @":smirk:",
                                 @"😞" : @[ @":disappointed:", @":(" ],
                                 @"😍" : @":heart_eyes:",
                                 @"😘" : @":kissing_heart:",
                                 @"😚" : @":kissing_closed_eyes:",
                                 @"😳" : @":flushed:",
                                 @"😥" : @":relieved:",
                                 @"😌" : @":satisfied:",
                                 @"😁" : @":grin:",
                                 @"😉" : @[ @":wink:", @";)", @";-)" ],
                                 @"😜" : @[ @":wink2:", @":P" ],
                                 @"😝" : @":stuck_out_tongue_closed_eyes:",
                                 @"😀" : @":grinning:",
                                 @"😗" : @":kissing:",
                                 @"😙" : @":kissing_smiling_eyes:",
                                 @"😛" : @":stuck_out_tongue:",
                                 @"😴" : @":sleeping:",
                                 @"😟" : @":worried:",
                                 @"😦" : @":frowning:",
                                 @"😧" : @":anguished:",
                                 @"😮" : @[ @":open_mouth:", @":o" ],
                                 @"😬" : @":grimacing:",
                                 @"😕" : @":confused:",
                                 @"😯" : @":hushed:",
                                 @"😑" : @":expressionless:",
                                 @"😒" : @":unamused:",
                                 @"😅" : @":sweat_smile:",
                                 @"😓" : @":sweat:",
                                 @"😩" : @":weary:",
                                 @"😔" : @":pensive:",
                                 @"😞" : @":dissapointed:",
                                 @"😖" : @":confounded:",
                                 @"😨" : @":fearful:",
                                 @"😰" : @":cold_sweat:",
                                 @"😣" : @":persevere:",
                                 @"😢" : @":cry:",
                                 @"😭" : @":sob:",
                                 @"😂" : @":joy:",
                                 @"😲" : @":astonished:",
                                 @"😱" : @":scream:",
                                 @"😫" : @":tired_face:",
                                 @"😠" : @":angry:",
                                 @"😡" : @":rage:",
                                 @"😤" : @":triumph:",
                                 @"😪" : @":sleepy:",
                                 @"😋" : @":yum:",
                                 @"😷" : @":mask:",
                                 @"😎" : @":sunglasses:",
                                 @"😵" : @":dizzy_face:",
                                 @"👿" : @":imp:",
                                 @"😈" : @":smiling_imp:",
                                 @"😐" : @":neutral_face:",
                                 @"😶" : @":no_mouth:",
                                 @"😇" : @":innocent:",
                                 @"👽" : @":alien:",
                                 @"💛" : @":yellow_heart:",
                                 @"💙" : @":blue_heart:",
                                 @"💜" : @":purple_heart:",
                                 @"❤" : @":heart:",
                                 @"💚" : @":green_heart:",
                                 @"💔" : @":broken_heart:",
                                 @"💓" : @":heartbeat:",
                                 @"💗" : @":heartpulse:",
                                 @"💕" : @":two_hearts:",
                                 @"💞" : @":revolving_hearts:",
                                 @"💘" : @":cupid:",
                                 @"💖" : @":sparkling_heart:",
                                 @"✨" : @":sparkles:",
                                 @"⭐️" : @":star:",
                                 @"🌟" : @":star2:",
                                 @"💫" : @":dizzy:",
                                 @"💥" : @":boom:",
                                 @"💢" : @":anger:",
                                 @"❗" : @":exclamation:",
                                 @"❓" : @":question:",
                                 @"❕" : @":grey_exclamation:",
                                 @"❔" : @":grey_question:",
                                 @"💤" : @":zzz:",
                                 @"💨" : @":dash:",
                                 @"💦" : @":sweat_drops:",
                                 @"🎶" : @":notes:",
                                 @"🎵" : @":musical_note:",
                                 @"🔥" : @":fire:",
                                 @"💩" : @[ @":poop:", @":hankey:", @":shit:" ],
                                 @"👍" : @[ @":+1:", @":thumbsup:" ],
                                 @"👎" : @[ @":-1:", @":thumbsdown:" ],
                                 @"👌" : @":ok_hand:",
                                 @"👊" : @":punch:",
                                 @"✊" : @":fist:",
                                 @"✌" : @":v:",
                                 @"👋" : @":wave:",
                                 @"✋" : @":hand:",
                                 @"👐" : @":open_hands:",
                                 @"☝" : @":point_up:",
                                 @"👇" : @":point_down:",
                                 @"👈" : @":point_left:",
                                 @"👉" : @":point_right:",
                                 @"🙌" : @":raised_hands:",
                                 @"🙏" : @":pray:",
                                 @"👆" : @":point_up_2:",
                                 @"👏" : @":clap:",
                                 @"💪" : @":muscle:",
                                 @"🚶" : @":walking:",
                                 @"🏃" : @":runner:",
                                 @"👫" : @":couple:",
                                 @"👪" : @":family:",
                                 @"👬" : @":two_men_holding_hands:",
                                 @"👭" : @":two_women_holding_hands:",
                                 @"💃" : @":dancer:",
                                 @"👯" : @":dancers:",
                                 @"🙆" : @":ok_woman:",
                                 @"🙅" : @":no_good:",
                                 @"💁" : @":information_desk_person:",
                                 @"🙋" : @":raised_hand:",
                                 @"👰" : @":bride_with_veil:",
                                 @"🙎" : @":person_with_pouting_face:",
                                 @"🙍" : @":person_frowning:",
                                 @"🙇" : @":bow:",
                                 @"💏" : @":couplekiss:",
                                 @"💑" : @":couple_with_heart:",
                                 @"💆" : @":massage:",
                                 @"💇" : @":haircut:",
                                 @"💅" : @":nail_care:",
                                 @"👦" : @":boy:",
                                 @"👧" : @":girl:",
                                 @"👩" : @":woman:",
                                 @"👨" : @":man:",
                                 @"👶" : @":baby:",
                                 @"👵" : @":older_woman:",
                                 @"👴" : @":older_man:",
                                 @"👱" : @":person_with_blond_hair:",
                                 @"👲" : @":man_with_gua_pi_mao:",
                                 @"👳" : @":man_with_turban:",
                                 @"👷" : @":construction_worker:",
                                 @"👮" : @":cop:",
                                 @"👼" : @":angel:",
                                 @"👸" : @":princess:",
                                 @"😺" : @":smiley_cat:",
                                 @"😸" : @":smile_cat:",
                                 @"😻" : @":heart_eyes_cat:",
                                 @"😽" : @":kissing_cat:",
                                 @"😼" : @":smirk_cat:",
                                 @"🙀" : @":scream_cat:",
                                 @"😿" : @":crying_cat_face:",
                                 @"😹" : @":joy_cat:",
                                 @"😾" : @":pouting_cat:",
                                 @"👹" : @":japanese_ogre:",
                                 @"👺" : @":japanese_goblin:",
                                 @"🙈" : @":see_no_evil:",
                                 @"🙉" : @":hear_no_evil:",
                                 @"🙊" : @":speak_no_evil:",
                                 @"💂" : @":guardsman:",
                                 @"💀" : @":skull:",
                                 @"👣" : @":feet:",
                                 @"👄" : @":lips:",
                                 @"💋" : @":kiss:",
                                 @"💧" : @":droplet:",
                                 @"👂" : @":ear:",
                                 @"👀" : @":eyes:",
                                 @"👃" : @":nose:",
                                 @"👅" : @":tongue:",
                                 @"💌" : @":love_letter:",
                                 @"👤" : @":bust_in_silhouette:",
                                 @"👥" : @":busts_in_silhouette:",
                                 @"💬" : @":speech_balloon:",
                                 @"💭" : @":thought_balloon:",
                                 @"☀" : @":sunny:",
                                 @"☔" : @":umbrella:",
                                 @"☁" : @":cloud:",
                                 @"❄" : @":snowflake:",
                                 @"⛄" : @":snowman:",
                                 @"⚡" : @":zap:",
                                 @"🌀" : @":cyclone:",
                                 @"🌁" : @":foggy:",
                                 @"🌊" : @":ocean:",
                                 @"🐱" : @":cat:",
                                 @"🐶" : @":dog:",
                                 @"🐭" : @":mouse:",
                                 @"🐹" : @":hamster:",
                                 @"🐰" : @":rabbit:",
                                 @"🐺" : @":wolf:",
                                 @"🐸" : @":frog:",
                                 @"🐯" : @":tiger:",
                                 @"🐨" : @":koala:",
                                 @"🐻" : @":bear:",
                                 @"🐷" : @":pig:",
                                 @"🐽" : @":pig_nose:",
                                 @"🐮" : @":cow:",
                                 @"🐗" : @":boar:",
                                 @"🐵" : @":monkey_face:",
                                 @"🐒" : @":monkey:",
                                 @"🐴" : @":horse:",
                                 @"🐎" : @":racehorse:",
                                 @"🐫" : @":camel:",
                                 @"🐑" : @":sheep:",
                                 @"🐘" : @":elephant:",
                                 @"🐼" : @":panda_face:",
                                 @"🐍" : @":snake:",
                                 @"🐦" : @":bird:",
                                 @"🐤" : @":baby_chick:",
                                 @"🐥" : @":hatched_chick:",
                                 @"🐣" : @":hatching_chick:",
                                 @"🐔" : @":chicken:",
                                 @"🐧" : @":penguin:",
                                 @"🐢" : @":turtle:",
                                 @"🐛" : @":bug:",
                                 @"🐝" : @":honeybee:",
                                 @"🐜" : @":ant:",
                                 @"🐞" : @":beetle:",
                                 @"🐌" : @":snail:",
                                 @"🐙" : @":octopus:",
                                 @"🐠" : @":tropical_fish:",
                                 @"🐟" : @":fish:",
                                 @"🐳" : @":whale:",
                                 @"🐋" : @":whale2:",
                                 @"🐬" : @":dolphin:",
                                 @"🐄" : @":cow2:",
                                 @"🐏" : @":ram:",
                                 @"🐀" : @":rat:",
                                 @"🐃" : @":water_buffalo:",
                                 @"🐅" : @":tiger2:",
                                 @"🐇" : @":rabbit2:",
                                 @"🐉" : @":dragon:",
                                 @"🐐" : @":goat:",
                                 @"🐓" : @":rooster:",
                                 @"🐕" : @":dog2:",
                                 @"🐖" : @":pig2:",
                                 @"🐁" : @":mouse2:",
                                 @"🐂" : @":ox:",
                                 @"🐲" : @":dragon_face:",
                                 @"🐡" : @":blowfish:",
                                 @"🐊" : @":crocodile:",
                                 @"🐪" : @":dromedary_camel:",
                                 @"🐆" : @":leopard:",
                                 @"🐈" : @":cat2:",
                                 @"🐩" : @":poodle:",
                                 @"🐾" : @":paw_prints:",
                                 @"💐" : @":bouquet:",
                                 @"🌸" : @":cherry_blossom:",
                                 @"🌷" : @":tulip:",
                                 @"🍀" : @":four_leaf_clover:",
                                 @"🌹" : @":rose:",
                                 @"🌻" : @":sunflower:",
                                 @"🌺" : @":hibiscus:",
                                 @"🍁" : @":maple_leaf:",
                                 @"🍃" : @":leaves:",
                                 @"🍂" : @":fallen_leaf:",
                                 @"🌿" : @":herb:",
                                 @"🍄" : @":mushroom:",
                                 @"🌵" : @":cactus:",
                                 @"🌴" : @":palm_tree:",
                                 @"🌲" : @":evergreen_tree:",
                                 @"🌳" : @":deciduous_tree:",
                                 @"🌰" : @":chestnut:",
                                 @"🌱" : @":seedling:",
                                 @"🌼" : @":blossum:",
                                 @"🌾" : @":ear_of_rice:",
                                 @"🐚" : @":shell:",
                                 @"🌐" : @":globe_with_meridians:",
                                 @"🌞" : @":sun_with_face:",
                                 @"🌝" : @":full_moon_with_face:",
                                 @"🌚" : @":new_moon_with_face:",
                                 @"🌑" : @":new_moon:",
                                 @"🌒" : @":waxing_crescent_moon:",
                                 @"🌓" : @":first_quarter_moon:",
                                 @"🌔" : @":waxing_gibbous_moon:",
                                 @"🌕" : @":full_moon:",
                                 @"🌖" : @":waning_gibbous_moon:",
                                 @"🌗" : @":last_quarter_moon:",
                                 @"🌘" : @":waning_crescent_moon:",
                                 @"🌜" : @":last_quarter_moon_with_face:",
                                 @"🌛" : @":first_quarter_moon_with_face:",
                                 @"🌙" : @":moon:",
                                 @"🌍" : @":earth_africa:",
                                 @"🌎" : @":earth_americas:",
                                 @"🌏" : @":earth_asia:",
                                 @"🌋" : @":volcano:",
                                 @"🌌" : @":milky_way:",
                                 @"⛅" : @":partly_sunny:",
                                 @"🎍" : @":bamboo:",
                                 @"💝" : @":gift_heart:",
                                 @"🎎" : @":dolls:",
                                 @"🎒" : @":school_satchel:",
                                 @"🎓" : @":mortar_board:",
                                 @"🎏" : @":flags:",
                                 @"🎆" : @":fireworks:",
                                 @"🎇" : @":sparkler:",
                                 @"🎐" : @":wind_chime:",
                                 @"🎑" : @":rice_scene:",
                                 @"🎃" : @":jack_o_lantern:",
                                 @"👻" : @":ghost:",
                                 @"🎅" : @":santa:",
                                 @"🎱" : @":8ball:",
                                 @"⏰" : @":alarm_clock:",
                                 @"🍎" : @":apple:",
                                 @"🎨" : @":art:",
                                 @"🍼" : @":baby_bottle:",
                                 @"🎈" : @":balloon:",
                                 @"🍌" : @":banana:",
                                 @"📊" : @":bar_chart:",
                                 @"⚾" : @":baseball:",
                                 @"🏀" : @":basketball:",
                                 @"🛀" : @":bath:",
                                 @"🛁" : @":bathtub:",
                                 @"🔋" : @":battery:",
                                 @"🍺" : @":beer:",
                                 @"🍻" : @":beers:",
                                 @"🔔" : @":bell:",
                                 @"🍱" : @":bento:",
                                 @"🚴" : @":bicyclist:",
                                 @"👙" : @":bikini:",
                                 @"🎂" : @":birthday:",
                                 @"🃏" : @":black_joker:",
                                 @"✒" : @":black_nib:",
                                 @"📘" : @":blue_book:",
                                 @"💣" : @":bomb:",
                                 @"🔖" : @":bookmark:",
                                 @"📑" : @":bookmark_tabs:",
                                 @"📚" : @":books:",
                                 @"👢" : @":boot:",
                                 @"🎳" : @":bowling:",
                                 @"🍞" : @":bread:",
                                 @"💼" : @":briefcase:",
                                 @"💡" : @":bulb:",
                                 @"🍰" : @":cake:",
                                 @"📆" : @":calendar:",
                                 @"📲" : @":calling:",
                                 @"📷" : @":camera:",
                                 @"🍬" : @":candy:",
                                 @"📇" : @":card_index:",
                                 @"💿" : @":cd:",
                                 @"📉" : @":chart_with_downwards_trend:",
                                 @"📈" : @":chart_with_upwards_trend:",
                                 @"🍒" : @":cherries:",
                                 @"🍫" : @":chocolate_bar:",
                                 @"🎄" : @":christmas_tree:",
                                 @"🎬" : @":clapper:",
                                 @"📋" : @":clipboard:",
                                 @"📕" : @":closed_book:",
                                 @"🔐" : @":closed_lock_with_key:",
                                 @"🌂" : @":closed_umbrella:",
                                 @"♣" : @":clubs:",
                                 @"🍸" : @":cocktail:",
                                 @"☕" : @":coffee:",
                                 @"💻" : @":computer:",
                                 @"🎊" : @":confetti_ball:",
                                 @"🍪" : @":cookie:",
                                 @"🌽" : @":corn:",
                                 @"💳" : @":credit_card:",
                                 @"👑" : @":crown:",
                                 @"🔮" : @":crystal_ball:",
                                 @"🍛" : @":curry:",
                                 @"🍮" : @":custard:",
                                 @"🍡" : @":dango:",
                                 @"🎯" : @":dart:",
                                 @"📅" : @":date:",
                                 @"♦" : @":diamonds:",
                                 @"💵" : @":dollar:",
                                 @"🚪" : @":door:",
                                 @"🍩" : @":doughnut:",
                                 @"👗" : @":dress:",
                                 @"📀" : @":dvd:",
                                 @"📧" : @":e-mail:",
                                 @"🍳" : @":egg:",
                                 @"🍆" : @":eggplant:",
                                 @"🔌" : @":electric_plug:",
                                 @"✉" : @":email:",
                                 @"💶" : @":euro:",
                                 @"👓" : @":eyeglasses:",
                                 @"📠" : @":fax:",
                                 @"📁" : @":file_folder:",
                                 @"🍥" : @":fish_cake:",
                                 @"🎣" : @":fishing_pole_and_fish:",
                                 @"🔦" : @":flashlight:",
                                 @"💾" : @":floppy_disk:",
                                 @"🎴" : @":flower_playing_cards:",
                                 @"🏈" : @":football:",
                                 @"🍴" : @":fork_and_knife:",
                                 @"🍤" : @":fried_shrimp:",
                                 @"🍟" : @":fries:",
                                 @"🎲" : @":game_die:",
                                 @"💎" : @":gem:",
                                 @"🎁" : @":gift:",
                                 @"⛳" : @":golf:",
                                 @"🍇" : @":grapes:",
                                 @"🍏" : @":green_apple:",
                                 @"📗" : @":green_book:",
                                 @"🎸" : @":guitar:",
                                 @"🔫" : @":gun:",
                                 @"🍔" : @":hamburger:",
                                 @"🔨" : @":hammer:",
                                 @"👜" : @":handbag:",
                                 @"🎧" : @":headphones:",
                                 @"♥" : @":hearts:",
                                 @"🔆" : @":high_brightness:",
                                 @"👠" : @":high_heel:",
                                 @"🔪" : @":hocho:",
                                 @"🍯" : @":honey_pot:",
                                 @"🏇" : @":horse_racing:",
                                 @"⌛" : @":hourglass:",
                                 @"⏳" : @":hourglass_flowing_sand:",
                                 @"🍨" : @":ice_cream:",
                                 @"🍦" : @":icecream:",
                                 @"📥" : @":inbox_tray:",
                                 @"📨" : @":incoming_envelope:",
                                 @"📱" : @":iphone:",
                                 @"🏮" : @":izakaya_lantern:",
                                 @"👖" : @":jeans:",
                                 @"🔑" : @":key:",
                                 @"👘" : @":kimono:",
                                 @"📒" : @":ledger:",
                                 @"🍋" : @":lemon:",
                                 @"💄" : @":lipstick:",
                                 @"🔒" : @":lock:",
                                 @"🔏" : @":lock_with_ink_pen:",
                                 @"🍭" : @":lollipop:",
                                 @"➿" : @":loop:",
                                 @"📢" : @":loudspeaker:",
                                 @"🔅" : @":low_brightness:",
                                 @"🔍" : @":mag:",
                                 @"🔎" : @":mag_right:",
                                 @"🀄" : @":mahjong:",
                                 @"📫" : @":mailbox:",
                                 @"📪" : @":mailbox_closed:",
                                 @"📬" : @":mailbox_with_mail:",
                                 @"📭" : @":mailbox_with_no_mail:",
                                 @"👞" : @":mans_shoe:",
                                 @"🍖" : @":meat_on_bone:",
                                 @"📣" : @":mega:",
                                 @"🍈" : @":melon:",
                                 @"📝" : @":memo:",
                                 @"🎤" : @":microphone:",
                                 @"🔬" : @":microscope:",
                                 @"💽" : @":minidisc:",
                                 @"💸" : @":money_with_wings:",
                                 @"💰" : @":moneybag:",
                                 @"🚵" : @":mountain_bicyclist:",
                                 @"🎥" : @":movie_camera:",
                                 @"🎹" : @":musical_keyboard:",
                                 @"🎼" : @":musical_score:",
                                 @"🔇" : @":mute:",
                                 @"📛" : @":name_badge:",
                                 @"👔" : @":necktie:",
                                 @"📰" : @":newspaper:",
                                 @"🔕" : @":no_bell:",
                                 @"📓" : @":notebook:",
                                 @"📔" : @":notebook_with_decorative_cover:",
                                 @"🔩" : @":nut_and_bolt:",
                                 @"🍢" : @":oden:",
                                 @"📂" : @":open_file_folder:",
                                 @"📙" : @":orange_book:",
                                 @"📤" : @":outbox_tray:",
                                 @"📄" : @":page_facing_up:",
                                 @"📃" : @":page_with_curl:",
                                 @"📟" : @":pager:",
                                 @"📎" : @":paperclip:",
                                 @"🍑" : @":peach:",
                                 @"🍐" : @":pear:",
                                 @"✏" : @":pencil2:",
                                 @"☎" : @":phone:",
                                 @"💊" : @":pill:",
                                 @"🍍" : @":pineapple:",
                                 @"🍕" : @":pizza:",
                                 @"📯" : @":postal_horn:",
                                 @"📮" : @":postbox:",
                                 @"👝" : @":pouch:",
                                 @"🍗" : @":poultry_leg:",
                                 @"💷" : @":pound:",
                                 @"👛" : @":purse:",
                                 @"📌" : @":pushpin:",
                                 @"📻" : @":radio:",
                                 @"🍜" : @":ramen:",
                                 @"🎀" : @":ribbon:",
                                 @"🍚" : @":rice:",
                                 @"🍙" : @":rice_ball:",
                                 @"🍘" : @":rice_cracker:",
                                 @"💍" : @":ring:",
                                 @"🏉" : @":rugby_football:",
                                 @"🎽" : @":running_shirt_with_sash:",
                                 @"🍶" : @":sake:",
                                 @"👡" : @":sandal:",
                                 @"📡" : @":satellite:",
                                 @"🎷" : @":saxophone:",
                                 @"✂" : @":scissors:",
                                 @"📜" : @":scroll:",
                                 @"💺" : @":seat:",
                                 @"🍧" : @":shaved_ice:",
                                 @"👕" : @":shirt:",
                                 @"🚿" : @":shower:",
                                 @"🎿" : @":ski:",
                                 @"🚬" : @":smoking:",
                                 @"🏂" : @":snowboarder:",
                                 @"⚽" : @":soccer:",
                                 @"🔉" : @":sound:",
                                 @"👾" : @":space_invader:",
                                 @"♠" : @":spades:",
                                 @"🍝" : @":spaghetti:",
                                 @"🔊" : @":speaker:",
                                 @"🍲" : @":stew:",
                                 @"📏" : @":straight_ruler:",
                                 @"🍓" : @":strawberry:",
                                 @"🏄" : @":surfer:",
                                 @"🍣" : @":sushi:",
                                 @"🍠" : @":sweet_potato:",
                                 @"🏊" : @":swimmer:",
                                 @"💉" : @":syringe:",
                                 @"🎉" : @":tada:",
                                 @"🎋" : @":tanabata_tree:",
                                 @"🍊" : @":tangerine:",
                                 @"🍵" : @":tea:",
                                 @"📞" : @":telephone_receiver:",
                                 @"🔭" : @":telescope:",
                                 @"🎾" : @":tennis:",
                                 @"🚽" : @":toilet:",
                                 @"🍅" : @":tomato:",
                                 @"🎩" : @":tophat:",
                                 @"📐" : @":triangular_ruler:",
                                 @"🏆" : @":trophy:",
                                 @"🍹" : @":tropical_drink:",
                                 @"🎺" : @":trumpet:",
                                 @"📺" : @":tv:",
                                 @"🔓" : @":unlock:",
                                 @"📼" : @":vhs:",
                                 @"📹" : @":video_camera:",
                                 @"🎮" : @":video_game:",
                                 @"🎻" : @":violin:",
                                 @"⌚" : @":watch:",
                                 @"🍉" : @":watermelon:",
                                 @"🍷" : @":wine_glass:",
                                 @"👚" : @":womans_clothes:",
                                 @"👒" : @":womans_hat:",
                                 @"🔧" : @":wrench:",
                                 @"💴" : @":yen:",
                                 @"🚡" : @":aerial_tramway:",
                                 @"✈" : @":airplane:",
                                 @"🚑" : @":ambulance:",
                                 @"⚓" : @":anchor:",
                                 @"🚛" : @":articulated_lorry:",
                                 @"🏧" : @":atm:",
                                 @"🏦" : @":bank:",
                                 @"💈" : @":barber:",
                                 @"🔰" : @":beginner:",
                                 @"🚲" : @":bike:",
                                 @"🚙" : @":blue_car:",
                                 @"⛵" : @":boat:",
                                 @"🌉" : @":bridge_at_night:",
                                 @"🚅" : @":bullettrain_front:",
                                 @"🚄" : @":bullettrain_side:",
                                 @"🚌" : @":bus:",
                                 @"🚏" : @":busstop:",
                                 @"🚗" : @":car:",
                                 @"🎠" : @":carousel_horse:",
                                 @"🏁" : @":checkered_flag:",
                                 @"⛪" : @":church:",
                                 @"🎪" : @":circus_tent:",
                                 @"🌇" : @":city_sunrise:",
                                 @"🌆" : @":city_sunset:",
                                 @"🚧" : @":construction:",
                                 @"🏪" : @":convenience_store:",
                                 @"🎌" : @":crossed_flags:",
                                 @"🏬" : @":department_store:",
                                 @"🏰" : @":european_castle:",
                                 @"🏤" : @":european_post_office:",
                                 @"🏭" : @":factory:",
                                 @"🎡" : @":ferris_wheel:",
                                 @"🚒" : @":fire_engine:",
                                 @"⛲" : @":fountain:",
                                 @"⛽" : @":fuelpump:",
                                 @"🚁" : @":helicopter:",
                                 @"🏥" : @":hospital:",
                                 @"🏨" : @":hotel:",
                                 @"♨" : @":hotsprings:",
                                 @"🏠" : @":house:",
                                 @"🏡" : @":house_with_garden:",
                                 @"🗾" : @":japan:",
                                 @"🏯" : @":japanese_castle:",
                                 @"🚈" : @":light_rail:",
                                 @"🏩" : @":love_hotel:",
                                 @"🚐" : @":minibus:",
                                 @"🚝" : @":monorail:",
                                 @"🗻" : @":mount_fuji:",
                                 @"🚠" : @":mountain_cableway:",
                                 @"🚞" : @":mountain_railway:",
                                 @"🗿" : @":moyai:",
                                 @"🏢" : @":office:",
                                 @"🚘" : @":oncoming_automobile:",
                                 @"🚍" : @":oncoming_bus:",
                                 @"🚔" : @":oncoming_police_car:",
                                 @"🚖" : @":oncoming_taxi:",
                                 @"🎭" : @":performing_arts:",
                                 @"🚓" : @":police_car:",
                                 @"🏣" : @":post_office:",
                                 @"🚃" : @":railway_car:",
                                 @"🌈" : @":rainbow:",
                                 @"🚀" : @":rocket:",
                                 @"🎢" : @":roller_coaster:",
                                 @"🚨" : @":rotating_light:",
                                 @"📍" : @":round_pushpin:",
                                 @"🚣" : @":rowboat:",
                                 @"🏫" : @":school:",
                                 @"🚢" : @":ship:",
                                 @"🎰" : @":slot_machine:",
                                 @"🚤" : @":speedboat:",
                                 @"🌠" : @":stars:",
                                 @"🌃" : @":city-night:",
                                 @"🚉" : @":station:",
                                 @"🗽" : @":statue_of_liberty:",
                                 @"🚂" : @":steam_locomotive:",
                                 @"🌅" : @":sunrise:",
                                 @"🌄" : @":sunrise_over_mountains:",
                                 @"🚟" : @":suspension_railway:",
                                 @"🚕" : @":taxi:",
                                 @"⛺" : @":tent:",
                                 @"🎫" : @":ticket:",
                                 @"🗼" : @":tokyo_tower:",
                                 @"🚜" : @":tractor:",
                                 @"🚥" : @":traffic_light:",
                                 @"🚆" : @":train2:",
                                 @"🚊" : @":tram:",
                                 @"🚩" : @":triangular_flag_on_post:",
                                 @"🚎" : @":trolleybus:",
                                 @"🚚" : @":truck:",
                                 @"🚦" : @":vertical_traffic_light:",
                                 @"⚠" : @":warning:",
                                 @"💒" : @":wedding:",
                                 @"🇯🇵" : @":jp:",
                                 @"🇰🇷" : @":kr:",
                                 @"🇨🇳" : @":cn:",
                                 @"🇺🇸" : @":us:",
                                 @"🇫🇷" : @":fr:",
                                 @"🇪🇸" : @":es:",
                                 @"🇮🇹" : @":it:",
                                 @"🇷🇺" : @":ru:",
                                 @"🇬🇧" : @":gb:",
                                 @"🇩🇪" : @":de:",
                                 @"💯" : @":100:",
                                 @"🔢" : @":1234:",
                                 @"🅰" : @":a:",
                                 @"🆎" : @":ab:",
                                 @"🔤" : @":abc:",
                                 @"🔡" : @":abcd:",
                                 @"🉑" : @":accept:",
                                 @"♒" : @":aquarius:",
                                 @"♈" : @":aries:",
                                 @"◀" : @":arrow_backward:",
                                 @"⏬" : @":arrow_double_down:",
                                 @"⏫" : @":arrow_double_up:",
                                 @"⬇" : @":arrow_down:",
                                 @"🔽" : @":arrow_down_small:",
                                 @"▶" : @":arrow_forward:",
                                 @"⤵" : @":arrow_heading_down:",
                                 @"⤴" : @":arrow_heading_up:",
                                 @"⬅" : @":arrow_left:",
                                 @"↙" : @":arrow_lower_left:",
                                 @"↘" : @":arrow_lower_right:",
                                 @"➡" : @":arrow_right:",
                                 @"↪" : @":arrow_right_hook:",
                                 @"⬆" : @":arrow_up:",
                                 @"↕" : @":arrow_up_down:",
                                 @"🔼" : @":arrow_up_small:",
                                 @"↖" : @":arrow_upper_left:",
                                 @"↗" : @":arrow_upper_right:",
                                 @"🔃" : @":arrows_clockwise:",
                                 @"🔄" : @":arrows_counterclockwise:",
                                 @"🅱" : @":b:",
                                 @"🚼" : @":baby_symbol:",
                                 @"🛄" : @":baggage_claim:",
                                 @"☑" : @":ballot_box_with_check:",
                                 @"‼" : @":bangbang:",
                                 @"⚫" : @":black_circle:",
                                 @"🔲" : @":black_square_button:",
                                 @"♋" : @":cancer:",
                                 @"🔠" : @":capital_abcd:",
                                 @"♑" : @":capricorn:",
                                 @"💹" : @":chart:",
                                 @"🚸" : @":children_crossing:",
                                 @"🎦" : @":cinema:",
                                 @"🆑" : @":cl:",
                                 @"🕐" : @":clock1:",
                                 @"🕙" : @":clock10:",
                                 @"🕥" : @":clock1030:",
                                 @"🕚" : @":clock11:",
                                 @"🕦" : @":clock1130:",
                                 @"🕛" : @":clock12:",
                                 @"🕧" : @":clock1230:",
                                 @"🕜" : @":clock130:",
                                 @"🕑" : @":clock2:",
                                 @"🕝" : @":clock230:",
                                 @"🕒" : @":clock3:",
                                 @"🕞" : @":clock330:",
                                 @"🕓" : @":clock4:",
                                 @"🕟" : @":clock430:",
                                 @"🕔" : @":clock5:",
                                 @"🕠" : @":clock530:",
                                 @"🕕" : @":clock6:",
                                 @"🕡" : @":clock630:",
                                 @"🕖" : @":clock7:",
                                 @"🕢" : @":clock730:",
                                 @"🕗" : @":clock8:",
                                 @"🕣" : @":clock830:",
                                 @"🕘" : @":clock9:",
                                 @"🕤" : @":clock930:",
                                 @"㊗" : @":congratulations:",
                                 @"🆒" : @":cool:",
                                 @"©" : @":copyright:",
                                 @"➰" : @":curly_loop:",
                                 @"💱" : @":currency_exchange:",
                                 @"🛃" : @":customs:",
                                 @"💠" : @":diamond_shape_with_a_dot_inside:",
                                 @"🚯" : @":do_not_litter:",
                                 @"8⃣" : @":eight:",
                                 @"✴" : @":eight_pointed_black_star:",
                                 @"✳" : @":eight_spoked_asterisk:",
                                 @"🔚" : @":end:",
                                 @"⏩" : @":fast_forward:",
                                 @"5⃣" : @":five:",
                                 @"4⃣" : @":four:",
                                 @"🆓" : @":free:",
                                 @"♊" : @":gemini:",
                                 @"#⃣" : @":hash:",
                                 @"💟" : @":heart_decoration:",
                                 @"✔" : @":heavy_check_mark:",
                                 @"➗" : @":heavy_division_sign:",
                                 @"💲" : @":heavy_dollar_sign:",
                                 @"➖" : @":heavy_minus_sign:",
                                 @"✖" : @":heavy_multiplication_x:",
                                 @"➕" : @":heavy_plus_sign:",
                                 @"🆔" : @":id:",
                                 @"🉐" : @":ideograph_advantage:",
                                 @"ℹ" : @":information_source:",
                                 @"⁉" : @":interrobang:",
                                 @"🔟" : @":keycap_ten:",
                                 @"🈁" : @":koko:",
                                 @"🔵" : @":large_blue_circle:",
                                 @"🔷" : @":large_blue_diamond:",
                                 @"🔶" : @":large_orange_diamond:",
                                 @"🛅" : @":left_luggage:",
                                 @"↔" : @":left_right_arrow:",
                                 @"↩" : @":leftwards_arrow_with_hook:",
                                 @"♌" : @":leo:",
                                 @"♎" : @":libra:",
                                 @"🔗" : @":link:",
                                 @"Ⓜ" : @":m:",
                                 @"🚹" : @":mens:",
                                 @"🚇" : @":metro:",
                                 @"📴" : @":mobile_phone_off:",
                                 @"❎" : @":negative_squared_cross_mark:",
                                 @"🆕" : @":new:",
                                 @"🆖" : @":ng:",
                                 @"9⃣" : @":nine:",
                                 @"🚳" : @":no_bicycles:",
                                 @"⛔" : @":no_entry:",
                                 @"🚫" : @":no_entry_sign:",
                                 @"📵" : @":no_mobile_phones:",
                                 @"🚷" : @":no_pedestrians:",
                                 @"🚭" : @":no_smoking:",
                                 @"🚱" : @":non-potable_water:",
                                 @"⭕" : @":o:",
                                 @"🅾" : @":o2:",
                                 @"🆗" : @":ok:",
                                 @"🔛" : @":on:",
                                 @"1⃣" : @":one:",
                                 @"⛎" : @":ophiuchus:",
                                 @"🅿" : @":parking:",
                                 @"〽" : @":part_alternation_mark:",
                                 @"🛂" : @":passport_control:",
                                 @"♓" : @":pisces:",
                                 @"🚰" : @":potable_water:",
                                 @"🚮" : @":put_litter_in_its_place:",
                                 @"🔘" : @":radio_button:",
                                 @"♻" : @":recycle:",
                                 @"🔴" : @":red_circle:",
                                 @"®" : @":registered:",
                                 @"🔁" : @":repeat:",
                                 @"🔂" : @":repeat_one:",
                                 @"🚻" : @":restroom:",
                                 @"⏪" : @":rewind:",
                                 @"🈂" : @":sa:",
                                 @"♐" : @":sagittarius:",
                                 @"♏" : @":scorpius:",
                                 @"㊙" : @":secret:",
                                 @"7⃣" : @":seven:",
                                 @"📶" : @":signal_strength:",
                                 @"6⃣" : @":six:",
                                 @"🔯" : @":six_pointed_star:",
                                 @"🔹" : @":small_blue_diamond:",
                                 @"🔸" : @":small_orange_diamond:",
                                 @"🔺" : @":small_red_triangle:",
                                 @"🔻" : @":small_red_triangle_down:",
                                 @"🔜" : @":soon:",
                                 @"🆘" : @":sos:",
                                 @"🔣" : @":symbols:",
                                 @"♉" : @":taurus:",
                                 @"3⃣" : @":three:",
                                 @"™" : @":tm:",
                                 @"🔝" : @":top:",
                                 @"🔱" : @":trident:",
                                 @"🔀" : @":twisted_rightwards_arrows:",
                                 @"2⃣" : @":two:",
                                 @"🈹" : @":u5272:",
                                 @"🈴" : @":u5408:",
                                 @"🈺" : @":u55b6:",
                                 @"🈯" : @":u6307:",
                                 @"🈷" : @":u6708:",
                                 @"🈶" : @":u6709:",
                                 @"🈵" : @":u6e80:",
                                 @"🈚" : @":u7121:",
                                 @"🈸" : @":u7533:",
                                 @"🈲" : @":u7981:",
                                 @"🈳" : @":u7a7a:",
                                 @"🔞" : @":underage:",
                                 @"🆙" : @":up:",
                                 @"📳" : @":vibration_mode:",
                                 @"♍" : @":virgo:",
                                 @"🆚" : @":vs:",
                                 @"〰" : @":wavy_dash:",
                                 @"🚾" : @":wc:",
                                 @"♿" : @":wheelchair:",
                                 @"✅" : @":white_check_mark:",
                                 @"⚪" : @":white_circle:",
                                 @"💮" : @":white_flower:",
                                 @"🔳" : @":white_square_button:",
                                 @"🚺" : @":womens:",
                                 @"❌" : @":x:",
                                 @"0⃣" : @":zero:"
                                 };
    
    NSMutableDictionary *reversedMap = [NSMutableDictionary dictionaryWithCapacity:[forwardMap count]];
    [forwardMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSArray class]]) {
            for (NSString *object in obj) {
                [reversedMap setObject:key forKey:object];
            }
        } else {
            [reversedMap setObject:key forKey:obj];
        }
    }];
    
    @synchronized(self) {
        s_unicodeToCheatCodes = forwardMap;
        s_cheatCodesToUnicode = [reversedMap copy];
    }
}

- (NSString *)stringByReplacingEmojiCheatCodesWithUnicode
{
    if (!s_cheatCodesToUnicode) {
        [NSString initializeEmojiCheatCodes];
    }
    
    if ([self rangeOfString:@":"].location != NSNotFound) {
        __block NSMutableString *newText = [NSMutableString stringWithString:self];
        [s_cheatCodesToUnicode enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [newText replaceOccurrencesOfString:key withString:obj options:NSLiteralSearch range:NSMakeRange(0, newText.length)];
        }];
        return newText;
    }
    
    return self;
}

- (NSString *)stringByReplacingEmojiUnicodeWithCheatCodes
{
    if (!s_cheatCodesToUnicode) {
        [NSString initializeEmojiCheatCodes];
    }
    
    if (self.length) {
        __block NSMutableString *newText = [NSMutableString stringWithString:self];
        [s_unicodeToCheatCodes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *string = ([obj isKindOfClass:[NSArray class]] ? [obj firstObject] : obj);
            [newText replaceOccurrencesOfString:key withString:string options:NSLiteralSearch range:NSMakeRange(0, newText.length)];
        }];
        return newText;
    }
    return self;
}

/**
 *  @brief  是否包含emoji
 *
 *  @return 是否包含emoji
 */
- (BOOL)isEmoji
{
    if ([self isFuckEmoji]) {
        return YES;
    }
    const unichar high = [self characterAtIndex:0];
    
    
    // Surrogate pair (U+1D000-1F77F)
    if (0xd800 <= high && high <= 0xdbff) {
        const unichar low = [self characterAtIndex:1];
        const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;
        
        return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
        
        // Not surrogate pair (U+2100-27BF)
    } else {
        return (0x2100 <= high && high <= 0x27bf);
    }
    //
}
- (BOOL)isFuckEmoji
{
    NSArray *fuckArray = @[ @"⭐", @"㊙️", @"㊗️", @"⬅️", @"⬆️", @"⬇️", @"⤴️", @"⤵️", @"#️⃣", @"0️⃣", @"1️⃣", @"2️⃣", @"3️⃣", @"4️⃣", @"5️⃣", @"6️⃣", @"7️⃣", @"8️⃣", @"9️⃣", @"〰", @"©®", @"〽️", @"‼️", @"⁉️", @"⭕️", @"⬛️", @"⬜️", @"⭕", @"", @"⬆", @"⬇", @"⬅", @"㊙", @"㊗", @"⭕", @"©®", @"⤴", @"⤵", @"〰", @"†", @"⟹", @"ツ", @"ღ", @"©", @"®" ];
    BOOL result = NO;
    for (NSString *string in fuckArray) {
        if ([self isEqualToString:string]) {
            return YES;
        }
    }
    if ([@"\u2b50\ufe0f" isEqualToString:self]) {
        result = YES;
    }
    return result;
}

- (BOOL)isIncludingEmoji
{
    BOOL __block result = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              if ([substring isEmoji]) {
                                  *stop = YES;
                                  result = YES;
                              }
                          }];
    
    return result;
}
/**
 *  @brief  删除掉包含的emoji
 *
 *  @return 清除后的string
 */
- (instancetype)removedEmojiString
{
    NSMutableString *__block buffer = [NSMutableString stringWithCapacity:[self length]];
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              [buffer appendString:([substring isEmoji])? @"": substring];
                          }];
    
    return buffer;
}

#pragma mark-
#pragma mark :. Encrypt

- (NSString *)encryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv
{
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWithAESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64EncodedString];
    
    return encryptedString;
}

- (NSString *)decryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv
{
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWithAESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

- (NSString *)encryptedWith3DESUsingKey:(NSString *)key andIV:(NSData *)iv
{
    NSData *encrypted = [[self dataUsingEncoding:NSUTF8StringEncoding] encryptedWith3DESUsingKey:key andIV:iv];
    NSString *encryptedString = [encrypted base64EncodedString];
    
    return encryptedString;
}

- (NSString *)decryptedWith3DESUsingKey:(NSString *)key andIV:(NSData *)iv
{
    NSData *decrypted = [[NSData dataWithBase64EncodedString:self] decryptedWith3DESUsingKey:key andIV:iv];
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    
    return decryptedString;
}

#pragma mark-
#pragma mark :. Hash

- (NSString *)md5String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_MD5_DIGEST_LENGTH];
}

- (NSString *)sha1String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)sha256String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)sha512String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
}

- (NSString *)hmacMD5StringWithKey:(NSString *)key
{
    return [self hmacStringUsingAlg:kCCHmacAlgMD5 withKey:key];
}

- (NSString *)hmacSHA1StringWithKey:(NSString *)key
{
    return [self hmacStringUsingAlg:kCCHmacAlgSHA1 withKey:key];
}

- (NSString *)hmacSHA256StringWithKey:(NSString *)key
{
    return [self hmacStringUsingAlg:kCCHmacAlgSHA256 withKey:key];
}

- (NSString *)hmacSHA512StringWithKey:(NSString *)key
{
    return [self hmacStringUsingAlg:kCCHmacAlgSHA512 withKey:key];
}

#pragma mark --- Helpers
- (NSString *)hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key
{
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5:
            size = CC_MD5_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA1:
            size = CC_SHA1_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA224:
            size = CC_SHA224_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA256:
            size = CC_SHA256_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA384:
            size = CC_SHA384_DIGEST_LENGTH;
            break;
        case kCCHmacAlgSHA512:
            size = CC_SHA512_DIGEST_LENGTH;
            break;
        default:
            return nil;
    }
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *messageData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableData = [NSMutableData dataWithLength:size];
    CCHmac(alg, keyData.bytes, keyData.length, messageData.bytes, messageData.length, mutableData.mutableBytes);
    return [self stringFromBytes:(unsigned char *)mutableData.bytes length:(int)mutableData.length];
}

- (NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length
{
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
        [mutableString appendFormat:@"%02x", bytes[i]];
    return [NSString stringWithString:mutableString];
}

#pragma mark-
#pragma mark :. Matcher

- (NSArray *)matchWithRegex:(NSString *)regex
{
    NSTextCheckingResult *result = [self firstMatchedResultWithRegex:regex];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:[result numberOfRanges]];
    for (int i = 0 ; i < [result numberOfRanges]; i ++ ) {
        [mArray addObject:[self substringWithRange:[result rangeAtIndex:i]]];
    }
    return mArray;
}

- (NSString *)matchWithRegex:(NSString *)regex atIndex:(NSUInteger)index
{
    NSTextCheckingResult *result = [self firstMatchedResultWithRegex:regex];
    return [self substringWithRange:[result rangeAtIndex:index]];
}

- (NSString *)firstMatchedGroupWithRegex:(NSString *)regex
{
    NSTextCheckingResult *result = [self firstMatchedResultWithRegex:regex];
    return [self substringWithRange:[result rangeAtIndex:1]];
}

- (NSTextCheckingResult *)firstMatchedResultWithRegex:(NSString *)regex
{
    NSRegularExpression *regexExpression = [NSRegularExpression regularExpressionWithPattern:regex options:(NSRegularExpressionOptions)0 error:NULL];
    NSRange range = {0, self.length};
    return [regexExpression firstMatchInString:self options:(NSMatchingOptions)0 range:range];
}

#pragma mark-
#pragma mark :. MIME

/**
 *  @brief  根据文件url后缀 返回对应的MIMEType
 *
 *  @return MIMEType
 */
- (NSString *)MIMEType
{
    return [[self class] MIMETypeForExtension:[self pathExtension]];
}

+ (NSString *)MIMETypeForExtension:(NSString *)extension
{
    return [[self MIMEDict] valueForKey:[extension lowercaseString]];
}

/**
 *  @brief  常见MIME集合
 *
 *  @return 常见MIME集合
 */
+ (NSDictionary *)MIMEDict
{
    NSDictionary *MIMEDict;
    // Lazy loads the MIME type dictionary.
    if (!MIMEDict) {
        
        // ???: Should I have these return an array of MIME types? The first element would be the preferred MIME type.
        
        // ???: Should I have a couple methods that return the MIME media type name and the MIME subtype name?
        
        // There are probably values missed, but this is a good start.
        // A few more have been added that weren't included on the original list.
        MIMEDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    // Key      // Value
                    @"", @"application/octet-stream",
                    @"323", @"text/h323",
                    @"acx", @"application/internet-property-stream",
                    @"ai", @"application/postscript",
                    @"aif", @"audio/x-aiff",
                    @"aifc", @"audio/x-aiff",
                    @"aiff", @"audio/x-aiff",
                    @"asf", @"video/x-ms-asf",
                    @"asr", @"video/x-ms-asf",
                    @"asx", @"video/x-ms-asf",
                    @"au", @"audio/basic",
                    @"avi", @"video/x-msvideo",
                    @"axs", @"application/olescript",
                    @"bas", @"text/plain",
                    @"bcpio", @"application/x-bcpio",
                    @"bin", @"application/octet-stream",
                    @"bmp", @"image/bmp",
                    @"c", @"text/plain",
                    @"cat", @"application/vnd.ms-pkiseccat",
                    @"cdf", @"application/x-cdf",
                    @"cer", @"application/x-x509-ca-cert",
                    @"class", @"application/octet-stream",
                    @"clp", @"application/x-msclip",
                    @"cmx", @"image/x-cmx",
                    @"cod", @"image/cis-cod",
                    @"cpio", @"application/x-cpio",
                    @"crd", @"application/x-mscardfile",
                    @"crl", @"application/pkix-crl",
                    @"crt", @"application/x-x509-ca-cert",
                    @"csh", @"application/x-csh",
                    @"css", @"text/css",
                    @"dcr", @"application/x-director",
                    @"der", @"application/x-x509-ca-cert",
                    @"dir", @"application/x-director",
                    @"dll", @"application/x-msdownload",
                    @"dms", @"application/octet-stream",
                    @"doc", @"application/msword",
                    @"docx", @"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                    @"dot", @"application/msword",
                    @"dvi", @"application/x-dvi",
                    @"dxr", @"application/x-director",
                    @"eps", @"application/postscript",
                    @"etx", @"text/x-setext",
                    @"evy", @"application/envoy",
                    @"exe", @"application/octet-stream",
                    @"fif", @"application/fractals",
                    @"flr", @"x-world/x-vrml",
                    @"gif", @"image/gif",
                    @"gtar", @"application/x-gtar",
                    @"gz", @"application/x-gzip",
                    @"h", @"text/plain",
                    @"hdf", @"application/x-hdf",
                    @"hlp", @"application/winhlp",
                    @"hqx", @"application/mac-binhex40",
                    @"hta", @"application/hta",
                    @"htc", @"text/x-component",
                    @"htm", @"text/html",
                    @"html", @"text/html",
                    @"htt", @"text/webviewhtml",
                    @"ico", @"image/x-icon",
                    @"ief", @"image/ief",
                    @"iii", @"application/x-iphone",
                    @"ins", @"application/x-internet-signup",
                    @"isp", @"application/x-internet-signup",
                    @"jfif", @"image/pipeg",
                    @"jpe", @"image/jpeg",
                    @"jpeg", @"image/jpeg",
                    @"jpg", @"image/jpeg",
                    @"js", @"application/x-javascript",
                    @"json", @"application/json", // According to RFC 4627  // Also application/x-javascript text/javascript text/x-javascript text/x-json
                    @"latex", @"application/x-latex",
                    @"lha", @"application/octet-stream",
                    @"lsf", @"video/x-la-asf",
                    @"lsx", @"video/x-la-asf",
                    @"lzh", @"application/octet-stream",
                    @"m", @"text/plain",
                    @"m13", @"application/x-msmediaview",
                    @"m14", @"application/x-msmediaview",
                    @"m3u", @"audio/x-mpegurl",
                    @"man", @"application/x-troff-man",
                    @"mdb", @"application/x-msaccess",
                    @"me", @"application/x-troff-me",
                    @"mht", @"message/rfc822",
                    @"mhtml", @"message/rfc822",
                    @"mid", @"audio/mid",
                    @"mny", @"application/x-msmoney",
                    @"mov", @"video/quicktime",
                    @"movie", @"video/x-sgi-movie",
                    @"mp2", @"video/mpeg",
                    @"mp3", @"audio/mpeg",
                    @"mpa", @"video/mpeg",
                    @"mpe", @"video/mpeg",
                    @"mpeg", @"video/mpeg",
                    @"mpg", @"video/mpeg",
                    @"mpp", @"application/vnd.ms-project",
                    @"mpv2", @"video/mpeg",
                    @"ms", @"application/x-troff-ms",
                    @"mvb", @"	application/x-msmediaview",
                    @"nws", @"message/rfc822",
                    @"oda", @"application/oda",
                    @"p10", @"application/pkcs10",
                    @"p12", @"application/x-pkcs12",
                    @"p7b", @"application/x-pkcs7-certificates",
                    @"p7c", @"application/x-pkcs7-mime",
                    @"p7m", @"application/x-pkcs7-mime",
                    @"p7r", @"application/x-pkcs7-certreqresp",
                    @"p7s", @"	application/x-pkcs7-signature",
                    @"pbm", @"image/x-portable-bitmap",
                    @"pdf", @"application/pdf",
                    @"pfx", @"application/x-pkcs12",
                    @"pgm", @"image/x-portable-graymap",
                    @"pko", @"application/ynd.ms-pkipko",
                    @"pma", @"application/x-perfmon",
                    @"pmc", @"application/x-perfmon",
                    @"pml", @"application/x-perfmon",
                    @"pmr", @"application/x-perfmon",
                    @"pmw", @"application/x-perfmon",
                    @"png", @"image/png",
                    @"pnm", @"image/x-portable-anymap",
                    @"pot", @"application/vnd.ms-powerpoint",
                    @"vppm", @"image/x-portable-pixmap",
                    @"pps", @"application/vnd.ms-powerpoint",
                    @"ppt", @"application/vnd.ms-powerpoint",
                    @"pptx", @"application/vnd.openxmlformats-officedocument.presentationml.presentation",
                    @"prf", @"application/pics-rules",
                    @"ps", @"application/postscript",
                    @"pub", @"application/x-mspublisher",
                    @"qt", @"video/quicktime",
                    @"ra", @"audio/x-pn-realaudio",
                    @"ram", @"audio/x-pn-realaudio",
                    @"ras", @"image/x-cmu-raster",
                    @"rgb", @"image/x-rgb",
                    @"rmi", @"audio/mid",
                    @"roff", @"application/x-troff",
                    @"rtf", @"application/rtf",
                    @"rtx", @"text/richtext",
                    @"scd", @"application/x-msschedule",
                    @"sct", @"text/scriptlet",
                    @"setpay", @"application/set-payment-initiation",
                    @"setreg", @"application/set-registration-initiation",
                    @"sh", @"application/x-sh",
                    @"shar", @"application/x-shar",
                    @"sit", @"application/x-stuffit",
                    @"snd", @"audio/basic",
                    @"spc", @"application/x-pkcs7-certificates",
                    @"spl", @"application/futuresplash",
                    @"src", @"application/x-wais-source",
                    @"sst", @"application/vnd.ms-pkicertstore",
                    @"stl", @"application/vnd.ms-pkistl",
                    @"stm", @"text/html",
                    @"svg", @"image/svg+xml",
                    @"sv4cpio", @"application/x-sv4cpio",
                    @"sv4crc", @"application/x-sv4crc",
                    @"swf", @"application/x-shockwave-flash",
                    @"t", @"application/x-troff",
                    @"tar", @"application/x-tar",
                    @"tcl", @"application/x-tcl",
                    @"tex", @"application/x-tex",
                    @"texi", @"application/x-texinfo",
                    @"texinfo", @"application/x-texinfo",
                    @"tgz", @"application/x-compressed",
                    @"tif", @"image/tiff",
                    @"tiff", @"image/tiff",
                    @"tr", @"application/x-troff",
                    @"trm", @"application/x-msterminal",
                    @"tsv", @"text/tab-separated-values",
                    @"txt", @"text/plain",
                    @"uls", @"text/iuls",
                    @"ustar", @"application/x-ustar",
                    @"vcf", @"text/x-vcard",
                    @"vrml", @"x-world/x-vrml",
                    @"wav", @"audio/x-wav",
                    @"wcm", @"application/vnd.ms-works",
                    @"wdb", @"application/vnd.ms-works",
                    @"wks", @"application/vnd.ms-works",
                    @"wmf", @"application/x-msmetafile",
                    @"wps", @"application/vnd.ms-works",
                    @"wri", @"application/x-mswrite",
                    @"wrl", @"x-world/x-vrml",
                    @"wrz", @"x-world/x-vrml",
                    @"xaf", @"x-world/x-vrml",
                    @"xbm", @"image/x-xbitmap",
                    @"xla", @"application/vnd.ms-excel",
                    @"xlc", @"application/vnd.ms-excel",
                    @"xlm", @"application/vnd.ms-excel",
                    @"xls", @"application/vnd.ms-excel",
                    @"xlsx", @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    @"xlt", @"application/vnd.ms-excel",
                    @"xlw", @"application/vnd.ms-excel",
                    @"xml", @"text/xml", // According to RFC 3023   // Also application/xml
                    @"xof", @"x-world/x-vrml",
                    @"xpm", @"image/x-xpixmap",
                    @"xwd", @"image/x-xwindowdump",
                    @"z", @"application/x-compress",
                    @"zip", @"application/zip",
                    nil];
    }
    
    return MIMEDict;
}

#pragma mark-
#pragma mark :. Pinyin

- (NSString *)pinyinWithPhoneticSymbol
{
    NSMutableString *pinyin = [NSMutableString stringWithString:self];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin), NULL, kCFStringTransformMandarinLatin, NO);
    return pinyin;
}

- (NSString *)pinyin
{
    NSMutableString *pinyin = [NSMutableString stringWithString:[self pinyinWithPhoneticSymbol]];
    CFStringTransform((__bridge CFMutableStringRef)(pinyin), NULL, kCFStringTransformStripCombiningMarks, NO);
    return pinyin;
}

- (NSArray *)pinyinArray
{
    NSArray *array = [[self pinyin] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return array;
}

- (NSString *)pinyinWithoutBlank
{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSString *str in [self pinyinArray]) {
        [string appendString:str];
    }
    return string;
}

- (NSArray *)pinyinInitialsArray
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *str in [self pinyinArray]) {
        if ([str length] > 0) {
            [array addObject:[str substringToIndex:1]];
        }
    }
    return array;
}

- (NSString *)pinyinInitialsString
{
    NSMutableString *pinyin = [NSMutableString stringWithString:@""];
    for (NSString *str in [self pinyinArray]) {
        if ([str length] > 0) {
            [pinyin appendString:[str substringToIndex:1]];
        }
    }
    return pinyin;
}

#pragma mark-
#pragma mark :. RegexCategory

#pragma mark --- 正则相关
- (BOOL)isValidateByRegex:(NSString *)regex
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pre evaluateWithObject:self];
}

//手机号分服务商
- (BOOL)isMobileNumberClassification
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188,1705
     * 联通：130,131,132,152,155,156,185,186,1709
     * 电信：133,1349,153,180,189,1700
     */
    //    NSString * MOBILE = @"^1((3//d|5[0-35-9]|8[025-9])//d|70[059])\\d{7}$";//总况
    
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188，1705
     12         */
    NSString *CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d|705)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186,1709
     17         */
    NSString *CU = @"^1((3[0-2]|5[256]|8[56])\\d|709)\\d{7}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,1700
     22         */
    NSString *CT = @"^1((33|53|8[09])\\d|349|700)\\d{7}$";
    
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString *PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    
    //    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    if (([self isValidateByRegex:CM]) || ([self isValidateByRegex:CU]) || ([self isValidateByRegex:CT]) || ([self isValidateByRegex:PHS])) {
        return YES;
    } else {
        return NO;
    }
}

//手机号有效性
- (BOOL)isMobileNumber
{
    /**
     *  手机号以13、15、18、170开头，8个 \d 数字字符
     *  小灵通 区号：010,020,021,022,023,024,025,027,028,029 还有未设置的新区号xxx
     */
    NSString *mobileNoRegex = @"^1((3\\d|5[0-35-9]|8[025-9])\\d|70[059])\\d{7}$"; //除4以外的所有个位整数，不能使用[^4,\\d]匹配，这里是否iOS Bug?
    NSString *phsRegex = @"^0(10|2[0-57-9]|\\d{3})\\d{7,8}$";
    
    BOOL ret = [self isValidateByRegex:mobileNoRegex];
    BOOL ret1 = [self isValidateByRegex:phsRegex];
    
    return (ret || ret1);
}

//邮箱
- (BOOL)isEmailAddress
{
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self isValidateByRegex:emailRegex];
}

//身份证号
- (BOOL)simpleVerifyIdentityCardNum
{
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    return [self isValidateByRegex:regex2];
}

//车牌
- (BOOL)isCarNumber
{
    //车牌号:湘K-DE829 香港车牌号码:粤Z-J499港
    NSString *carRegex = @"^[\u4e00-\u9fff]{1}[a-zA-Z]{1}[-][a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fff]$"; //其中\u4e00-\u9fa5表示unicode编码中汉字已编码部分，\u9fa5-\u9fff是保留部分，将来可能会添加
    return [self isValidateByRegex:carRegex];
}

- (BOOL)isMacAddress
{
    NSString *macAddRegex = @"([A-Fa-f\\d]{2}:){5}[A-Fa-f\\d]{2}";
    return [self isValidateByRegex:macAddRegex];
}

- (BOOL)isValidUrl
{
    //      NSString *regex = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSString *regex = @"^((http)|(https))+:[^\\s]+\\.[^\\s]*$";
    return [self isValidateByRegex:regex];
}

- (BOOL)isValidChinese;
{
    NSString *chineseRegex = @"^[\u4e00-\u9fa5]+$";
    return [self isValidateByRegex:chineseRegex];
}

- (BOOL)isValidPostalcode
{
    NSString *postalRegex = @"^[0-8]\\d{5}(?!\\d)$";
    return [self isValidateByRegex:postalRegex];
}

- (BOOL)isValidTaxNo
{
    NSString *taxNoRegex = @"[0-9]\\d{13}([0-9]|X)$";
    return [self isValidateByRegex:taxNoRegex];
}

- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
{
    //  [\u4e00-\u9fa5A-Za-z0-9_]{4,20}
    NSString *hanzi = containChinese ? @"\u4e00-\u9fa5" : @"";
    NSString *first = firstCannotBeDigtal ? @"^[a-zA-Z_]" : @"";
    
    NSString *regex = [NSString stringWithFormat:@"%@[%@A-Za-z0-9_]{%d,%d}", first, hanzi, (int)(minLenth - 1), (int)(maxLenth - 1)];
    return [self isValidateByRegex:regex];
}

- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLetter:(BOOL)containLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
{
    NSString *hanzi = containChinese ? @"\u4e00-\u9fa5" : @"";
    NSString *first = firstCannotBeDigtal ? @"^[a-zA-Z_]" : @"";
    NSString *lengthRegex = [NSString stringWithFormat:@"(?=^.{%@,%@}$)", @(minLenth), @(maxLenth)];
    NSString *digtalRegex = containDigtal ? @"(?=(.*\\d.*){1})" : @"";
    NSString *letterRegex = containLetter ? @"(?=(.*[a-zA-Z].*){1})" : @"";
    NSString *characterRegex = [NSString stringWithFormat:@"(?:%@[%@A-Za-z0-9%@]+)", first, hanzi, containOtherCharacter ? containOtherCharacter : @""];
    NSString *regex = [NSString stringWithFormat:@"%@%@%@%@", lengthRegex, digtalRegex, letterRegex, characterRegex];
    return [self isValidateByRegex:regex];
}

#pragma mark --- 算法相关
//精确的身份证号码有效性检测
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value
{
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length = 0;
    if (!value) {
        return NO;
    } else {
        length = (int)value.length;
        
        if (length != 15 && length != 18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray = @[ @"11", @"12", @"13", @"14", @"15", @"21", @"22", @"23", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"41", @"42", @"43", @"44", @"45", @"46", @"50", @"51", @"52", @"53", @"54", @"61", @"62", @"63", @"64", @"65", @"71", @"81", @"82", @"91" ];
    
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag = NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year = 0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6, 2)].intValue + 1900;
            
            if (year % 4 == 0 || (year % 100 == 0 && year % 4 == 0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil]; //测试出生日期的合法性
            } else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil]; //测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
							     
            if (numberofMatch > 0) {
                return YES;
            } else {
                return NO;
            }
        case 18:
            year = [value substringWithRange:NSMakeRange(6, 4)].intValue;
            if (year % 4 == 0 || (year % 100 == 0 && year % 4 == 0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil]; //测试出生日期的合法性
            } else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil]; //测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
							     
            if (numberofMatch > 0) {
                int S = ([value substringWithRange:NSMakeRange(0, 1)].intValue + [value substringWithRange:NSMakeRange(10, 1)].intValue) * 7 + ([value substringWithRange:NSMakeRange(1, 1)].intValue + [value substringWithRange:NSMakeRange(11, 1)].intValue) * 9 + ([value substringWithRange:NSMakeRange(2, 1)].intValue + [value substringWithRange:NSMakeRange(12, 1)].intValue) * 10 + ([value substringWithRange:NSMakeRange(3, 1)].intValue + [value substringWithRange:NSMakeRange(13, 1)].intValue) * 5 + ([value substringWithRange:NSMakeRange(4, 1)].intValue + [value substringWithRange:NSMakeRange(14, 1)].intValue) * 8 + ([value substringWithRange:NSMakeRange(5, 1)].intValue + [value substringWithRange:NSMakeRange(15, 1)].intValue) * 4 + ([value substringWithRange:NSMakeRange(6, 1)].intValue + [value substringWithRange:NSMakeRange(16, 1)].intValue) * 2 + [value substringWithRange:NSMakeRange(7, 1)].intValue * 1 + [value substringWithRange:NSMakeRange(8, 1)].intValue * 6 + [value substringWithRange:NSMakeRange(9, 1)].intValue * 3;
                int Y = S % 11;
                NSString *M = @"F";
                NSString *JYM = @"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y, 1)]; // 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17, 1)]]) {
                    return YES; // 检测ID的校验位
                } else {
                    return NO;
                }
                
            } else {
                return NO;
            }
        default:
            return NO;
    }
}


/** 银行卡号有效性问题Luhn算法
 *  现行 16 位银联卡现行卡号开头 6 位是 622126～622925 之间的，7 到 15 位是银行自定义的，
 *  可能是发卡分行，发卡网点，发卡序号，第 16 位是校验码。
 *  16 位卡号校验位采用 Luhm 校验方法计算：
 *  1，将未带校验位的 15 位卡号从右依次编号 1 到 15，位于奇数位号上的数字乘以 2
 *  2，将奇位乘积的个十位全部相加，再加上所有偶数位上的数字
 *  3，将加法和加上校验位能被 10 整除。
 */
- (BOOL)bankCardluhmCheck
{
    NSString *lastNum = [[self substringFromIndex:(self.length - 1)] copy];  //取出最后一位
    NSString *forwardNum = [[self substringToIndex:(self.length - 1)] copy]; //前15或18位
    
    NSMutableArray *forwardArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0; i < forwardNum.length; i++) {
        NSString *subStr = [forwardNum substringWithRange:NSMakeRange(i, 1)];
        [forwardArr addObject:subStr];
    }
    
    NSMutableArray *forwardDescArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = (int)(forwardArr.count - 1); i > -1; i--) { //前15位或者前18位倒序存进数组
        [forwardDescArr addObject:forwardArr[i]];
    }
    
    NSMutableArray *arrOddNum = [[NSMutableArray alloc] initWithCapacity:0];  //奇数位*2的积 < 9
    NSMutableArray *arrOddNum2 = [[NSMutableArray alloc] initWithCapacity:0]; //奇数位*2的积 > 9
    NSMutableArray *arrEvenNum = [[NSMutableArray alloc] initWithCapacity:0]; //偶数位数组
    
    for (int i = 0; i < forwardDescArr.count; i++) {
        NSInteger num = [forwardDescArr[i] intValue];
        if (i % 2) { //偶数位
            [arrEvenNum addObject:[NSNumber numberWithInteger:num]];
        } else { //奇数位
            if (num * 2 < 9) {
                [arrOddNum addObject:[NSNumber numberWithInteger:num * 2]];
            } else {
                NSInteger decadeNum = (num * 2) / 10;
                NSInteger unitNum = (num * 2) % 10;
                [arrOddNum2 addObject:[NSNumber numberWithInteger:unitNum]];
                [arrOddNum2 addObject:[NSNumber numberWithInteger:decadeNum]];
            }
        }
    }
    
    __block NSInteger sumOddNumTotal = 0;
    [arrOddNum enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        sumOddNumTotal += [obj integerValue];
    }];
    
    __block NSInteger sumOddNum2Total = 0;
    [arrOddNum2 enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        sumOddNum2Total += [obj integerValue];
    }];
    
    __block NSInteger sumEvenNumTotal = 0;
    [arrEvenNum enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        sumEvenNumTotal += [obj integerValue];
    }];
    
    NSInteger lastNumber = [lastNum integerValue];
    
    NSInteger luhmTotal = lastNumber + sumEvenNumTotal + sumOddNum2Total + sumOddNumTotal;
    
    return (luhmTotal%10 ==0)?YES:NO;
}

- (BOOL)isIPAddress{
    NSString *regex = [NSString stringWithFormat:@"^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL rc = [pre evaluateWithObject:self];
    
    if (rc) {
        NSArray *componds = [self componentsSeparatedByString:@","];
        
        BOOL v = YES;
        for (NSString *s in componds) {
            if (s.integerValue > 255) {
                v = NO;
                break;
            }
        }
        
        return v;
    }
    
    return NO;
}

#pragma mark -
#pragma mark :. Ruby

#pragma mark --- Private

NSString *_stringRepresentationOf(id<Concatenatable> object)
{
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        unichar c = [(NSNumber *)object charValue];
        return [NSString stringWithCharacters:&c length:1];
    } else if ([object respondsToSelector:@selector(description)]) {
        return [object description];
    } else {
        return @"";
    }
}

- (NSString *)_delete:(NSString *)first remaining:(va_list)args
{
    NSSet *comparisonSet = [self unionOfCharactersInStrings:first remaining:args];
    NSString *finalString = self;
    for (NSString *charString in comparisonSet) {
        finalString = [finalString stringByReplacingOccurrencesOfString:charString withString:@""];
    }
    return finalString;
}


#pragma mark --- Public Operator-likes

- (NSString *) : (id<Concatenatable>)concat, ...
{
    NSMutableString *newString = [NSMutableString stringWithString:self];
    va_list args;
    va_start(args, concat);
    for (id arg = concat; arg != nil; arg = va_arg(args, id<Concatenatable>)) {
        [newString appendString:_stringRepresentationOf(arg)];
    }
    va_end(args);
    
    return newString;
}

- (NSString *)x:(NSInteger)mult
{
    NSMutableString *result = [NSMutableString string];
    for (NSInteger i = 0; i < mult; i++) {
        [result appendString:self];
    }
    return result;
}

#pragma mark --- Public Shorthand Accessors
- (NSString *)ShorthandAccessors:(NSInteger)loc Len:(NSInteger)len
{
    return [self substringWithRange:NSMakeRange((loc >= 0) ? loc : self.length - labs(loc),
                                                len)];
}

- (NSString *)ShorthandAccessors:(NSInteger)start Shorthand:(char *)shorthand End:(NSInteger)end
{
    NSUInteger rstart = (start >= 0) ? start : self.length - labs(start);
    NSUInteger rend = (end >= 0) ? end : self.length - labs(end);
    if (rstart > rend)
        return nil;
    
    NSRange range = NSMakeRange(rstart, rend - rstart);
    if (strcmp(shorthand, "...") == 0) {
        return [self substringWithRange:range];
    } else if (strcmp(shorthand, "..") == 0) {
        range.length += 1;
        return [self substringWithRange:range];
    }
    return nil;
}

#pragma mark --- Public Ruby String Methods
- (void)bytes:(void (^)(unichar))block
{
    unichar *characters = calloc(self.length, sizeof(unichar));
    [self getCharacters:characters];
    for (NSInteger i = 0; i < self.length; i++) {
        block(characters[i]);
    }
    free(characters);
}

- (NSString *)center:(NSInteger)amount
{
    return [self center:amount with:@" "];
}

- (NSString *)center:(NSInteger)amount with:(NSString *)padString
{
    if (amount <= self.length)
        return self;
    NSInteger padamount = floor((amount - self.length) / 2);
    NSString *pad = @"";
    NSInteger c = 0;
    for (NSInteger i = 0; i < padamount; i++) {
        pad = [NSString stringWithFormat:@"%@%c", pad, [padString characterAtIndex:c++]];
        if (c >= padString.length)
            c = 0;
    }
    NSString *result = [NSString stringWithFormat:@"%@%@%@", pad, self, pad];
    return (result.length == amount) ? result : [NSString stringWithFormat:@"%@%c", result, [padString characterAtIndex:c]];
}

- (void)chars:(void (^)(unichar))block
{
    unichar *characters = calloc(self.length, sizeof(unichar));
    [self getCharacters:characters];
    for (NSInteger i = 0; i < self.length; i++) {
        unichar character = [self characterAtIndex:i];
        block(character);
    }
    free(characters);
}

- (NSString *)chomp
{
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self characterAtIndex:self.length - 1]]) {
        return [self substringWithRange:NSMakeRange(0, self.length - 1)];
    }
    return self;
}

- (NSString *)chomp:(NSString *)string
{
    return [self stringByReplacingOccurrencesOfString:string
                                           withString:@""
                                              options:0
                                                range:NSMakeRange(self.length - string.length,
                                                                  string.length)];
}

- (NSString *)chop
{
    return [self substringWithRange:NSMakeRange(0, self.length - ((self.length > 0) ? 1 : 0))];
}

- (NSString *)chr
{
    return [self substringWithRange:NSMakeRange(0, (self.length > 0) ? 1 : 0)];
}

- (void)codePoints:(void (^)(NSInteger))block
{
    unichar *characters = calloc(self.length, sizeof(unichar));
    [self getCharacters:characters];
    for (NSInteger i = 0; i < self.length; i++) {
        NSInteger codepoint = (NSInteger)[self characterAtIndex:i];
        block(codepoint);
    }
    free(characters);
}

- (NSString *)concat:(id)concat
{
    return [self stringByAppendingString:concat];
}

- (NSInteger)count:(NSString *)first, ...
{
    va_list args;
    va_start(args, first);
    NSSet *comparisonSet = [self unionOfCharactersInStrings:first remaining:args];
    va_end(args);
    NSInteger count = 0;
    for (NSString *charString in comparisonSet) {
        count += [self occurencesOf:charString];
    }
    return count;
}

- (NSString *) delete:(NSString *)first, ...
{
    va_list args;
    va_start(args, first);
    NSString *result = [self _delete:first remaining:args];
    va_end(args);
    return result;
}

- (BOOL)endsWith:(NSString *)first, ...
{
    va_list args;
    va_start(args, first);
    for (NSString *arg = first; arg != nil; arg = va_arg(args, NSString *)) {
        NSRange range = [self rangeOfString:arg];
        if (range.location + range.length == self.length)
            return true;
    }
    va_end(args);
    return false;
}

- (long)hex
{
    unsigned outVal = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner scanHexInt:&outVal];
    return (long)outVal;
}

- (BOOL)includes:(NSString *)include
{
    return [self rangeOfString:include].location != NSNotFound;
}

- (NSInteger)index:(NSString *)pattern
{
    return [self index:pattern offset:0];
}

- (NSInteger)index:(NSString *)pattern offset:(NSInteger)offset
{
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        NSUInteger loc = (offset >= 0) ? offset : self.length - labs(offset);
        NSUInteger len = self.length - loc;
        NSRange range = NSMakeRange(loc, len);
        NSTextCheckingResult *result = [regex firstMatchInString:self options:0 range:range];
        return (result.range.length > 0) ? result.range.location : NSNotFound;
    }
    return NSNotFound;
}

- (NSString *)insert:(NSInteger)index string:(NSString *)string
{
    if (index < 0)
        index = self.length - labs(index) + 1;
    else if (index >= self.length)
        index = self.length;
    return [NSString stringWithFormat:@"%@%@%@", [self substringToIndex:index], string, [self substringFromIndex:index]];
}

- (NSString *)inspect;
{
    NSMutableString *result = [self mutableCopy];
    NSRange stringRange = NSMakeRange(0, [self length]);
    
    [@{
       @"\0" : @"\\0",
       @"\a" : @"\\a",
       @"\b" : @"\\b",
       @"\t" : @"\\t",
       @"\n" : @"\\n",
       @"\f" : @"\\f",
       @"\r" : @"\\r",
       @"\e" : @"\\e",
       } enumerateKeysAndObjectsUsingBlock:^(NSString *string, NSString *replacement, BOOL *stop) {
           [result replaceOccurrencesOfString:string withString:replacement options:0 range:stringRange];
       }];
    
    return [NSString stringWithFormat:@"\"%@\"", result];
}

- (BOOL)isASCII
{
    unichar *characters = calloc(self.length, sizeof(unichar));
    [self getCharacters:characters];
    for (NSInteger i = 0; i < self.length; i++) {
        if (characters[i] < 32 || characters[i] > 127) {
            free(characters);
            return NO;
        }
    }
    free(characters);
    return YES;
}

- (BOOL)isEmpty
{
    return self.length == 0;
}

- (NSInteger)lastIndex:(NSString *)pattern
{
    return [self lastIndex:pattern offset:0];
}

- (NSInteger)lastIndex:(NSString *)pattern offset:(NSInteger)offset
{
    offset = labs(offset); //lets allow for negative and positive inputs
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        NSTextCheckingResult *result = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length - offset)].lastObject;
        return (result.range.length > 0) ? result.range.location : NSNotFound;
    }
    return NSNotFound;
}

- (NSString *)leftJustify:(NSInteger)amount
{
    return [self leftJustify:amount with:@" "];
}

- (NSString *)leftJustify:(NSInteger)amount with:(NSString *)padString
{
    if (amount <= self.length)
        return self;
    NSString *pad = @"";
    NSInteger c = 0;
    for (NSInteger i = 0; i < amount - self.length; i++) {
        pad = [NSString stringWithFormat:@"%@%c", pad, [padString characterAtIndex:c++]];
        if (c >= padString.length)
            c = 0;
    }
    NSString *result = [NSString stringWithFormat:@"%@%@", self, pad];
    return result;
}

- (NSString *)leftStrip
{
    NSInteger i;
    for (i = 0; i < self.length; i++) {
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self characterAtIndex:i]])
            break;
    }
    return [self stringByReplacingCharactersInRange:NSMakeRange(0, i) withString:@""];
}

- (void)lines:(void (^)(NSString *))block
{
    [self lines:block separator:@"\n"];
}

- (void)lines:(void (^)(NSString *))block separator:(NSString *)separator
{
    NSArray *lines = [self componentsSeparatedByString:separator];
    for (NSString *line in lines) {
        block(line);
    }
}

- (NSArray *)match:(NSString *)pattern
{
    return [self match:pattern offset:0];
}

- (NSArray *)match:(NSString *)pattern offset:(NSInteger)offset
{
    NSMutableArray *results = [NSMutableArray array];
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (error)
        return nil;
    
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(offset, self.length - offset)];
    for (NSTextCheckingResult *match in matches) {
        //we want to honor capture groups, the obj-c way is.. -_-,
        //skip the first match, it's most probably not correct
        if (match.numberOfRanges > 1) {
            for (NSInteger i = 1; i < match.numberOfRanges; i++) {
                [results addObject:[self substringWithRange:[match rangeAtIndex:i]]];
            }
        } else {
            [results addObject:[self substringWithRange:match.range]];
        }
    }
    return results;
}

- (NSInteger)occurencesOf:(NSString *)subString
{
    NSUInteger cnt = 0, length = [self length];
    NSRange range = NSMakeRange(0, length);
    while (range.location != NSNotFound) {
        range = [self rangeOfString:subString options:0 range:range];
        if (range.location != NSNotFound) {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            cnt++;
        }
    }
    return cnt;
}

- (long)octal
{
    long result = strtol(self.UTF8String, NULL, 8);
    return result;
}

- (NSInteger)ordinal
{
    return (NSInteger)[self characterAtIndex:0];
}

- (NSArray *)partition:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (error)
        return @[];
    
    NSTextCheckingResult *result = [regex firstMatchInString:self options:0 range:self.range];
    if (!result)
        return @[ self, @"", @"" ];
    
    NSString *first = [self substringWithRange:NSMakeRange(0, result.range.location)];
    NSString *middle = [self substringWithRange:result.range];
    NSString *last = [self substringWithRange:NSMakeRange(result.range.location + result.range.length,
                                                          self.length - (result.range.location + result.range.length))];
    return @[ first, middle, last ];
}

- (NSString *)prepend:(NSString *)prefix
{
    return [NSString stringWithFormat:@"%@%@", prefix, self];
}

- (NSRange)range
{
    return NSMakeRange(0, self.length);
}

- (NSString *)reverse
{
    NSMutableString *reversedStr = [NSMutableString stringWithCapacity:self.length];
    
    for (NSInteger i = self.length - 1; i >= 0; i--)
        [reversedStr appendString:[NSString stringWithFormat:@"%c", [self characterAtIndex:i]]];
    
    return reversedStr;
}

- (NSInteger)rightIndex:(NSString *)pattern
{
    return [self index:pattern offset:0];
}

- (NSInteger)rightIndex:(NSString *)pattern offset:(NSInteger)offset
{
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        NSInteger loc = (offset >= 0) ? offset : self.length - labs(offset);
        NSInteger len = self.length - loc;
        NSRange range = NSMakeRange(0, len);
        NSTextCheckingResult *result = [regex matchesInString:self options:0 range:range].lastObject;
        return (result.range.length > 0) ? result.range.location : NSNotFound;
    }
    return NSNotFound;
}

- (NSString *)rightJustify:(NSInteger)amount
{
    return [self rightJustify:amount with:@" "];
}

- (NSString *)rightJustify:(NSInteger)amount with:(NSString *)padString
{
    if (amount <= self.length)
        return self;
    NSString *pad = [@"" stringByPaddingToLength:amount - self.length withString:padString startingAtIndex:0];
    return [pad:self, nil];
}

- (NSArray *)rightPartition:(NSString *)pattern
{
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (error)
        return @[];
    
    NSTextCheckingResult *result = [regex matchesInString:self options:0 range:self.range].lastObject;
    if (!result)
        return @[ @"", @"", self ];
    
    NSString *first = [self substringWithRange:NSMakeRange(0, result.range.location)];
    NSString *middle = [self substringWithRange:result.range];
    NSString *last = [self substringWithRange:NSMakeRange(result.range.location + result.range.length,
                                                          self.length - (result.range.location + result.range.length))];
    return @[ first, middle, last ];
}

- (NSString *)rightStrip
{
    NSInteger i;
    for (i = self.length - 1; i > 0; i--) {
        if (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self characterAtIndex:i]])
            break;
    }
    return [self stringByReplacingCharactersInRange:NSMakeRange(i + 1, self.length - 1 - i) withString:@""];
}

- (NSArray *)scan:(NSString *)pattern
{
    NSMutableArray *strings = [NSMutableArray array];
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (error)
        return @[];
    
    NSArray *results = [regex matchesInString:self options:0 range:self.range];
    for (NSTextCheckingResult *result in results) {
        [strings addObject:[self substringWithRange:result.range]];
    }
    return [NSArray arrayWithArray:strings];
}

- (BOOL)startsWith:(NSString *)first, ...
{
    va_list args;
    va_start(args, first);
    for (NSString *arg = first; arg != nil; arg = va_arg(args, NSString *)) {
        if ([self rangeOfString:arg].location == 0)
            return true;
    }
    va_end(args);
    return false;
}

- (NSString *)strip
{
    return [[self leftStrip] rightStrip];
}

- (NSArray *)split
{
    return [self split:@" "];
}

- (NSArray *)split:(NSString *)pattern
{
    return [self split:pattern limit:INT_MAX];
}

- (NSArray *)split:(NSString *)pattern limit:(NSInteger)limit
{
    NSString *str = self;
    
    //if limit is negative, dont suppress fields and return all fields
    if (limit < 0)
        limit = INT_MAX - 1;
    
    NSMutableArray *strings = [NSMutableArray array];
    //if splitting on nothing, just split every character
    if (pattern.length == 0) {
        for (NSInteger i = 0; i < MIN(limit - 1, str.length); i++) {
            [strings addObject:[NSString stringWithFormat:@"%c", [str characterAtIndex:i]]];
        }
        if (strings.count < str.length)
            [strings addObject:[str substringWithRange:NSMakeRange(strings.count, str.length - strings.count)]];
        return strings;
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (error)
        return @[];
    
    //remove leading/trailing/continuous whitespace if we're splitting on whitespace
    if ([pattern isEqualToString:@" "])
        str = [[self strip] squeeze:@" "];
    
    NSArray *matches = [regex matchesInString:str options:0 range:str.range];
    NSInteger loc = 0;
    for (NSTextCheckingResult *result in matches) {
        NSString *s = [str substringWithRange:NSMakeRange(loc, result.range.location - loc)];
        if (result.range.length > 0 || s.length > 0)
            [strings addObject:s];
        loc = result.range.location + result.range.length;
        if (strings.count >= limit - 1)
            break;
    }
    NSString *s = [str substringWithRange:NSMakeRange(loc, str.length - loc)];
    if (s.length > 0 || limit == INT_MAX - 1)
        [strings addObject:s];
    
    //if limit isn't specified, suppress trailing nulls
    if (limit == INT_MAX && [[strings lastObject] length] == 0)
        [strings removeLastObject];
    return strings;
}

- (NSString *)squeeze
{
    return [self squeeze:@"."];
}

- (NSString *)squeeze:(NSString *)pattern
{
    NSMutableString *s = [NSMutableString string];
    NSString *wrapped = [NSString stringWithFormat:@"(%@)\\1+", pattern];
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:wrapped
                                                                      options:0
                                                                        error:&error];
    if (error)
        return nil;
    NSArray *matches = [regex matchesInString:self options:0 range:self.range];
    NSInteger loc = 0;
    for (NSTextCheckingResult *result in matches) {
        [s appendString:[self substringWithRange:NSMakeRange(loc, result.range.location - loc)]];
        loc = result.range.location + result.range.length;
        [s appendFormat:@"%c", [self characterAtIndex:result.range.location]];
    }
    [s appendString:[self substringWithRange:NSMakeRange(loc, self.length - loc)]];
    return s;
}

- (NSString *)substituteFirst:(NSString *)pattern with:(NSString *)sub
{
    NSString *result = self;
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        NSTextCheckingResult *match = [regex firstMatchInString:self options:0 range:self.range];
        result = [result stringByReplacingCharactersInRange:match.range withString:sub];
    }
    return result;
}

- (NSString *)substituteLast:(NSString *)pattern with:(NSString *)sub
{
    NSString *result = self;
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        NSTextCheckingResult *match = [regex matchesInString:self options:0 range:self.range].lastObject;
        result = [result stringByReplacingCharactersInRange:match.range withString:sub];
    }
    return result;
}

- (NSString *)substituteAll:(NSDictionary *)subDictionary
{
    NSString *result = self;
    for (NSString *key in [subDictionary allKeys]) {
        NSRange range = [self rangeOfString:key];
        if (range.location != NSNotFound)
            result = [result stringByReplacingOccurrencesOfString:key withString:[subDictionary objectForKey:key]];
    }
    return result;
}

- (NSString *)substituteAll:(NSString *)pattern with:(NSString *)sub
{
    NSString *result = self;
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                      options:0
                                                                        error:&error];
    if (!error) {
        NSArray *matches = [regex matchesInString:self options:0 range:self.range];
        for (NSTextCheckingResult *match in matches) {
            result = [result stringByReplacingCharactersInRange:match.range withString:sub];
        }
    }
    return result;
}

- (NSInteger)sum
{
    return [self sum:16];
}

- (NSInteger)sum:(NSInteger)bit
{
    __block NSInteger total = 0;
    [self chars:^(unichar c) {
        total += (NSInteger )c;
    }];
    return (total % (NSInteger)pow(2, bit - 1));
}

- (NSString *)swapcase
{
    unichar *s = calloc(self.length, sizeof(unichar));
    [self getCharacters:s];
    for (NSInteger i = 0; i < self.length; i++) {
        if (s[i] >= 64 && s[i] <= 90)
            s[i] = s[i] + 32;
        else if (s[i] >= 97 && s[i] <= 122)
            s[i] = s[i] - 32;
    }
    return [NSString stringWithCharacters:s length:self.length];
}

#pragma mark --- Subscript Protocol Methods

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    if (index > self.length - 1)
        return nil;
    unichar character = [self characterAtIndex:index];
    return [NSString stringWithCharacters:&character length:1];
}

- (id)objectForKeyedSubscript:(id)key
{
    if ([key isKindOfClass:[NSString class]]) { //if it's a string, assume a regex.
        NSError *error = nil;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:key
                                                                          options:0
                                                                            error:&error];
        if (error)
            return nil;
        NSTextCheckingResult *result = [regex firstMatchInString:self options:0 range:self.range];
        if (result)
            return [self substringWithRange:result.range];
    } else if ([key isKindOfClass:[NSArray class]]) {
        NSInteger loc = [key[0] intValue];
        NSInteger len = [key[1] intValue];
        return [self substringWithRange:NSMakeRange((loc > 0) ? loc : self.length - labs(loc),
                                                    len)];
    }
    return nil;
}

#pragma mark --- Helper Methods
- (NSSet *)unionOfCharactersInStrings:(NSString *)first remaining:(va_list)va_list
{
    NSMutableArray *sets = [NSMutableArray array];
    NSMutableSet *negateSet = [NSMutableSet set];
    for (NSString *arg = first; arg != nil; arg = va_arg(va_list, NSString *)) {
        NSMutableSet *argSet = [NSMutableSet set];
        NSString *cleanedArg = [arg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        unichar *characters = calloc(cleanedArg.length, sizeof(unichar));
        [cleanedArg getCharacters:characters];
        if (characters[0] == '^') {
            for (NSInteger i = 1; i < cleanedArg.length; i++) {
                [negateSet addObject:[NSString stringWithCharacters:&characters[i] length:1]];
            }
        } else {
            for (NSInteger i = 0; i < cleanedArg.length; i++) {
                if (characters[i] == '-') {
                    for (NSInteger j = characters[i - 1]; j < characters[i + 1]; j++) {
                        unichar c = (unichar)j;
                        [argSet addObject:[NSString stringWithCharacters:&c length:1]];
                    }
                } else {
                    [argSet addObject:[NSString stringWithCharacters:&characters[i] length:1]];
                }
            }
            [sets addObject:argSet];
        }
        free(characters);
    }
    va_end(va_list);
    NSMutableSet *comparisonSet = [sets objectAtIndex:0];
    for (NSMutableSet *set in sets) {
        [comparisonSet intersectSet:set];
    }
    [comparisonSet minusSet:negateSet];
    return comparisonSet;
}

#pragma mark-
#pragma mark :. Scire

- (CGFloat)scoreAgainst:(NSString *)otherString
{
    return [self scoreAgainst:otherString fuzziness:nil];
}

- (CGFloat)scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness
{
    return [self scoreAgainst:otherString fuzziness:fuzziness options:NSStringScoreOptionNone];
}

- (CGFloat)scoreAgainst:(NSString *)anotherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options
{
    NSMutableCharacterSet *workingInvalidCharacterSet = [NSMutableCharacterSet lowercaseLetterCharacterSet];
    [workingInvalidCharacterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [workingInvalidCharacterSet addCharactersInString:@" "];
    NSCharacterSet *invalidCharacterSet = [workingInvalidCharacterSet invertedSet];
    
    NSString *string = [[[self decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
    NSString *otherString = [[[anotherString decomposedStringWithCanonicalMapping] componentsSeparatedByCharactersInSet:invalidCharacterSet] componentsJoinedByString:@""];
    
    // If the string is equal to the abbreviation, perfect match.
    if ([string isEqualToString:otherString]) return (CGFloat)1.0f;
    
    //if it's not a perfect match and is empty return 0
    if ([otherString length] == 0) return (CGFloat)0.0f;
    
    CGFloat totalCharacterScore = 0;
    NSUInteger otherStringLength = [otherString length];
    NSUInteger stringLength = [string length];
    BOOL startOfStringBonus = NO;
    CGFloat otherStringScore;
    CGFloat fuzzies = 1;
    CGFloat finalScore;
    
    // Walk through abbreviation and add up scores.
    for (uint index = 0; index < otherStringLength; index++) {
        CGFloat characterScore = 0.1;
        NSInteger indexInString = NSNotFound;
        NSString *chr;
        NSRange rangeChrLowercase;
        NSRange rangeChrUppercase;
        
        chr = [otherString substringWithRange:NSMakeRange(index, 1)];
        
        //make these next few lines leverage NSNotfound, methinks.
        rangeChrLowercase = [string rangeOfString:[chr lowercaseString]];
        rangeChrUppercase = [string rangeOfString:[chr uppercaseString]];
        
        if (rangeChrLowercase.location == NSNotFound && rangeChrUppercase.location == NSNotFound) {
            if (fuzziness) {
                fuzzies += 1 - [fuzziness floatValue];
            } else {
                return 0; // this is an error!
            }
            
        } else if (rangeChrLowercase.location != NSNotFound && rangeChrUppercase.location != NSNotFound) {
            indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
            
        } else if (rangeChrLowercase.location != NSNotFound || rangeChrUppercase.location != NSNotFound) {
            indexInString = rangeChrLowercase.location != NSNotFound ? rangeChrLowercase.location : rangeChrUppercase.location;
            
        } else {
            indexInString = MIN(rangeChrLowercase.location, rangeChrUppercase.location);
        }
        
        // Set base score for matching chr
        
        // Same case bonus.
        if (indexInString != NSNotFound && [[string substringWithRange:NSMakeRange(indexInString, 1)] isEqualToString:chr]) {
            characterScore += 0.1;
        }
        
        // Consecutive letter & start-of-string bonus
        if (indexInString == 0) {
            // Increase the score when matching first character of the remainder of the string
            characterScore += 0.6;
            if (index == 0) {
                // If match is the first character of the string
                // & the first character of abbreviation, add a
                // start-of-string match bonus.
                startOfStringBonus = YES;
            }
        } else if (indexInString != NSNotFound) {
            // Acronym Bonus
            // Weighing Logic: Typing the first character of an acronym is as if you
            // preceded it with two perfect character matches.
            if ([[string substringWithRange:NSMakeRange(indexInString - 1, 1)] isEqualToString:@" "]) {
                characterScore += 0.8;
            }
        }
        
        // Left trim the already matched part of the string
        // (forces sequential matching).
        if (indexInString != NSNotFound) {
            string = [string substringFromIndex:indexInString + 1];
        }
        
        totalCharacterScore += characterScore;
    }
    
    if (NSStringScoreOptionFavorSmallerWords == (options & NSStringScoreOptionFavorSmallerWords)) {
        // Weigh smaller words higher
        return totalCharacterScore / stringLength;
    }
    
    otherStringScore = totalCharacterScore / otherStringLength;
    
    if (NSStringScoreOptionReducedLongStringPenalty == (options & NSStringScoreOptionReducedLongStringPenalty)) {
        // Reduce the penalty for longer words
        CGFloat percentageOfMatchedString = otherStringLength / stringLength;
        CGFloat wordScore = otherStringScore * percentageOfMatchedString;
        finalScore = (wordScore + otherStringScore) / 2;
        
    } else {
        finalScore = ((otherStringScore * ((CGFloat)(otherStringLength) / (CGFloat)(stringLength))) + otherStringScore) / 2;
    }
    
    finalScore = finalScore / fuzzies;
    
    if (startOfStringBonus && finalScore + 0.15 < 1) {
        finalScore += 0.15;
    }
    
    return finalScore;
}


@end


#pragma mark - NSMutableString
@implementation NSMutableString (Additions)

- (NSString *)capitalizeInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self capitalizedString]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)chompInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self chomp]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)chompInPlace:(NSString *)string
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self chomp:string]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)chopInPlace
{
    [self setString:[self chop]];
    return self;
}

- (NSString *)deleteInPlace:(NSString *)first, ...
{
    NSString *oldString = [NSString stringWithString:self];
    va_list args;
    va_start(args, first);
    [self setString:[self _delete:first remaining:args]];
    va_end(args);
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)lowercaseInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self lowercaseString]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)substituteAllInPlace:(NSDictionary *)subDictionary
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self substituteAll:subDictionary]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)substituteAllInPlace:(NSString *)pattern with:(NSString *)sub
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self substituteAll:pattern with:sub]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)leftStripInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self leftStrip]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)reverseInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self reverse]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)rightStripInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self rightStrip]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)squeezeInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self squeeze]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)squeezeInPlace:(NSString *)pattern
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self squeeze:pattern]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)stripInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self strip]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)substituteFirstInPlace:(NSString *)pattern with:(NSString *)sub
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self substituteFirst:pattern with:sub]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)substituteLastInPlace:(NSString *)pattern with:(NSString *)sub
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self substituteLast:pattern with:sub]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)swapcaseInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self swapcase]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

- (NSString *)uppercaseInPlace
{
    NSString *oldString = [NSString stringWithString:self];
    [self setString:[self uppercaseString]];
    if ([oldString isEqualToString:self]) {
        return nil;
    } else {
        return self;
    }
}

@end

