//
//  NSObject+Additions.m
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

#import "NSObject+Additions.h"
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <dispatch/dispatch.h>

@interface NSObject () <NSSecureCoding>

@end

@implementation NSObject (Additions)

/**
 *  @brief  异步执行代码块
 *
 *  @param block 代码块
 */
- (void)performAsynchronous:(void (^)(void))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

/**
 *  @brief  GCD主线程执行代码块
 *
 *  @param block 代码块
 *  @param wait  是否同步请求
 */
- (void)performOnMainThread:(void (^)(void))block wait:(BOOL)shouldWait
{
    if (shouldWait) {
        // Synchronous
        dispatch_sync(dispatch_get_main_queue(), block);
    } else {
        // Asynchronous
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 *  @brief  延迟执行代码块
 *
 *  @param seconds 延迟时间 秒
 *  @param block   代码块
 */
- (void)performAfter:(NSTimeInterval)seconds block:(void (^)(void))block
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_current_queue(), block);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

#pragma mark -
#pragma mark :. Reflection

- (NSString *)className
{
    return NSStringFromClass([self class]);
}

- (NSString *)superClassName
{
    return NSStringFromClass([self superclass]);
}

+ (NSString *)className
{
    return NSStringFromClass([self class]);
}

+ (NSString *)superClassName
{
    return NSStringFromClass([self superclass]);
}

- (NSDictionary *)propertyDictionary
{
    //创建可变字典
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t prop = props[i];
        NSString *propName = [[NSString alloc] initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        id propValue = [self valueForKey:propName];
        [dict setObject:propValue ?: [NSNull null] forKey:propName];
    }
    free(props);
    return dict;
}

- (NSArray *)propertyKeys
{
    return [[self class] propertyKeys];
}

+ (NSArray *)propertyKeys
{
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    NSMutableArray *propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNames;
}

- (NSArray *)propertiesInfo
{
    return [[self class] propertiesInfo];
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 属性列表与属性的各种信息
 */
+ (NSArray *)propertiesInfo
{
    NSMutableArray *propertieArray = [NSMutableArray array];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        [propertieArray addObject:({
            
            NSDictionary *dictionary = [self dictionaryWithProperty:properties[i]];
            
            dictionary;
        })];
    }
    
    free(properties);
    
    return propertieArray;
}

+ (NSArray *)propertiesWithCodeFormat
{
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *properties = [[self class] propertiesInfo];
    
    for (NSDictionary *item in properties) {
        NSMutableString *format = ({
            
            NSMutableString *formatString = [NSMutableString stringWithFormat:@"@property "];
            //attribute
            NSArray *attribute = [item objectForKey:@"attribute"];
            attribute = [attribute sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            if (attribute && attribute.count > 0)
            {
                NSString *attributeStr = [NSString stringWithFormat:@"(%@)",[attribute componentsJoinedByString:@", "]];
                
                [formatString appendString:attributeStr];
            }
            
            //type
            NSString *type = [item objectForKey:@"type"];
            if (type) {
                [formatString appendString:@" "];
                [formatString appendString:type];
            }
            
            //name
            NSString *name = [item objectForKey:@"name"];
            if (name) {
                [formatString appendString:@" "];
                [formatString appendString:name];
                [formatString appendString:@";"];
            }
            
            formatString;
        });
        
        [array addObject:format];
    }
    
    return array;
}

- (NSArray *)methodList
{
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);
    return methodList;
}

- (NSArray *)methodListInfo
{
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        Method method = methods[i];
        //        IMP imp = method_getImplementation(method);
        SEL name = method_getName(method);
        // 返回方法的参数的个数
        int argumentsCount = method_getNumberOfArguments(method);
        //获取描述方法参数和返回值类型的字符串
        const char *encoding = method_getTypeEncoding(method);
        //取方法的返回值类型的字符串
        const char *returnType = method_copyReturnType(method);
        
        NSMutableArray *arguments = [NSMutableArray array];
        for (int index = 0; index < argumentsCount; index++) {
            // 获取方法的指定位置参数的类型字符串
            char *arg = method_copyArgumentType(method, index);
            //            NSString *argString = [NSString stringWithCString:arg encoding:NSUTF8StringEncoding];
            [arguments addObject:[[self class] decodeType:arg]];
        }
        
        NSString *returnTypeString = [[self class] decodeType:returnType];
        NSString *encodeString = [[self class] decodeType:encoding];
        NSString *nameString = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        
        [info setObject:arguments forKey:@"arguments"];
        [info setObject:[NSString stringWithFormat:@"%d", argumentsCount] forKey:@"argumentsCount"];
        [info setObject:returnTypeString forKey:@"returnType"];
        [info setObject:encodeString forKey:@"encode"];
        [info setObject:nameString forKey:@"name"];
        //        [info setObject:imp_f forKey:@"imp"];
        [methodList addObject:info];
    }
    free(methods);
    return methodList;
}

+ (NSArray *)methodList
{
    u_int count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        [methodList addObject:strName];
    }
    free(methods);
    
    return methodList;
}

//创建并返回一个指向所有已注册类的指针列表
+ (NSArray *)registedClassList
{
    NSMutableArray *result = [NSMutableArray array];
    
    unsigned int count;
    Class *classes = objc_copyClassList(&count);
    for (int i = 0; i < count; i++) {
        [result addObject:NSStringFromClass(classes[i])];
    }
    free(classes);
    [result sortedArrayUsingSelector:@selector(compare:)];
    
    return result;
}

/**
 *  @author CC, 16-03-03
 *  
 *  @brief 协议列表信息
 *
 *  @return 协议列表信息
 */
- (NSDictionary *)protocolList
{
    return [[self class] protocolList];
}
+ (NSDictionary *)protocolList
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned int count;
    Protocol *__unsafe_unretained *protocols = class_copyProtocolList([self class], &count);
    for (int i = 0; i < count; i++) {
        Protocol *protocol = protocols[i];
        
        NSString *protocolName = [NSString stringWithCString:protocol_getName(protocol) encoding:NSUTF8StringEncoding];
        
        NSMutableArray *superProtocolArray = ({
            
            NSMutableArray *array = [NSMutableArray array];
            
            unsigned int superProtocolCount;
            Protocol * __unsafe_unretained * superProtocols = protocol_copyProtocolList(protocol, &superProtocolCount);
            for (int ii = 0; ii < superProtocolCount; ii++)
            {
                Protocol *superProtocol = superProtocols[ii];
                
                NSString *superProtocolName = [NSString stringWithCString:protocol_getName(superProtocol) encoding:NSUTF8StringEncoding];
                
                [array addObject:superProtocolName];
            }
            free(superProtocols);
            
            array;
        });
        
        [dictionary setObject:superProtocolArray forKey:protocolName];
    }
    free(protocols);
    
    return dictionary;
}

+ (NSArray *)instanceVariable
{
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        NSString *type = [[self class] decodeType:ivar_getTypeEncoding(ivars[i])];
        NSString *name = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
        NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
        [result addObject:ivarDescription];
    }
    free(ivars);
    return result.count ? [result copy] : nil;
}

- (BOOL)hasPropertyForKey:(NSString *)key
{
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    return (BOOL)property;
}

- (BOOL)hasIvarForKey:(NSString *)key
{
    Ivar ivar = class_getInstanceVariable([self class], [key UTF8String]);
    return (BOOL)ivar;
}

#pragma mark--- help
+ (NSDictionary *)dictionaryWithProperty:(objc_property_t)property
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    //name
    NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    [result setObject:propertyName forKey:@"name"];
    
    //attribute
    
    NSMutableDictionary *attributeDictionary = ({
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        unsigned int attributeCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attributeCount);
        
        for (int i = 0; i < attributeCount; i++)
        {
            NSString *name = [NSString stringWithCString:attrs[i].name encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:attrs[i].value encoding:NSUTF8StringEncoding];
            [dictionary setObject:value forKey:name];
        }
        
        free(attrs);
        
        dictionary;
    });
    
    NSMutableArray *attributeArray = [NSMutableArray array];
    
    /***
     R           | The property is read-only (readonly).
     C           | The property is a copy of the value last assigned (copy).
     &           | The property is a reference to the value last assigned (retain).
     N           | The property is non-atomic (nonatomic).
     G<name>     | The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
     S<name>     | The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
     D           | The property is dynamic (@dynamic).
     W           | The property is a weak reference (__weak).
     P           | The property is eligible for garbage collection.
     t<encoding> | Specifies the type using old-style encoding.
     */
    
    //R
    if ([attributeDictionary objectForKey:@"R"])
        [attributeArray addObject:@"readonly"];
    
    //C
    if ([attributeDictionary objectForKey:@"C"])
        [attributeArray addObject:@"copy"];
    
    //&
    if ([attributeDictionary objectForKey:@"&"])
        [attributeArray addObject:@"strong"];
    
    //N
    if ([attributeDictionary objectForKey:@"N"])
        [attributeArray addObject:@"nonatomic"];
    else
        [attributeArray addObject:@"atomic"];
    
    //G<name>
    if ([attributeDictionary objectForKey:@"G"])
        [attributeArray addObject:[NSString stringWithFormat:@"getter=%@", [attributeDictionary objectForKey:@"G"]]];
    
    //S<name>
    if ([attributeDictionary objectForKey:@"S"])
        [attributeArray addObject:[NSString stringWithFormat:@"setter=%@", [attributeDictionary objectForKey:@"G"]]];
    
    //D
    if ([attributeDictionary objectForKey:@"D"])
        [result setObject:[NSNumber numberWithBool:YES] forKey:@"isDynamic"];
    else
        [result setObject:[NSNumber numberWithBool:NO] forKey:@"isDynamic"];
    
    //W
    if ([attributeDictionary objectForKey:@"W"])
        [attributeArray addObject:@"weak"];
    
    //P
    if ([attributeDictionary objectForKey:@"P"])
        //TODO:P | The property is eligible for garbage collection.
        
        //T
        if ([attributeDictionary objectForKey:@"T"]) {
            /*
             c               A char
             i               An int
             s               A short
             l               A long l is treated as a 32-bit quantity on 64-bit programs.
             q               A long long
             C               An unsigned char
             I               An unsigned int
             S               An unsigned short
             L               An unsigned long
             Q               An unsigned long long
             f               A float
             d               A double
             B               A C++ bool or a C99 _Bool
             v               A void
             *               A character string (char *)
             @               An object (whether statically typed or typed id)
             #               A class object (Class)
             :               A method selector (SEL)
             [array type]    An array
             {name=type...}  A structure
             (name=type...)  A union
             bnum            A bit field of num bits
             ^type           A pointer to type
             ?               An unknown type (among other things, this code is used for function pointers)
             
             */
            
            NSDictionary *typeDic = @{ @"c" : @"char",
                                       @"i" : @"int",
                                       @"s" : @"short",
                                       @"l" : @"long",
                                       @"q" : @"long long",
                                       @"C" : @"unsigned char",
                                       @"I" : @"unsigned int",
                                       @"S" : @"unsigned short",
                                       @"L" : @"unsigned long",
                                       @"Q" : @"unsigned long long",
                                       @"f" : @"float",
                                       @"d" : @"double",
                                       @"B" : @"BOOL",
                                       @"v" : @"void",
                                       @"*" : @"char *",
                                       @"@" : @"id",
                                       @"#" : @"Class",
                                       @":" : @"SEL",
                                       };
            //TODO:An array
            NSString *key = [attributeDictionary objectForKey:@"T"];
            
            id type_str = [typeDic objectForKey:key];
            
            if (type_str == nil) {
                if ([[key substringToIndex:1] isEqualToString:@"@"] && [key rangeOfString:@"?"].location == NSNotFound) {
                    type_str = [[key substringWithRange:NSMakeRange(2, key.length - 3)] stringByAppendingString:@"*"];
                } else if ([[key substringToIndex:1] isEqualToString:@"^"]) {
                    id str = [typeDic objectForKey:[key substringFromIndex:1]];
                    
                    if (str) {
                        type_str = [NSString stringWithFormat:@"%@ *", str];
                    }
                } else {
                    type_str = @"unknow";
                }
            }
            
            [result setObject:type_str forKey:@"type"];
        }
    
    [result setObject:attributeArray forKey:@"attribute"];
    
    return result;
}

+ (NSString *)decodeType:(const char *)cString
{
    if (!strcmp(cString, @encode(char)))
        return @"char";
    if (!strcmp(cString, @encode(int)))
        return @"int";
    if (!strcmp(cString, @encode(short)))
        return @"short";
    if (!strcmp(cString, @encode(long)))
        return @"long";
    if (!strcmp(cString, @encode(long long)))
        return @"long long";
    if (!strcmp(cString, @encode(unsigned char)))
        return @"unsigned char";
    if (!strcmp(cString, @encode(unsigned int)))
        return @"unsigned int";
    if (!strcmp(cString, @encode(unsigned short)))
        return @"unsigned short";
    if (!strcmp(cString, @encode(unsigned long)))
        return @"unsigned long";
    if (!strcmp(cString, @encode(unsigned long long)))
        return @"unsigned long long";
    if (!strcmp(cString, @encode(float)))
        return @"float";
    if (!strcmp(cString, @encode(double)))
        return @"double";
    if (!strcmp(cString, @encode(bool)))
        return @"bool";
    if (!strcmp(cString, @encode(_Bool)))
        return @"_Bool";
    if (!strcmp(cString, @encode(void)))
        return @"void";
    if (!strcmp(cString, @encode(char *)))
        return @"char *";
    if (!strcmp(cString, @encode(id)))
        return @"id";
    if (!strcmp(cString, @encode(Class)))
        return @"class";
    if (!strcmp(cString, @encode(SEL)))
        return @"SEL";
    if (!strcmp(cString, @encode(BOOL)))
        return @"BOOL";
    
    //@TODO: do handle bitmasks
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    
    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    } else {
        if ([[result substringToIndex:1] isEqualToString:@"^"]) {
            result = [NSString stringWithFormat:@"%@ *",
                      [NSString decodeType:[[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    return result;
}

#pragma mark -
#pragma mark :. AddProperty

//objc_getAssociatedObject和objc_setAssociatedObject都需要指定一个固定的地址，这个固定的地址值用来表示属性的key，起到一个常量的作用。
static const void *StringProperty = &StringProperty;
static const void *IntegerProperty = &IntegerProperty;
//static char IntegerProperty;

@dynamic stringProperty;

//set
/**
 *  @brief  catgory runtime实现get set方法增加一个字符串属性
 */
- (void)setStringProperty:(NSString *)stringProperty
{
    //use that a static const as the key
    objc_setAssociatedObject(self, StringProperty, stringProperty, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //use that property's selector as the key:
    //objc_setAssociatedObject(self, @selector(stringProperty), stringProperty, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//get
- (NSString *)stringProperty
{
    return objc_getAssociatedObject(self, StringProperty);
}

//set
/**
 *  @brief  catgory runtime实现get set方法增加一个NSInteger属性
 */
- (void)setIntegerProperty:(NSInteger)integerProperty
{
    NSNumber *number = [[NSNumber alloc] initWithInteger:integerProperty];
    objc_setAssociatedObject(self, IntegerProperty, number, OBJC_ASSOCIATION_ASSIGN);
}

//get
- (NSInteger)integerProperty
{
    return [objc_getAssociatedObject(self, IntegerProperty) integerValue];
}

#pragma mark -
#pragma mark :. AppInfo

- (NSString *)cc_version
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}
- (NSInteger)cc_build
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [app_build integerValue];
}
- (NSString *)cc_identifier
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleIdentifier = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    return bundleIdentifier;
}
- (NSString *)cc_currentLanguage
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages firstObject];
    return [NSString stringWithString:currentLanguage];
}
- (NSString *)cc_deviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return [NSString stringWithString:deviceString];
}

#pragma mark -
#pragma mark :. AssociatedObject

/**
 *  @brief  附加一个stong对象
 *
 *  @param value 被附加的对象
 *  @param key   被附加对象的key
 */
- (void)associateValue:(id)value withKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

/**
 *  @brief  附加一个weak对象
 *
 *  @param value 被附加的对象
 *  @param key   被附加对象的key
 */
- (void)weaklyAssociateValue:(id)value withKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

/**
 *  @author CC, 16-03-14
 *  
 *  @brief  附加一个copy对象
 *
 *  @param value 被附加的对象
 *  @param key   被附加对象的key
 */
-(void)copyAssociateValue:(id)value withKey:(void *)key
{
     objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_COPY);
}

/**
 *  @brief  根据附加对象的key取出附加对象
 *
 *  @param key 附加对象的key
 *
 *  @return 附加对象
 */
- (id)associatedValueForKey:(void *)key
{
    return objc_getAssociatedObject(self, key);
}

#pragma mark -
#pragma mark :. AutoCoding

#pragma GCC diagnostic ignored "-Wgnu"
static NSString *const AutocodingException = @"AutocodingException";


+ (instancetype)objectWithContentsOfFile:(NSString *)filePath
{
    //load the file
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    //attempt to deserialise data as a plist
    id object = nil;
    if (data) {
        NSPropertyListFormat format;
        object = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:NULL];
        //success?
        if (object) {
            //check if object is an NSCoded unarchive
            if ([object respondsToSelector:@selector(objectForKey:)] && [(NSDictionary *)object objectForKey:@"$archiver"]) {
                object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
        } else {
            //return raw data
            object = data;
        }
    }
    //return object
    return object;
}

- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    //note: NSData, NSDictionary and NSArray already implement this method
    //and do not save using NSCoding, however the objectWithContentsOfFile
    //method will correctly recover these objects anyway
    //archive object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToFile:filePath atomically:useAuxiliaryFile];
}

+ (NSDictionary *)codableProperties
{
    //deprecated
    SEL deprecatedSelector = NSSelectorFromString(@"codableKeys");
    if ([self respondsToSelector:deprecatedSelector] || [self instancesRespondToSelector:deprecatedSelector]) {
        NSLog(@"AutoCoding Warning: codableKeys method is no longer supported. Use codableProperties instead.");
    }
    deprecatedSelector = NSSelectorFromString(@"uncodableKeys");
    if ([self respondsToSelector:deprecatedSelector] || [self instancesRespondToSelector:deprecatedSelector]) {
        NSLog(@"AutoCoding Warning: uncodableKeys method is no longer supported. Use ivars, or synthesize your properties using non-KVC-compliant names to avoid coding them instead.");
    }
    deprecatedSelector = NSSelectorFromString(@"uncodableProperties");
    NSArray *uncodableProperties = nil;
    if ([self respondsToSelector:deprecatedSelector] || [self instancesRespondToSelector:deprecatedSelector]) {
        uncodableProperties = [self valueForKey:@"uncodableProperties"];
        NSLog(@"AutoCoding Warning: uncodableProperties method is no longer supported. Use ivars, or synthesize your properties using non-KVC-compliant names to avoid coding them instead.");
    }
    unsigned int propertyCount;
    __autoreleasing NSMutableDictionary *codableProperties = [NSMutableDictionary dictionary];
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    for (unsigned int i = 0; i < propertyCount; i++) {
        //get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        __autoreleasing NSString *key = @(propertyName);
        //check if codable
        if (![uncodableProperties containsObject:key]) {
            //get property type
            Class propertyClass = nil;
            char *typeEncoding = property_copyAttributeValue(property, "T");
            switch (typeEncoding[0]) {
                case '@': {
                    if (strlen(typeEncoding) >= 3) {
                        char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                        __autoreleasing NSString *name = @(className);
                        NSRange range = [name rangeOfString:@"<"];
                        if (range.location != NSNotFound) {
                            name = [name substringToIndex:range.location];
                        }
                        propertyClass = NSClassFromString(name) ?: [NSObject class];
                        free(className);
                    }
                    break;
                }
                case 'c':
                case 'i':
                case 's':
                case 'l':
                case 'q':
                case 'C':
                case 'I':
                case 'S':
                case 'L':
                case 'Q':
                case 'f':
                case 'd':
                case 'B': {
                    propertyClass = [NSNumber class];
                    break;
                }
                case '{': {
                    propertyClass = [NSValue class];
                    break;
                }
            }
            free(typeEncoding);
            if (propertyClass) {
                //check if there is a backing ivar
                char *ivar = property_copyAttributeValue(property, "V");
                if (ivar) {
                    //check if ivar has KVC-compliant name
                    __autoreleasing NSString *ivarName = @(ivar);
                    if ([ivarName isEqualToString:key] || [ivarName isEqualToString:[@"_" stringByAppendingString:key]]) {
                        //no setter, but setValue:forKey: will still work
                        codableProperties[key] = propertyClass;
                    }
                    free(ivar);
                } else {
                    //check if property is dynamic and readwrite
                    char *dynamic = property_copyAttributeValue(property, "D");
                    char *readonly = property_copyAttributeValue(property, "R");
                    if (dynamic && !readonly) {
                        //no ivar, but setValue:forKey: will still work
                        codableProperties[key] = propertyClass;
                    }
                    free(dynamic);
                    free(readonly);
                }
            }
        }
    }
    free(properties);
    return codableProperties;
}

- (NSDictionary *)codableProperties
{
    __autoreleasing NSDictionary *codableProperties = objc_getAssociatedObject([self class], _cmd);
    if (!codableProperties) {
        codableProperties = [NSMutableDictionary dictionary];
        Class subclass = [self class];
        while (subclass != [NSObject class]) {
            [(NSMutableDictionary *)codableProperties addEntriesFromDictionary:[subclass codableProperties]];
            subclass = [subclass superclass];
        }
        codableProperties = [NSDictionary dictionaryWithDictionary:codableProperties];
        //make the association atomically so that we don't need to bother with an @synchronize
        objc_setAssociatedObject([self class], _cmd, codableProperties, OBJC_ASSOCIATION_RETAIN);
    }
    return codableProperties;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (__unsafe_unretained NSString *key in [self codableProperties]) {
        id value = [self valueForKey:key];
        if (value) dict[key] = value;
    }
    return dict;
}

- (void)setWithCoder:(NSCoder *)aDecoder
{
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = [[self class] supportsSecureCoding];
    NSDictionary *properties = [self codableProperties];
    for (NSString *key in properties) {
        id object = nil;
        Class propertyClass = properties[key];
        if (secureAvailable) {
            object = [aDecoder decodeObjectOfClass:propertyClass forKey:key];
        } else {
            object = [aDecoder decodeObjectForKey:key];
        }
        if (object) {
            if (secureSupported && ![object isKindOfClass:propertyClass]) {
                [NSException raise:AutocodingException format:@"Expected '%@' to be a %@, but was actually a %@", key, propertyClass, [object class]];
            }
            [self setValue:object forKey:key];
        }
    }
}

//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [self initWithCoder:aDecoder];
//    [self setWithCoder:aDecoder];
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)aCoder
//{
//    for (NSString *key in [self codableProperties]) {
//        id object = [self valueForKey:key];
//        if (object) [aCoder encodeObject:object forKey:key];
//    }
//}

#pragma mark -
#pragma mark :. Block

static inline dispatch_time_t dTimeDelay(NSTimeInterval time)
{
    int64_t delta = (int64_t)(NSEC_PER_SEC * time);
    return dispatch_time(DISPATCH_TIME_NOW, delta);
}

+ (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled)block();
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO);
    });
    
    return wrappingBlock;
}

+ (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay
{
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO, anObject);
    });
    
    return wrappingBlock;
}

- (id)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL) = ^(BOOL cancel) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block();
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO);
    });
    
    return wrappingBlock;
}

- (id)performBlock:(void (^)(id arg))block withObject:(id)anObject afterDelay:(NSTimeInterval)delay
{
    if (!block) return nil;
    
    __block BOOL cancelled = NO;
    
    void (^wrappingBlock)(BOOL, id) = ^(BOOL cancel, id arg) {
        if (cancel) {
            cancelled = YES;
            return;
        }
        if (!cancelled) block(arg);
    };
    
    wrappingBlock = [wrappingBlock copy];
    
    dispatch_after(dTimeDelay(delay), dispatch_get_main_queue(), ^{  wrappingBlock(NO, anObject);
    });
    
    return wrappingBlock;
}

+ (void)cancelBlock:(id)block
{
    if (!block) return;
    void (^aWrappingBlock)(BOOL) = (void (^)(BOOL))block;
    aWrappingBlock(YES);
}

+ (void)cancelPreviousPerformBlock:(id)aWrappingBlockHandle
{
    [self cancelBlock:aWrappingBlockHandle];
}

- (void)logTimeTakenToRunBlock:(void (^)(void))block withPrefix:(NSString *)prefixString
{
    double a = CFAbsoluteTimeGetCurrent();
    block();
    double b = CFAbsoluteTimeGetCurrent();
    
    unsigned int m = ((b - a) * 1000.0f); // convert from seconds to milliseconds
    
    NSLog(@"%@: %d ms", prefixString ? prefixString : @"Time taken", m);
}

#pragma mark--- KVOBlock
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context
          withBlock:(KVOBlock)block
{
    
    objc_setAssociatedObject(observer, (__bridge const void *)(keyPath), block, OBJC_ASSOCIATION_COPY);
    [self addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)removeBlockObserver:(NSObject *)observer
                 forKeyPath:(NSString *)keyPath
{
    objc_setAssociatedObject(observer, (__bridge const void *)(keyPath), nil, OBJC_ASSOCIATION_COPY);
    [self removeObserver:observer forKeyPath:keyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    KVOBlock block = objc_getAssociatedObject(self, (__bridge const void *)(keyPath));
    block(change, context);
}

- (void)addObserverForKeyPath:(NSString *)keyPath
                      options:(NSKeyValueObservingOptions)options
                      context:(void *)context
                    withBlock:(KVOBlock)block
{
    
    [self addObserver:self forKeyPath:keyPath options:options context:context withBlock:block];
}

- (void)removeBlockObserverForKeyPath:(NSString *)keyPath
{
    [self removeBlockObserver:self forKeyPath:keyPath];
}

#pragma mark -
#pragma mark :. EasyCopy

- (BOOL)easyShallowCopy:(NSObject *)instance
{
    Class currentClass = [self class];
    Class instanceClass = [instance class];
    
    if (self == instance) {
        //相同实例
        return NO;
    }
    
    if (![instance isMemberOfClass:currentClass]) {
        //不是当前类的实例
        return NO;
    }
    
    while (instanceClass != [NSObject class]) {
        unsigned int propertyListCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyListCount);
        for (int i = 0; i < propertyListCount; i++) {
            objc_property_t property = propertyList[i];
            const char *property_name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:property_name encoding:NSUTF8StringEncoding];
            
            //check if property is dynamic and readwrite
            char *dynamic = property_copyAttributeValue(property, "D");
            char *readonly = property_copyAttributeValue(property, "R");
            if (propertyName && !readonly) {
                id propertyValue = [instance valueForKey:propertyName];
                [self setValue:propertyValue forKey:propertyName];
            }
            free(dynamic);
            free(readonly);
        }
        free(propertyList);
        instanceClass = class_getSuperclass(instanceClass);
    }
    
    return YES;
}

- (BOOL)easyDeepCopy:(NSObject *)instance
{
    Class currentClass = [self class];
    Class instanceClass = [instance class];
    
    if (self == instance) {
        //相同实例
        return NO;
    }
    
    if (![instance isMemberOfClass:currentClass]) {
        //不是当前类的实例
        return NO;
    }
    
    while (instanceClass != [NSObject class]) {
        unsigned int propertyListCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyListCount);
        for (int i = 0; i < propertyListCount; i++) {
            objc_property_t property = propertyList[i];
            const char *property_name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:property_name encoding:NSUTF8StringEncoding];
            
            //check if property is dynamic and readwrite
            char *dynamic = property_copyAttributeValue(property, "D");
            char *readonly = property_copyAttributeValue(property, "R");
            if (propertyName && !readonly) {
                id propertyValue = [instance valueForKey:propertyName];
                Class propertyValueClass = [propertyValue class];
                BOOL flag = [NSObject isNSObjectClass:propertyValueClass];
                if (flag) {
                    if ([propertyValue conformsToProtocol:@protocol(NSCopying)]) {
                        NSObject *copyValue = [propertyValue copy];
                        [self setValue:copyValue forKey:propertyName];
                    } else {
                        NSObject *copyValue = [[[propertyValue class] alloc] init];
                        [copyValue easyDeepCopy:propertyValue];
                        [self setValue:copyValue forKey:propertyName];
                    }
                } else {
                    [self setValue:propertyValue forKey:propertyName];
                }
            }
            free(dynamic);
            free(readonly);
        }
        free(propertyList);
        instanceClass = class_getSuperclass(instanceClass);
    }
    
    return YES;
}


+ (BOOL)isNSObjectClass:(Class)clazz
{
    
    BOOL flag = class_conformsToProtocol(clazz, @protocol(NSObject));
    if (flag) {
        return flag;
    } else {
        Class superClass = class_getSuperclass(clazz);
        if (!superClass) {
            return NO;
        } else {
            return [NSObject isNSObjectClass:superClass];
        }
    }
}

#pragma mark-
#pragma mark :. Runtime

BOOL method_swizzle(Class klass, SEL origSel, SEL altSel)
{
    if (!klass)
        return NO;
    
    Method __block origMethod, __block altMethod;
    
    void (^find_methods)() = ^{
        unsigned methodCount = 0;
        Method *methodList = class_copyMethodList(klass, &methodCount);
        
        origMethod = altMethod = NULL;
        
        if (methodList)
            for (unsigned i = 0; i < methodCount; ++i)
            {
                if (method_getName(methodList[i]) == origSel)
                    origMethod = methodList[i];
                
                if (method_getName(methodList[i]) == altSel)
                    altMethod = methodList[i];
            }
        
        free(methodList);
    };
    
    find_methods();
    
    if (!origMethod) {
        origMethod = class_getInstanceMethod(klass, origSel);
        
        if (!origMethod)
            return NO;
        
        if (!class_addMethod(klass, method_getName(origMethod), method_getImplementation(origMethod), method_getTypeEncoding(origMethod)))
            return NO;
    }
    
    if (!altMethod) {
        altMethod = class_getInstanceMethod(klass, altSel);
        
        if (!altMethod)
            return NO;
        
        if (!class_addMethod(klass, method_getName(altMethod), method_getImplementation(altMethod), method_getTypeEncoding(altMethod)))
            return NO;
    }
    
    find_methods();
    
    if (!origMethod || !altMethod)
        return NO;
    
    method_exchangeImplementations(origMethod, altMethod);
    
    return YES;
}

void method_append(Class toClass, Class fromClass, SEL selector)
{
    if (!toClass || !fromClass || !selector)
        return;
    
    Method method = class_getInstanceMethod(fromClass, selector);
    
    if (!method)
        return;
    
    class_addMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
}

void method_replace(Class toClass, Class fromClass, SEL selector)
{
    if (!toClass || !fromClass || !selector)
        return;
    
    Method method = class_getInstanceMethod(fromClass, selector);
    
    if (!method)
        return;
    
    class_replaceMethod(toClass, method_getName(method), method_getImplementation(method), method_getTypeEncoding(method));
}

+ (void)swizzleMethod:(SEL)originalMethod withMethod:(SEL)newMethod
{
    method_swizzle(self.class, originalMethod, newMethod);
}

+ (void)appendMethod:(SEL)newMethod fromClass:(Class)klass
{
    method_append(self.class, klass, newMethod);
}

+ (void)replaceMethod:(SEL)method fromClass:(Class)klass
{
    method_replace(self.class, klass, method);
}

- (BOOL)respondsToSelector:(SEL)selector untilClass:(Class)stopClass
{
    return [self.class instancesRespondToSelector:selector untilClass:stopClass];
}

- (BOOL)superRespondsToSelector:(SEL)selector
{
    return [self.superclass instancesRespondToSelector:selector];
}

- (BOOL)superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass
{
    return [self.superclass instancesRespondToSelector:selector untilClass:stopClass];
}

+ (BOOL)instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass
{
    BOOL __block (^__weak block_self)(Class klass, SEL selector, Class stopClass);
    BOOL (^block)(Class klass, SEL selector, Class stopClass) = [^(Class klass, SEL selector, Class stopClass) {
        if (!klass || klass == stopClass)
            return NO;
        
        unsigned methodCount = 0;
        Method *methodList = class_copyMethodList(klass, &methodCount);
        
        if (methodList)
            for (unsigned i = 0; i < methodCount; ++i)
                if (method_getName(methodList[i]) == selector)
                    return YES;
        
        return block_self(klass.superclass, selector, stopClass);
    } copy];
    
    block_self = block;
    
    return block(self.class, selector, stopClass);
}

/**
 *  @author C C, 2015-11-12
 *
 *  @brief  用于初始化
 *
 *  @param methodName 初始化函数名
 *
 *  @return 返回初始化独享
 */
+ (id)InitDefaultMethod:(NSString *)methodName
{
    SEL methodSEL = NSSelectorFromString(methodName);
    NSObject *valueObj = nil;
    if ([self respondsToSelector:methodSEL]) {
        NSMethodSignature *methodSignature = [self methodSignatureForSelector:methodSEL];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self];
        [invocation setSelector:methodSEL];
        [invocation invoke];
        [invocation getReturnValue:&valueObj];
    }
    return valueObj;
}

/**
 *  @author C C, 2015-10-27
 *
 *  @brief  多参数调用
 *
 *  @param selector 函数名
 *
 *  @return 返回函数值
 */
- (id)performSelectors:(NSString *)methodName withObject:(id)aObject, ...
{
    SEL methodSEL = NSSelectorFromString(methodName);
    
    //声明返回值变量
    id anObject = nil;
    if ([self respondsToSelector:methodSEL]) {
        //方法签名类，需要被调用消息所属的类self ,被调用的消息invokeMethod:
        NSMethodSignature *methodSignature = [self methodSignatureForSelector:methodSEL];
        
        //根据方法签名创建一个NSInvocation
        NSInvocation *invo = [NSInvocation invocationWithMethodSignature:methodSignature];
        if (methodSignature) {
            //设置调用者也就是AsynInvoked的实例对象，在这里我用self替代
            [invo setTarget:self];
            //设置被调用的消息
            [invo setSelector:methodSEL];
            //如果此消息有参数需要传入，那么就需要按照如下方法进行参数设置，需要注意的是，atIndex的下标必须从2开始。原因为：0 1 两个参数已经被target 和selector占用
            [invo setArgument:&aObject atIndex:2];
            //retain 所有参数，防止参数被释放dealloc
            [invo retainArguments];
            
            va_list arguments;
            id eachObject;
            if (aObject) {
                va_start(arguments, aObject);
                
                NSInteger index = 3;
                while ((eachObject = va_arg(arguments, id))) {
                    [invo setArgument:&eachObject atIndex:index];
                    index++;
                }
                va_end(arguments);
            }
        }
        //消息调用
        [invo invoke];
        
        //获得返回值类型
        const char *returnType = methodSignature.methodReturnType;
        
        //如果没有返回值，也就是消息声明为void，那么returnValue=nil
        if (!strcmp(returnType, @encode(void))) {
            anObject = nil;
        }
        //如果返回值为对象，那么为变量赋值
        else if (!strcmp(returnType, @encode(id))) {
            [invo getReturnValue:&anObject];
        } else {
            //如果返回值为普通类型NSInteger  BOOL
            //返回值长度
            NSUInteger length = [methodSignature methodReturnLength];
            //根据长度申请内存
            void *buffer = (void *)malloc(length);
            //为变量赋值
            [invo getReturnValue:buffer];
            //以下代码为参考:具体地址我忘记了，等我找到后补上，(很对不起原作者)
            if (!strcmp(returnType, @encode(BOOL))) {
                anObject = [NSNumber numberWithBool:*((BOOL *)buffer)];
            } else if (!strcmp(returnType, @encode(NSInteger))) {
                anObject = [NSNumber numberWithInteger:*((NSInteger *)buffer)];
            }
            anObject = [NSValue valueWithBytes:buffer objCType:returnType];
        }
    }
    return anObject;
}


@end
