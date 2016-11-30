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

@protocol Concatenatable <NSObject>
@end

@interface NSString () <NSXMLParserDelegate>

@property(nonatomic, retain) NSMutableArray *currentDictionaries;
@property(nonatomic, retain) NSMutableString *currentText;


@end

@interface NSString (Additions)

/**
 *  @brief  获取随机 UUID 例如 E621E1F8-C36C-495A-93FC-0C247A3E6E5F
 *
 *  @return 随机 UUID
 */
+ (NSString *)UUID;

/**
 *
 *  @brief  毫秒时间戳 例如 1443066826371
 *
 *  @return 毫秒时间戳
 */
+ (NSString *)UUIDTimestamp;

/**
 *  @author CC, 2015-12-11
 *
 *  @brief  根据值生成唯一ID
 */
- (NSString *)pathForTemporaryFileWithPrefix;

/**
 *  @brief  JSON字符串转成对象
 */
- (id)JSONValue;

#pragma mark -
#pragma mark :. IPAddress

/**
 *  @author C C, 2016-09-27
 *  
 *  @brief  获取IP地址
 *
 *  @param preferIPv4 是否IPV4
 */
+ (NSString *)obtainIPAddress:(BOOL)preferIPv4;

/**
 *  @author C C, 2016-09-27
 *  
 *  @brief  判断IP地址
 *
 *  @param ipAddress IP地址
 */
+ (BOOL)isValidatIP:(NSString *)ipAddress;

/**
 *  @author C C, 2016-09-27
 *  
 *  @brief  获取设置所有IP
 */
+ (NSDictionary *)obtainIPAddresses;

#pragma mark -
#pragma mark :. QueryDictionary
/**
 *  @return If the receiver is a valid URL query component, returns
 *  components as key/value pairs. If couldn't split into *any* pairs,
 *  returns nil.
 */
- (NSDictionary *)cc_URLQueryDictionary;

#pragma mark -
#pragma mark :. XML

/**
 *  @brief  xml字符串转换成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryFromXML;

#pragma mark--- 转换

/**
 *  @author CC, 15-09-25
 *
 *  @brief  base64编码
 */
- (NSString *)encodeBase64String;

/**
 *  @author CC, 15-09-25
 *
 *  @brief  base64解码
 */
- (NSString *)decodeBase64String;

/**
 *  @author C C, 2015-07-21
 *
 *  @brief  字符串转换日期
 *
 *  @param strFormat 字符串格式
 */
- (NSDate *)convertingStringsToDate:(NSString *)strFormat;

/**
 *  @author CC, 2015-12-02
 *
 *  @brief  字符串转换日期带'T'
 */
- (NSDate *)convertingTStringsToDate;

/**
 *  @author C C, 2015-07-22
 *
 *  @brief  转换货币格式
 */
- (NSString *)convertingCurrencyFormat;

/**
 *  @author CC, 15-08-27
 *
 *  @brief  字符串解码Image
 */
- (UIImage *)decodedImage;

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  生成二维码图像
 *
 *  @param size  图像大小
 */
- (UIImage *)becomeQRCodeWithQRstring:(float)size;

/**
 生成二维码中间带头像
 
 @param size 生成大小
 @param avatar 头像
 */
- (UIImage *)becomeQRCodeWithQRstring:(float)size 
                          AvatarImage:(UIImage *)avatar;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  转换Data
 */
- (NSData *)convertingData;

/**
 *  @author CC, 15-09-22
 *
 *  @brief  转换64位字符串
 */
- (NSData *)convertingBase64Encoded;

/**
 *  @author CC, 15-09-21
 *
 *  @brief  序列化Json
 */
- (NSDictionary *)serialization;

#pragma mark--- 取值
/**
 *  @author CC, 15-08-14
 *
 *  @brief  获取字符串的行数
 */
- (NSInteger)numberOfLines;

/**
 *  @author CC, 16-02-02
 *
 *  @brief 计算文字长宽
 *
 *  @param MaxWith 最大宽度
 *  @param font    字体
 */
- (CGSize)calculateTextWidthWidth:(CGFloat)MaxWith
                             Font:(UIFont *)font;

/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/**
 *  @brief 计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width;

/**
 *  @brief 计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height;

/**
 *  @brief  反转字符串
 *
 *  @param strSrc 被反转字符串
 *
 *  @return 反转后字符串
 */
+ (NSString *)reverseString:(NSString *)strSrc;

#pragma mark--- 加密
/**
 *  @author C C, 15-08-17
 *
 *  @brief  MD5Hash加密
 */
- (NSString *)MD5Hash;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  MD5 32位加密
 */
- (NSString *)MD532;

/**
 *  @author CC, 15-09-02
 *
 *  @brief  SHA加密
 */
- (NSString *)SHA;

#pragma mark--- 文件
/**
 *  @author CC, 15-08-21
 *
 *  @brief  document根文件夹
 */
+ (NSString *)documentFolder;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  caches根文件夹
 */
+ (NSString *)cachesFolder;

/**
 *  @author CC, 15-08-21
 *
 *  @brief  生成子文件夹(如果子文件夹不存在，则直接创建；如果已经存在，则直接返回)
 *
 *  @param subFolder 子文件夹名
 */
- (NSString *)createSubFolder:(NSString *)subFolder;

#pragma mark -
#pragma mark :. 处理

/**
 *  @author CC, 2015-10-20
 *
 *  @brief  拼接字符串
 *
 *  @param format 多个参数
 */
- (NSString *)appendFormats:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

/**
 *  @author CC, 2015-10-20
 *
 *  @brief  添加字符串
 *
 *  @param aString 字符喘
 */
- (NSString *)appendStrings:(NSString *)aString;

/**
 *  @brief  清除html标签
 *
 *  @return 清除后的结果
 */
- (NSString *)stringByStrippingHTML;

/**
 *  @brief  清除js脚本
 *
 *  @return 清楚js后的结果
 */
- (NSString *)stringByRemovingScriptsAndStrippingHTML;

/**
 *  @brief  去除空格
 *
 *  @return 去除空格后的字符串
 */
- (NSString *)trimmingWhitespace;

/**
 *  @brief  去除字符串与空行
 *
 *  @return 去除字符串与空行的字符串
 */
- (NSString *)trimmingWhitespaceAndNewlines;

/**
 *  @brief  urlEncode
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncode;

/**
 *  @brief  urlEncode
 *
 *  @param encoding encoding模式
 *
 *  @return urlEncode 后的字符串
 */
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

/**
 *  @brief  urlDecode
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecode;

/**
 *  @brief  urlDecode
 *
 *  @param encoding encoding模式
 *
 *  @return urlDecode 后的字符串
 */
- (NSString *)urlDecodeUsingEncoding:(NSStringEncoding)encoding;

/**
 *  @brief  url query转成NSDictionary
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryFromURLParameters;


#pragma mark -
#pragma mark :. Base64

+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

#pragma mark -
#pragma mark :. Contains

/**
 *  @brief  判断URL中是否包含中文
 *
 *  @return 是否包含中文
 */
- (BOOL)isContainChinese;

/**
 *  @brief  是否包含空格
 *
 *  @return 是否包含空格
 */
- (BOOL)isContainBlank;

/**
 *  @brief  Unicode编码的字符串转成NSString
 *
 *  @return Unicode编码的字符串转成NSString
 */
- (NSString *)makeUnicodeToString;

- (BOOL)containsCharacterSet:(NSCharacterSet *)set;

/**
 *  @brief 是否包含字符串
 *
 *  @param string 字符串
 *
 *  @return YES, 包含;
 */
- (BOOL)containsaString:(NSString *)string;

/**
 *  @brief 获取字符数量
 */
- (int)wordsCount;

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

/**
 *  @author CC, 2016-12-29
 *
 *  @brief  字符串字节长度
 */
- (NSInteger)byteLength;

#pragma mark -
#pragma mark :. Emoji

/**
 Returns a NSString in which any occurrences that match the cheat codes
 from Emoji Cheat Sheet  are replaced by the
 corresponding unicode characters.
 
 Example:
 "This is a smiley face :smiley:"
 
 Will be replaced with:
 "This is a smiley face \U0001F604"
 */
- (NSString *)stringByReplacingEmojiCheatCodesWithUnicode;

/**
 Returns a NSString in which any occurrences that match the unicode characters
 of the emoji emoticons are replaced by the corresponding cheat codes from
 Emoji Cheat Sheet
 
 Example:
 "This is a smiley face \U0001F604"
 
 Will be replaced with:
 "This is a smiley face :smiley:"
 */
- (NSString *)stringByReplacingEmojiUnicodeWithCheatCodes;

/**
 *  @brief  是否包含emoji
 *
 *  @return 是否包含emoji
 */
- (BOOL)isIncludingEmoji;

/**
 *  @brief  删除掉包含的emoji
 *
 *  @return 清除后的string
 */
- (instancetype)removedEmojiString;

#pragma mark -
#pragma mark :. Encrypt

- (NSString *)encryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv;
- (NSString *)decryptedWithAESUsingKey:(NSString *)key andIV:(NSData *)iv;

- (NSString *)encryptedWith3DESUsingKey:(NSString *)key andIV:(NSData *)iv;
- (NSString *)decryptedWith3DESUsingKey:(NSString *)key andIV:(NSData *)iv;

#pragma mark -
#pragma mark :. Hash

@property(readonly) NSString *md5String;
@property(readonly) NSString *sha1String;
@property(readonly) NSString *sha256String;
@property(readonly) NSString *sha512String;

- (NSString *)hmacMD5StringWithKey:(NSString *)key;
- (NSString *)hmacSHA1StringWithKey:(NSString *)key;
- (NSString *)hmacSHA256StringWithKey:(NSString *)key;
- (NSString *)hmacSHA512StringWithKey:(NSString *)key;

#pragma mark -
#pragma mark :. Matcher

- (NSArray *)matchWithRegex:(NSString *)regex;
- (NSString *)matchWithRegex:(NSString *)regex atIndex:(NSUInteger)index;
- (NSString *)firstMatchedGroupWithRegex:(NSString *)regex;
- (NSTextCheckingResult *)firstMatchedResultWithRegex:(NSString *)regex;

#pragma mark -
#pragma mark :. MIME

/**
 *  @brief  根据文件url 返回对应的MIMEType
 *
 *  @return MIMEType
 */
- (NSString *)MIMEType;
/**
 *  @brief  根据文件url后缀 返回对应的MIMEType
 *
 *  @return MIMEType
 */
+ (NSString *)MIMETypeForExtension:(NSString *)extension;
/**
 *  @brief  常见MIME集合
 *
 *  @return 常见MIME集合
 */
+ (NSDictionary *)MIMEDict;

#pragma mark -
#pragma mark :. Pinyin

- (NSString *)pinyinWithPhoneticSymbol;
- (NSString *)pinyin;
- (NSArray *)pinyinArray;
- (NSString *)pinyinWithoutBlank;
- (NSArray *)pinyinInitialsArray;
- (NSString *)pinyinInitialsString;

#pragma mark -
#pragma mark :. RegexCategory

/**
 *  正则表达式简单说明
 *  语法：
 .       匹配除换行符以外的任意字符
 \w      匹配字母或数字或下划线或汉字
 \s      匹配任意的空白符
 \d      匹配数字
 \b      匹配单词的开始或结束
 ^       匹配字符串的开始
 $       匹配字符串的结束
 *       重复零次或更多次
 +       重复一次或更多次
 ?       重复零次或一次
 {n} 	重复n次
 {n,} 	重复n次或更多次
 {n,m} 	重复n到m次
 \W      匹配任意不是字母，数字，下划线，汉字的字符
 \S      匹配任意不是空白符的字符
 \D      匹配任意非数字的字符
 \B      匹配不是单词开头或结束的位置
 [^x] 	匹配除了x以外的任意字符
 [^aeiou]匹配除了aeiou这几个字母以外的任意字符
 *?      重复任意次，但尽可能少重复
 +?      重复1次或更多次，但尽可能少重复
 ??      重复0次或1次，但尽可能少重复
 {n,m}? 	重复n到m次，但尽可能少重复
 {n,}? 	重复n次以上，但尽可能少重复
 \a      报警字符(打印它的效果是电脑嘀一声)
 \b      通常是单词分界位置，但如果在字符类里使用代表退格
 \t      制表符，Tab
 \r      回车
 \v      竖向制表符
 \f      换页符
 \n      换行符
 \e      Escape
 \0nn 	ASCII代码中八进制代码为nn的字符
 \xnn 	ASCII代码中十六进制代码为nn的字符
 \unnnn 	Unicode代码中十六进制代码为nnnn的字符
 \cN 	ASCII控制字符。比如\cC代表Ctrl+C
 \A      字符串开头(类似^，但不受处理多行选项的影响)
 \Z      字符串结尾或行尾(不受处理多行选项的影响)
 \z      字符串结尾(类似$，但不受处理多行选项的影响)
 \G      当前搜索的开头
 \p{name} 	Unicode中命名为name的字符类，例如\p{IsGreek}
 (?>exp) 	贪婪子表达式
 (?<x>-<y>exp) 	平衡组
 (?im-nsx:exp) 	在子表达式exp中改变处理选项
 (?im-nsx)       为表达式后面的部分改变处理选项
 (?(exp)yes|no) 	把exp当作零宽正向先行断言，如果在这个位置能匹配，使用yes作为此组的表达式；否则使用no
 (?(exp)yes) 	同上，只是使用空表达式作为no
 (?(name)yes|no) 如果命名为name的组捕获到了内容，使用yes作为表达式；否则使用no
 (?(name)yes) 	同上，只是使用空表达式作为no
 
 捕获
 (exp)               匹配exp,并捕获文本到自动命名的组里
 (?<name>exp)        匹配exp,并捕获文本到名称为name的组里，也可以写成(?'name'exp)
 (?:exp)             匹配exp,不捕获匹配的文本，也不给此分组分配组号
 零宽断言
 (?=exp)             匹配exp前面的位置
 (?<=exp)            匹配exp后面的位置
 (?!exp)             匹配后面跟的不是exp的位置
 (?<!exp)            匹配前面不是exp的位置
 注释
 (?#comment)         这种类型的分组不对正则表达式的处理产生任何影响，用于提供注释让人阅读
 
 *  表达式：\(?0\d{2}[) -]?\d{8}
 *  这个表达式可以匹配几种格式的电话号码，像(010)88886666，或022-22334455，或02912345678等。
 *  我们对它进行一些分析吧：
 *  首先是一个转义字符\(,它能出现0次或1次(?),然后是一个0，后面跟着2个数字(\d{2})，然后是)或-或空格中的一个，它出现1次或不出现(?)，
 *  最后是8个数字(\d{8})
 */


/**
 *  手机号码的有效性:分电信、联通、移动和小灵通
 */
- (BOOL)isMobileNumber;

/**
 *  邮箱的有效性
 */
- (BOOL)isEmailAddress;

/**
 *  简单的身份证有效性
 *
 */
- (BOOL)simpleVerifyIdentityCardNum;

/**
 *  精确的身份证号码有效性检测
 *
 *  @param value 身份证号
 */
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)value;

/**
 *  车牌号的有效性
 */
- (BOOL)isCarNumber;

/**
 *  银行卡的有效性
 */
- (BOOL)bankCardluhmCheck;

/**
 *  IP地址有效性
 */
- (BOOL)isIPAddress;

/**
 *  Mac地址有效性
 */
- (BOOL)isMacAddress;

/**
 *  网址有效性
 */
- (BOOL)isValidUrl;

/**
 *  纯汉字
 */
- (BOOL)isValidChinese;

/**
 *  邮政编码
 */
- (BOOL)isValidPostalcode;

/**
 *  工商税号
 */
- (BOOL)isValidTaxNo;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     containDigtal   包含数字
 @param     containLetter   包含字母
 @param     containOtherCharacter   其他字符
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLetter:(BOOL)containLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

#pragma mark -
#pragma mark :. Ruby

//Operator-likes
- (NSString *) : (NSObject *)concat, ...;
- (NSString *)x:(NSInteger)mult;

//Shorthand Accessors
- (NSString *)ShorthandAccessors:(NSInteger)loc Len:(NSInteger)len;
- (NSString *)ShorthandAccessors:(NSInteger)start Shorthand:(char *)shorthand End:(NSInteger)end;

//Ruby Methods
- (void)bytes:(void (^)(unichar))block;
- (NSString *)center:(NSInteger)amount;
- (NSString *)center:(NSInteger)amount with:(NSString *)padString;
- (void)chars:(void (^)(unichar))block;
- (NSString *)chomp;
- (NSString *)chomp:(NSString *)string;
- (NSString *)chop;
- (NSString *)chr;
- (void)codePoints:(void (^)(NSInteger))block;
- (NSString *)concat:(id)concat;
- (NSInteger)count:(NSString *)setString, ...;
- (NSString *) delete:(NSString *)first, ...;
- (BOOL)endsWith:(NSString *)first, ...;
- (long)hex;
- (BOOL)includes:(NSString *)include;
- (NSInteger)index:(NSString *)pattern;
- (NSInteger)index:(NSString *)pattern offset:(NSInteger)offset;
- (NSString *)insert:(NSInteger)index string:(NSString *)string;
- (NSString *)inspect;
- (BOOL)isASCII;
- (BOOL)isEmpty;
- (NSInteger)lastIndex:(NSString *)pattern;
- (NSInteger)lastIndex:(NSString *)pattern offset:(NSInteger)offset;
- (NSString *)leftJustify:(NSInteger)amount;
- (NSString *)leftJustify:(NSInteger)amount with:(NSString *)padString;
- (NSString *)leftStrip;
- (void)lines:(void (^)(NSString *))block;
- (void)lines:(void (^)(NSString *))block separator:(NSString *)separator;
- (NSArray *)match:(NSString *)pattern;
- (NSArray *)match:(NSString *)pattern offset:(NSInteger)offset;
- (NSInteger)occurencesOf:(NSString *)subString;
- (long)octal;
- (NSInteger)ordinal;
- (NSArray *)partition:(NSString *)pattern;
- (NSString *)prepend:(NSString *)prefix;
- (NSRange)range;
- (NSString *)reverse;
- (NSInteger)rightIndex:(NSString *)pattern;
- (NSInteger)rightIndex:(NSString *)pattern offset:(NSInteger)offset;
- (NSString *)rightJustify:(NSInteger)amount;
- (NSString *)rightJustify:(NSInteger)amount with:(NSString *)padString;
- (NSArray *)rightPartition:(NSString *)pattern;
- (NSString *)rightStrip;
- (NSArray *)scan:(NSString *)pattern;
- (BOOL)startsWith:(NSString *)first, ...;
- (NSString *)strip;
- (NSArray *)split;
- (NSArray *)split:(NSString *)pattern;
- (NSArray *)split:(NSString *)pattern limit:(NSInteger)limit;
- (NSString *)squeeze;
- (NSString *)squeeze:(NSString *)pattern;
- (NSString *)substituteFirst:(NSString *)pattern with:(NSString *)sub;
- (NSString *)substituteLast:(NSString *)pattern with:(NSString *)sub;
- (NSString *)substituteAll:(NSDictionary *)subDictionary;
- (NSString *)substituteAll:(NSString *)pattern with:(NSString *)sub;
- (NSInteger)sum;
- (NSInteger)sum:(NSInteger)bit;
- (NSString *)swapcase;

//Subscript Protocol
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (id)objectForKeyedSubscript:(id)key;

#pragma mark-
#pragma mark :. Scire

enum {
    NSStringScoreOptionNone = 1 << 0,
    NSStringScoreOptionFavorSmallerWords = 1 << 1,
    NSStringScoreOptionReducedLongStringPenalty = 1 << 2
};

typedef NSUInteger NSStringScoreOption;

- (CGFloat)scoreAgainst:(NSString *)otherString;
- (CGFloat)scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness;
- (CGFloat)scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options;

@end

#pragma mark - NSMutableString

/* Ruby -> Obj-C Equivalents
 
 #capitalize!     capitalizeInPlace
 #chomp!          chompInPlace
 chompInPlace:
 #chop!           chopInPlace
 #delete!         deleteInPlace:
 #downcase!       lowercaseStringInPlace
 #gsub!           substituteAllInPlace:
 substituteAllInPlace:pattern
 #lstrip!         leftStripInPlace
 #reverse!        reverseInPlace
 #rstrip!         rightStripInPlace
 #squeeze!        squeezeInPlace
 squeezeInPlace:
 #strip!          stripInPlace
 #sub!            substituteFirstInPlace:
 substituteLastInPlace:
 #swapcase!       swapcaseInPlace
 #upcase!         uppercaseInPlace
 
 */

@interface NSMutableString (Additions)

//Ruby Methods
- (NSString *)capitalizeInPlace;
- (NSString *)chompInPlace;
- (NSString *)chompInPlace:(NSString *)string;
- (NSString *)chopInPlace;
- (NSString *)deleteInPlace:(NSString *)first, ...;
- (NSString *)lowercaseInPlace;
- (NSString *)substituteAllInPlace:(NSDictionary *)subDictionary;
- (NSString *)substituteAllInPlace:(NSString *)pattern with:(NSString *)sub;
- (NSString *)leftStripInPlace;
- (NSString *)reverseInPlace;
- (NSString *)rightStripInPlace;
- (NSString *)squeezeInPlace;
- (NSString *)squeezeInPlace:(NSString *)pattern;
- (NSString *)stripInPlace;
- (NSString *)substituteFirstInPlace:(NSString *)pattern with:(NSString *)sub;
- (NSString *)substituteLastInPlace:(NSString *)pattern with:(NSString *)sub;
- (NSString *)swapcaseInPlace;
- (NSString *)uppercaseInPlace;

@end
