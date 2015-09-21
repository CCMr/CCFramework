//
//  NSString+BNSString.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (BNSString)

/**
 *  @author CC, 15-09-02
 *
 *  @brief  去除所有空格
 *
 *  @return 返回当前字符串
 *
 *  @since 1.0
 */
- (NSString *)deleteSpace;

#pragma mark - 校验
/**
 *  @author C C, 2015-07-21
 *
 *  @brief  验证手机号码
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (BOOL)validateMobileNumber;
/**
 *  @author C C, 2015-07-21
 *
 *  @brief  验证邮件地址
 *
 *  @return <#return value description#>
 *
 *  @since <#version number#>
 */
- (BOOL)validateEmailAddress;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  验证HTTP网址
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (BOOL)validateHttpURL;

#pragma mark - 转换
/**
 *  @author C C, 2015-07-21
 *
 *  @brief  字符串转换日期
 *
 *  @param strFormat 字符串格式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSDate *)convertingStringsToDate:(NSString *)strFormat;

/**
 *  @author C C, 2015-07-22 
 *
 *  @brief  转换货币格式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSString *)convertingCurrencyFormat;

/**
 *  @author CC, 15-08-27
 *
 *  @brief  字符串解码Image
 *
 *  @return 返回解码之后Image
 *
 *  @since <#1.0#>
 */
- (UIImage *)decodedImage;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  转换Data
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (NSData *)convertingData;

/**
 *  @author CC, 15-09-21
 *
 *  @brief  序列化Json
 *
 *  @return 返回对象键值
 */
- (NSDictionary *)serialization;

#pragma mark - 取值
/**
 *  @author CC, 15-08-14
 *
 *  @brief  获取字符串的行数
 *
 *  @return 返回多少行
 *
 *  @since 1.0
 */
- (NSInteger)numberOfLines;

#pragma mark - 加密
/**
 *  @author C C, 15-08-17
 *
 *  @brief  MD5Hash加密
 *
 *  @return <#return value description#>
 *
 *  @since <#1.0#>
 */
- (NSString *)MD5Hash;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  MD5 32位加密
 *
 *  @return 返回加密字符串
 *
 *  @since 1.0
 */
- (NSString *)MD532;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  SHA加密
 *
 *  @return 返回加密字符串
 *
 *  @since 1.0
 */
- (NSString *)SHA;

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
+(NSString *)documentFolder;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  caches根文件夹
 *
 *  @return 返回文件夹路径
 *
 *  @since 1.0
 */
+(NSString *)cachesFolder;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  生成子文件夹(如果子文件夹不存在，则直接创建；如果已经存在，则直接返回)
 *
 *  @param subFolder 子文件夹名
 *
 *  @return 返回文件夹路径
 *
 *  @since <#1.0#>
 */
-(NSString *)createSubFolder:(NSString *)subFolder;
@end
