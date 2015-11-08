//
//  CCLog.h
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

#ifdef DEBUG
#define CCNSLogger( s , ... )\
    [CCNSLog cc_NSLog: [[NSString stringWithUTF8String:__FILE__] lastPathComponent] \
               method: [NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
               lineNr: [NSNumber numberWithInt:__LINE__] \
                 text: [NSString stringWithFormat:(s), ##__VA_ARGS__]]
#endif

@interface CCNSLog : NSObject

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  不要直接调用此方法，而只是使用的NSLog（）直接，它会再*调用此方法传递正确的paramters。
 *
 *  @param fileName 消息记录文件
 *  @param method   消息记录方法
 *  @param lineNr   源代码中的行数
 *  @param format   任意参数
 */
+ (void)cc_NSLog:(NSString *)fileName
          method:(NSString*)method
          lineNr:(NSNumber*)lineNr
            text:(NSString *)format, ...;

@end
