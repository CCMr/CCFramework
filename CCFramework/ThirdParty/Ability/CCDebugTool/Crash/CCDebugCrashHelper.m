//
//  CCDebugCrashHelper.m
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

#import "CCDebugCrashHelper.h"

const int maxCrashLogNum = 20;

#define carshPlistName @"CCCrashLog.plist"

@interface CCDebugCrashHelper ()

@property(nonatomic, strong) NSString *
crashLogPath;
@property(nonatomic, strong) NSMutableArray *crashLogPlist;

@end


@implementation CCDebugCrashHelper

+ (instancetype)manager
{
    static CCDebugCrashHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [CCDebugCrashHelper new];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

/**
 *  @author CC, 16-03-05
 *  
 *  @brief 初始化设置
 */
- (void)initialization
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *sandBoxPath = [paths objectAtIndex:0];
    
    _crashLogPath = [sandBoxPath stringByAppendingPathComponent:@"CCCrashLog"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_crashLogPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_crashLogPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    //creat plist
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_crashLogPath stringByAppendingPathComponent:carshPlistName]])
        _crashLogPlist = [[NSMutableArray arrayWithContentsOfFile:[_crashLogPath stringByAppendingPathComponent:carshPlistName]] mutableCopy];
    else
        _crashLogPlist = [NSMutableArray new];
}

/**
 *  @author CC, 16-03-05
 *  
 *  @brief 保存Crash日志
 *
 *  @param exdic 错误集合
 */
- (void)saveCrashException:(NSMutableDictionary *)exdic
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[exdic objectForKey:@"ErrDate"]];
    [exdic setObject:dateString forKey:@"ErrDate"];
    
    NSString *saceCrashPath = [[_crashLogPath stringByAppendingPathComponent:dateString] stringByAppendingString:@".plist"];
    
    if (![exdic writeToFile:saceCrashPath atomically:YES]) {
        NSLog(@"CCDebugTool:crash report failed!");
    } else
        NSLog(@"CCDebugTool:save crash report succeed!");
    
    [_crashLogPlist insertObject:dateString atIndex:0];
    [_crashLogPlist writeToFile:[_crashLogPath stringByAppendingPathComponent:carshPlistName] atomically:YES];
    
    if (_crashLogPlist.count > maxCrashLogNum) {
        [[NSFileManager defaultManager] removeItemAtPath:[_crashLogPath stringByAppendingPathComponent:[_crashLogPlist objectAtIndex:0]] error:nil];
        [_crashLogPlist writeToFile:[_crashLogPath stringByAppendingPathComponent:carshPlistName] atomically:YES];
    }
}

/**
 *  @author CC, 16-03-05
 *  
 *  @brief 获取Crash日志
 */
- (NSArray *)obtainCrashLogs
{
    NSMutableArray *crashArray = [NSMutableArray array];
    for (NSString *key in self.crashLogPlist) {
        NSString *filePath = [_crashLogPath stringByAppendingPathComponent:key];
        NSString *path = [filePath stringByAppendingString:@".plist"];
        NSDictionary *log = [NSDictionary dictionaryWithContentsOfFile:path];
        [crashArray addObject:log];
    }
    return [crashArray copy];
}

@end
