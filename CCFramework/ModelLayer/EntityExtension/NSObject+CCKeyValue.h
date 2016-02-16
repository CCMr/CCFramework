//
//  CCKeyValue.h
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
#import <CoreData/CoreData.h>
#import "CCProperty.h"

/**
 *  KeyValue协议
 */
@protocol CCKeyValue <NSObject>
@optional
/**
 *  只有这个数组中的属性名才允许进行字典和模型的转换
 */
+ (NSArray *)cc_allowedPropertyNames;

/**
 *  这个数组中的属性名将会被忽略：不进行字典和模型的转换
 */
+ (NSArray *)cc_ignoredPropertyNames;

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)cc_replacedKeyFromPropertyName;

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 从字典中取值用的key
 */
+ (NSString *)cc_replacedKeyFromPropertyName121:(NSString *)propertyName;

/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)cc_objectClassInArray;

/**
 *  旧值换新值，用于过滤字典中的值
 *
 *  @param oldValue 旧值
 *
 *  @return 新值
 */
- (id)cc_newValueFromOldValue:(id)oldValue property:(CCProperty *)property;

/**
 *  当字典转模型完毕时调用
 */
- (void)cc_keyValuesDidFinishConvertingToObject;

/**
 *  当模型转字典完毕时调用
 */
- (void)cc_objectDidFinishConvertingToKeyValues;
@end

@interface NSObject (CCKeyValue) <CCKeyValue>
#pragma mark - 类方法
/**
 * 字典转模型过程中遇到的错误
 */
+ (NSError *)cc_error;

/**
 *  模型转字典时，字典的key是否参考replacedKeyFromPropertyName等方法（父类设置了，子类也会继承下来）
 */
+ (void)cc_referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference;

#pragma mark - 对象方法
/**
 *  将字典的键值对转成模型属性
 *  @param keyValues 字典(可以是NSDictionary、NSData、NSString)
 */
- (instancetype)cc_setKeyValues:(id)keyValues;

/**
 *  将字典的键值对转成模型属性
 *  @param keyValues 字典(可以是NSDictionary、NSData、NSString)
 *  @param context   CoreData上下文
 */
- (instancetype)cc_setKeyValues:(id)keyValues 
                        context:(NSManagedObjectContext *)context;

/**
 *  将模型转成字典
 *  @return 字典
 */
- (NSMutableDictionary *)cc_keyValues;
- (NSMutableDictionary *)cc_keyValuesWithKeys:(NSArray *)keys;
- (NSMutableDictionary *)cc_keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys;

/**
 *  通过模型数组来创建一个字典数组
 *  @param objectArray 模型数组
 *  @return 字典数组
 */
+ (NSMutableArray *)cc_keyValuesArrayWithObjectArray:(NSArray *)objectArray;

+ (NSMutableArray *)cc_keyValuesArrayWithObjectArray:(NSArray *)objectArray 
                                                keys:(NSArray *)keys;

+ (NSMutableArray *)cc_keyValuesArrayWithObjectArray:(NSArray *)objectArray 
                                         ignoredKeys:(NSArray *)ignoredKeys;

#pragma mark - 字典转模型
/**
 *  通过字典来创建一个模型
 *  @param keyValues 字典(可以是NSDictionary、NSData、NSString)
 *  @return 新建的对象
 */
+ (instancetype)cc_objectWithKeyValues:(id)keyValues;

/**
 *  通过字典来创建一个CoreData模型
 *  @param keyValues 字典(可以是NSDictionary、NSData、NSString)
 *  @param context   CoreData上下文
 *  @return 新建的对象
 */
+ (instancetype)cc_objectWithKeyValues:(id)keyValues 
                               context:(NSManagedObjectContext *)context;

/**
 *  通过plist来创建一个模型
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 新建的对象
 */
+ (instancetype)cc_objectWithFilename:(NSString *)filename;

/**
 *  通过plist来创建一个模型
 *  @param file 文件全路径
 *  @return 新建的对象
 */
+ (instancetype)cc_objectWithFile:(NSString *)file;

#pragma mark - 字典数组转模型数组
/**
 *  通过字典数组来创建一个模型数组
 *  @param keyValuesArray 字典数组(可以是NSDictionary、NSData、NSString)
 *  @return 模型数组
 */
+ (NSMutableArray *)cc_objectArrayWithKeyValuesArray:(id)keyValuesArray;

/**
 *  通过字典数组来创建一个模型数组
 *  @param keyValuesArray 字典数组(可以是NSDictionary、NSData、NSString)
 *  @param context        CoreData上下文
 *  @return 模型数组
 */
+ (NSMutableArray *)cc_objectArrayWithKeyValuesArray:(id)keyValuesArray 
                                             context:(NSManagedObjectContext *)context;

/**
 *  通过plist来创建一个模型数组
 *  @param filename 文件名(仅限于mainBundle中的文件)
 *  @return 模型数组
 */
+ (NSMutableArray *)cc_objectArrayWithFilename:(NSString *)filename;

/**
 *  通过plist来创建一个模型数组
 *  @param file 文件全路径
 *  @return 模型数组
 */
+ (NSMutableArray *)cc_objectArrayWithFile:(NSString *)file;

#pragma mark - 转换为JSON
/**
 *  转换为JSON Data
 */
- (NSData *)cc_JSONData;
/**
 *  转换为字典或者数组
 */
- (id)cc_JSONObject;
/**
 *  转换为JSON 字符串
 */
- (NSString *)cc_JSONString;
@end

@interface NSObject (CCKeyValueDeprecated_v_2_5_16)
- (instancetype)setKeyValues:(id)keyValue CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (instancetype)setKeyValues:(id)keyValues error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (instancetype)setKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (void)referenceReplacedKeyWhenCreatingKeyValues:(BOOL)reference CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSMutableDictionary *)keyValues CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSMutableDictionary *)keyValuesWithError:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSMutableDictionary *)keyValuesWithKeys:(NSArray *)keys error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSMutableDictionary *)keyValuesWithIgnoredKeys:(NSArray *)ignoredKeys error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray keys:(NSArray *)keys error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)keyValuesArrayWithObjectArray:(NSArray *)objectArray ignoredKeys:(NSArray *)ignoredKeys error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithKeyValues:(id)keyValues CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithKeyValues:(id)keyValues error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithKeyValues:(id)keyValues context:(NSManagedObjectContext *)context error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithFilename:(NSString *)filename CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithFilename:(NSString *)filename error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithFile:(NSString *)file CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (instancetype)objectWithFile:(NSString *)file error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithKeyValuesArray:(id)keyValuesArray context:(NSManagedObjectContext *)context error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithFilename:(NSString *)filename error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithFile:(NSString *)file CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
+ (NSMutableArray *)objectArrayWithFile:(NSString *)file error:(NSError **)error CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSData *)JSONData CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (id)JSONObject CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
- (NSString *)JSONString CCExtensionDeprecated("请在方法名前面加上cc_前缀，使用cc_***");
@end
