//
//  CCExtensionConst.h
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

// 过期
#define CCExtensionDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

// 构建错误
#define CCExtensionBuildError(clazz, msg) \
NSError *error = [NSError errorWithDomain:msg code:250 userInfo:nil]; \
[clazz setcc_error:error];

/**
 * 断言
 * @param condition   条件
 * @param returnValue 返回值
 */
#define CCExtensionAssertError(condition, returnValue, clazz, msg) \
[clazz setcc_error:nil]; \
if ((condition) == NO) { \
    CCExtensionBuildError(clazz, msg); \
    return returnValue;\
}

#define CCExtensionAssert2(condition, returnValue) \
if ((condition) == NO) return returnValue;

/**
 * 断言
 * @param condition   条件
 */
#define CCExtensionAssert(condition) CCExtensionAssert2(condition, )

/**
 * 断言
 * @param param         参数
 * @param returnValue   返回值
 */
#define CCExtensionAssertParamNotNil2(param, returnValue) \
CCExtensionAssert2((param) != nil, returnValue)

/**
 * 断言
 * @param param   参数
 */
#define CCExtensionAssertParamNotNil(param) CCExtensionAssertParamNotNil2(param, )

/**
 * 打印所有的属性
 */
#define CCLogAllIvars \
-(NSString *)description \
{ \
    return [self cc_keyValues].description; \
}
#define CCExtensionLogAllProperties CCLogAllIvars

/**
 *  类型（属性类型）
 */
extern NSString *const CCPropertyTypeInt;
extern NSString *const CCPropertyTypeShort;
extern NSString *const CCPropertyTypeFloat;
extern NSString *const CCPropertyTypeDouble;
extern NSString *const CCPropertyTypeLong;
extern NSString *const CCPropertyTypeLongLong;
extern NSString *const CCPropertyTypeChar;
extern NSString *const CCPropertyTypeBOOL1;
extern NSString *const CCPropertyTypeBOOL2;
extern NSString *const CCPropertyTypePointer;

extern NSString *const CCPropertyTypeIvar;
extern NSString *const CCPropertyTypeMethod;
extern NSString *const CCPropertyTypeBlock;
extern NSString *const CCPropertyTypeClass;
extern NSString *const CCPropertyTypeSEL;
extern NSString *const CCPropertyTypeId;

#endif