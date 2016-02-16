//
//  NSObject+CCClass.h
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

#import "NSObject+CCClass.h"
#import "NSObject+CCCoding.h"
#import "NSObject+CCKeyValue.h"
#import "CCFoundation.h"
#import <objc/runtime.h>

static const char CCAllowedPropertyNamesKey = '\0';
static const char CCIgnoredPropertyNamesKey = '\0';
static const char CCAllowedCodingPropertyNamesKey = '\0';
static const char CCIgnoredCodingPropertyNamesKey = '\0';

static NSMutableDictionary *allowedPropertyNamesDict_;
static NSMutableDictionary *ignoredPropertyNamesDict_;
static NSMutableDictionary *allowedCodingPropertyNamesDict_;
static NSMutableDictionary *ignoredCodingPropertyNamesDict_;

@implementation NSObject (CCClass)

+ (void)load
{
    allowedPropertyNamesDict_ = [NSMutableDictionary dictionary];
    ignoredPropertyNamesDict_ = [NSMutableDictionary dictionary];
    allowedCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
    ignoredCodingPropertyNamesDict_ = [NSMutableDictionary dictionary];
}

+ (NSMutableDictionary *)dictForKey:(const void *)key
{
    if (key == &CCAllowedPropertyNamesKey) return allowedPropertyNamesDict_;
    if (key == &CCIgnoredPropertyNamesKey) return ignoredPropertyNamesDict_;
    if (key == &CCAllowedCodingPropertyNamesKey) return allowedCodingPropertyNamesDict_;
    if (key == &CCIgnoredCodingPropertyNamesKey) return ignoredCodingPropertyNamesDict_;
    return nil;
}

+ (void)cc_enumerateClasses:(CCClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
        
        if ([CCFoundation isClassFromFoundation:c]) break;
    }
}

+ (void)cc_enumerateAllClasses:(CCClassesEnumeration)enumeration
{
    // 1.没有block就直接返回
    if (enumeration == nil) return;
    
    // 2.停止遍历的标记
    BOOL stop = NO;
    
    // 3.当前正在遍历的类
    Class c = self;
    
    // 4.开始遍历每一个类
    while (c && !stop) {
        // 4.1.执行操作
        enumeration(c, &stop);
        
        // 4.2.获得父类
        c = class_getSuperclass(c);
    }
}

#pragma mark - 属性黑名单配置
+ (void)cc_setupIgnoredPropertyNames:(CCIgnoredPropertyNames)ignoredPropertyNames
{
    [self cc_setupBlockReturnValue:ignoredPropertyNames key:&CCIgnoredPropertyNamesKey];
}

+ (NSMutableArray *)cc_totalIgnoredPropertyNames
{
    return [self cc_totalObjectsWithSelector:@selector(cc_ignoredPropertyNames) key:&CCIgnoredPropertyNamesKey];
}

#pragma mark - 归档属性黑名单配置
+ (void)cc_setupIgnoredCodingPropertyNames:(CCIgnoredCodingPropertyNames)ignoredCodingPropertyNames
{
    [self cc_setupBlockReturnValue:ignoredCodingPropertyNames key:&CCIgnoredCodingPropertyNamesKey];
}

+ (NSMutableArray *)cc_totalIgnoredCodingPropertyNames
{
    return [self cc_totalObjectsWithSelector:@selector(cc_ignoredCodingPropertyNames) key:&CCIgnoredCodingPropertyNamesKey];
}

#pragma mark - 属性白名单配置
+ (void)cc_setupAllowedPropertyNames:(CCAllowedPropertyNames)allowedPropertyNames;
{
    [self cc_setupBlockReturnValue:allowedPropertyNames key:&CCAllowedPropertyNamesKey];
}

+ (NSMutableArray *)cc_totalAllowedPropertyNames
{
    return [self cc_totalObjectsWithSelector:@selector(cc_allowedPropertyNames) key:&CCAllowedPropertyNamesKey];
}

#pragma mark - 归档属性白名单配置
+ (void)cc_setupAllowedCodingPropertyNames:(CCAllowedCodingPropertyNames)allowedCodingPropertyNames
{
    [self cc_setupBlockReturnValue:allowedCodingPropertyNames key:&CCAllowedCodingPropertyNamesKey];
}

+ (NSMutableArray *)cc_totalAllowedCodingPropertyNames
{
    return [self cc_totalObjectsWithSelector:@selector(cc_allowedCodingPropertyNames) key:&CCAllowedCodingPropertyNamesKey];
}
#pragma mark - block和方法处理:存储block的返回值
+ (void)cc_setupBlockReturnValue:(id (^)())block key:(const char *)key
{
    if (block) {
        objc_setAssociatedObject(self, key, block(), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    // 清空数据
    [[self dictForKey:key] removeAllObjects];
}

+ (NSMutableArray *)cc_totalObjectsWithSelector:(SEL)selector key:(const char *)key
{
    NSMutableArray *array = [self dictForKey:key][NSStringFromClass(self)];
    if (array) return array;
    
    // 创建、存储
    [self dictForKey:key][NSStringFromClass(self)] = array = [NSMutableArray array];
    
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSArray *subArray = [self performSelector:selector];
#pragma clang diagnostic pop
        if (subArray) {
            [array addObjectsFromArray:subArray];
        }
    }
    
    [self cc_enumerateAllClasses:^(__unsafe_unretained Class c, BOOL *stop) {
        NSArray *subArray = objc_getAssociatedObject(c, key);
        [array addObjectsFromArray:subArray];
    }];
    return array;
}
@end
