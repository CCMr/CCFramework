//
//  CCExtension.h
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
#import "CCExtensionConst.h"

@interface NSString (CCExtension)
/**
 *  驼峰转下划线（loveYou -> love_you）
 */
- (NSString *)cc_underlineFromCamel;
/**
 *  下划线转驼峰（love_you -> loveYou）
 */
- (NSString *)cc_camelFromUnderline;
/**
 * 首字母变大写
 */
- (NSString *)cc_firstCharUpper;
/**
 * 首字母变小写
 */
- (NSString *)cc_firstCharLower;

- (BOOL)cc_isPureInt;

- (NSURL *)cc_url;
@end

@interface NSString (CCExtensionDeprecated_v_2_5_16)
- (NSString *)underlineFromCamel CCExtensionDeprecated("请在方法名前面加上CC_前缀，使用CC_***");
- (NSString *)camelFromUnderline CCExtensionDeprecated("请在方法名前面加上CC_前缀，使用CC_***");
- (NSString *)firstCharUpper CCExtensionDeprecated("请在方法名前面加上CC_前缀，使用CC_***");
- (NSString *)firstCharLower CCExtensionDeprecated("请在方法名前面加上CC_前缀，使用CC_***");
- (BOOL)isPureInt CCExtensionDeprecated("请在方法名前面加上CC_前缀，使用CC_***");
- (NSURL *)url CCExtensionDeprecated("请在方法名前面加上CC_前缀，使用CC_***");
@end
