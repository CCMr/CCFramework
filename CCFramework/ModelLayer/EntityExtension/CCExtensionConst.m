//
//  CCExtensionConst.m
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

#ifndef CCFramework_CCExtensionConst_h
#define CCFramework_CCExtensionConst_h

#import <Foundation/Foundation.h>

/**
 *  成员变量类型（属性类型）
 */
NSString *const CCPropertyTypeInt = @"i";
NSString *const CCPropertyTypeShort = @"s";
NSString *const CCPropertyTypeFloat = @"f";
NSString *const CCPropertyTypeDouble = @"d";
NSString *const CCPropertyTypeLong = @"l";
NSString *const CCPropertyTypeLongLong = @"q";
NSString *const CCPropertyTypeChar = @"c";
NSString *const CCPropertyTypeBOOL1 = @"c";
NSString *const CCPropertyTypeBOOL2 = @"b";
NSString *const CCPropertyTypePointer = @"*";

NSString *const CCPropertyTypeIvar = @"^{objc_ivar=}";
NSString *const CCPropertyTypeMethod = @"^{objc_method=}";
NSString *const CCPropertyTypeBlock = @"@?";
NSString *const CCPropertyTypeClass = @"#";
NSString *const CCPropertyTypeSEL = @":";
NSString *const CCPropertyTypeId = @"@";

#endif