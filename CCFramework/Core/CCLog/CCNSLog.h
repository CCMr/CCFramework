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
#define CCNSLogger(format, ...) cc_NSLog(nil, nil, __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__])			//输出格式（时间 工程名称 版本号 行数）
#define CCExtLogger(format, ...) cc_NSLog(__FILE__, __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__]) //输出格式（时间 工程名称 版本号 类名 函数名 行数）
#else
#define CCNSLogger(...) NSLog(__VA_ARGS__)
#endif

FOUNDATION_EXPORT void cc_NSLog(const char *file, const char *method, int lineNumber, NSString *format);
