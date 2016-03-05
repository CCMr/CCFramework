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

FOUNDATION_EXPORT void cc_NSLog(const char *file, const char *method, int lineNumber, NSString *format, ...)
{
    if (format) {
        va_list arguments;
        va_start(arguments, format);
        NSString *apS = [[NSString alloc] initWithFormat:format arguments:arguments];
        va_end(arguments);
        format = apS;
    }
    
    if (![format hasSuffix:@"\n"])
        format = [format stringByAppendingString:@"\n"];
    
    
    format = ({
        format = [format stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
        format = [format stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        format = [format stringByReplacingOccurrencesOfString:@"\\\\U" withString:@"\\U"];
        format = [[@"\"" stringByAppendingString:format] stringByAppendingString:@"\""];
        format = [NSPropertyListSerialization propertyListFromData:[format dataUsingEncoding:NSUTF8StringEncoding]
                                                  mutabilityOption:NSPropertyListImmutable
                                                            format:NULL
                                                  errorDescription:NULL];
        format = [format stringByReplacingOccurrencesOfString:@"\0" withString:@""];
        [format stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
    });
    
    NSMutableString *log = [NSMutableString string];
    
    NSDictionary *applicationInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *applicationName = [applicationInfo objectForKey:(NSString *)kCFBundleExecutableKey]; //app名称
    [log appendFormat:@"%@", applicationName];
    
    NSString *applicationVersion = [applicationInfo objectForKey:(NSString *)kCFBundleVersionKey]; //app版本
    [log appendFormat:@" Version:%@ ", applicationVersion];
    
    if (file) {
        NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent]; //文件名
        [log appendFormat:@"\n Class: %@", fileName];
    }
    
    if (method) {
        NSString *metodName = [NSString stringWithUTF8String:method]; //函数名称
        metodName = [[metodName substringWithRange:NSMakeRange(2, metodName.length - 3)] componentsSeparatedByString:@" "].lastObject;
        metodName = [metodName componentsSeparatedByString:@"]"].firstObject;
        [log appendFormat:@"\n Method: %@\n", metodName];
    }
    
    [log appendFormat:@"Line: %d\n", lineNumber];
    [log appendFormat:@"%@ \n", format];
    
    NSLog(@"%@", log);
}
