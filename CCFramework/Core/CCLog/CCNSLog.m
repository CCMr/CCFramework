//
//  CCLog.m
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

#import "CCNSLog.h"
#import "NSDate+BNSDate.h"

@interface CCNSLog ()

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  应用信息
 */
@property (nonatomic, strong) NSDictionary *applicationInfo;

@end

@implementation CCNSLog


+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  应用信息
 *
 *  @return 返回信用信息
 */
- (NSDictionary *)applicationInfo
{
    if (!_applicationInfo)
         _applicationInfo = [[NSBundle mainBundle] infoDictionary];
    return _applicationInfo;
}

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  输出日志消息
 *
 *  @param fileName 消息记录文件
 *  @param method   消息记录方法
 *  @param lineNr   源代码中的行数
 *  @param format   任意参数
 */
+ (void)cc_NSLog:(NSString *)fileName
          method:(NSString*)method
          lineNr:(NSNumber*)lineNr
            text:(NSString *)format,...
{
    va_list args;
    va_start(args, format);
    [[self sharedInstance] cc_NSLog:fileName method:method lineNr:lineNr text:format, args];
    va_end(args);
    
}

/**
 *  @author C C, 2015-11-08
 *
 *  @brief  输出日志消息
 *
 *  @param fileName 消息记录文件
 *  @param method   消息记录方法
 *  @param lineNr   源代码中的行数
 *  @param format   任意参数
 */
- (void)cc_NSLog:(NSString *)fileName
          method:(NSString *)method
          lineNr:(NSNumber *)lineNr
            text:(NSString *)format,...
{
    method = [[method substringWithRange:NSMakeRange(2, method.length-3)] componentsSeparatedByString:@" "].lastObject;

    NSMutableString *log = [NSMutableString string];
    [log appendFormat:@"%@ ",[self.applicationInfo objectForKey:(NSString *)kCFBundleExecutableKey]];//工程名
    [log appendFormat:@"Version：%@ ",[self.applicationInfo objectForKey:(NSString *)kCFBundleVersionKey]];
    [log appendFormat:@"(%@) ",[[NSDate date] toStringFormat:@"yyyy-MM-dd HH:mm:ss.SSS"]];
//    [log appendFormat:@"Class：%@ \n",fileName];
//    [log appendFormat:@"Method：%@ ",method];
    [log appendFormat:@"Line：%@\n",lineNr];
    [log appendFormat:@"%@ \n\n",format];
    
    if (log.length>0) {
        va_list args;
        va_start(args, format);
        #ifdef DEBUG
        vprintf(log.UTF8String, args);
        #endif
        va_end(args);
    }
}

@end
