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

#import "NSString+BNSString.h"
#import <CommonCrypto/CommonCrypto.h>
#import "CCBase64.h"

@implementation NSString (BNSString)

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
    [strM replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, strM.length)];
    return strM;
}

#pragma mark - 校验
/**
 *  @author CC, 2015-07-21
 *
 *  @brief  验证手机号码
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (BOOL)validateMobileNumber
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";

    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];

    if (([regextestmobile evaluateWithObject:self] == YES) || ([regextestcm evaluateWithObject:self] == YES) || ([regextestct evaluateWithObject:self] == YES) || ([regextestcu evaluateWithObject:self] == YES)){
        if([regextestcm evaluateWithObject:self] == YES)
            NSLog(@"China Mobile");
        else if([regextestct evaluateWithObject:self] == YES)
            NSLog(@"China Telecom");
        else if ([regextestcu evaluateWithObject:self] == YES)
            NSLog(@"China Unicom");
        else
            NSLog(@"Unknow");
        return YES;
    }else
        return NO;
}

/**
 *  @author CC, 2015-07-21
 *
 *  @brief  验证邮件地址
 *
 *  @return <#return value description#>
 *
 *  @since <#version number#>
 */
- (BOOL)validateEmailAddress
{
    NSString *emailCheck = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}";
    NSPredicate *emailMatch = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailCheck];
    if (![emailMatch evaluateWithObject:self])
        return NO;

    return YES;
}

/**
 *  @author CC, 15-09-02
 *
 *  @brief  验证HTTP网址
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (BOOL)validateHttpURL
{
    NSString *regex =@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlMatch = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if (![urlMatch evaluateWithObject:self])
        return NO;

    return YES;
}

/**
 *  @author CC, 2015-06-03
 *
 *  @brief  身份证校验
 *
 *  @param value value description
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (BOOL)validateIDCardNumber{
    NSString *value = self;

    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    int length = 0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;

        if (length !=15 && length !=18)
            return NO;
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];

    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag = NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }

    if (!areaFlag)
        return NO;


    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;

    int year =0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;

            if (year %4 ==0 || (year %100 ==0 && year %4 ==0))
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            else
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性

            numberofMatch = [regularExpression numberOfMatchesInString:value options:NSMatchingReportProgress range:NSMakeRange(0, value.length)];

            if(numberofMatch > 0)
                return YES;
            else
                return NO;
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0))
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            else
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性

            numberofMatch = [regularExpression numberOfMatchesInString:value options:NSMatchingReportProgress range:NSMakeRange(0, value.length)];

            if(numberofMatch >0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;

                int Y = S % 11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";

                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]])
                    return YES;// 检测ID的校验位
                else
                    return NO;
            }else
                return NO;
        default:
            return NO;
    }
}

#pragma mark - 转换

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
- (NSString*)decodeBase64String
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
 *  @author CC, 2015-07-22
 *
 *  @brief  转换货币格式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)convertingCurrencyFormat{
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
    return [NSJSONSerialization JSONObjectWithData:[self convertingData] options:NSJSONReadingAllowFragments error:nil];
}

#pragma mark - 取值
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

#pragma mark - 加密
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
    if(self.length == 0)
        return nil;

    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);

    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
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

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
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

    NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }

    return [result copy];
}

#pragma mark - 文件
/**
 *  @author CC, 15-08-21
 *
 *  @brief  document根文件夹
 *
 *  @return 返回文件夹路径
 *
 *  @since 1.0
 */
+(NSString *)documentFolder
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
+(NSString *)cachesFolder
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 *  @author CC, 15-08-21
 *
 *  @brief  生成子文件夹(如果子文件夹不存在，则直接创建；如果已经存在，则直接返回)
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 返回文件夹路径
 *
 *  @since 1.0
 */
-(NSString *)createSubFolder:(NSString *)subFolder
{
    NSString *subFolderPath=[NSString stringWithFormat:@"%@/%@",self,subFolder];

    BOOL isDir = NO;

    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL existed = [fileManager fileExistsAtPath:subFolderPath isDirectory:&isDir];

    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:subFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return subFolderPath;

}

@end
