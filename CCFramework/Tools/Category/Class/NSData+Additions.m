//
//  NSData+Additions.m
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

#import "NSData+Additions.h"
#import "CCBase64.h"

@implementation NSData (Additions)

/**
 *  @author CC, 15-09-09
 *
 *  @brief  data转换字符串
 *
 *  @return 返回转换字符串
 *
 *  @since 1.0
 */
- (NSString *)ChangedString
{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

/**
 *  @author CC, 15-09-25
 *
 *  @brief  base64编码
 *
 *  @return 返回编码之后的字符串
 */
- (NSString *)encodeBase64Data
{
    return [[NSString alloc] initWithData:[CCBase64 encodeData:self] encoding:NSUTF8StringEncoding];
}

/**
 *  @author CC, 15-09-25
 *
 *  @brief  base64解码
 *
 *  @return 返回加密字符串
 */
- (NSString *)decodeBase64Data
{
    return [[NSString alloc] initWithData:[CCBase64 decodeData:self] encoding:NSUTF8StringEncoding];
}

@end
