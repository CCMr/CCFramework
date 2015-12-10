//
//  CCJPsuh.m
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

@class UILocalNotification;

#import "CCJPsuh.h"
#import "NSObject+Additions.h"

typedef void (^Callback)(NSDictionary *requestDic);

@interface CCJPsuh ()

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  设置tag与别名响应回调
 */
@property(nonatomic, copy) Callback callback;

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  本地通知
 */
@property(nonatomic, strong) UILocalNotification *notification;

@end

@implementation CCJPsuh

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  单例
 */
+ (id)manager
{
    static CCJPsuh *_sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  设置Tag
 *
 *  @param aryTags tag集合
 */
- (void)setTags:(NSArray *)aryTags
       Callback:(void (^)(NSDictionary *requestDic))block
{
    _callback = block;
    __block NSMutableSet *tags = [NSMutableSet set];
    [aryTags enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [tags addObject:obj];
    }];
    [self setTagsAlias:tags
                 alias:nil];
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  设置别名
 *
 *  @param alias 别名
 *  @param block 响应函数
 */
- (void)setAlias:(NSString *)alias
        Callback:(void (^)(NSDictionary *requestDic))block
{
    _callback = block;
    
    [self setTagsAlias:nil
                 alias:alias];
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  清空Tag
 */
- (void)resetTags
{
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        [APService performSelectors:@"setTags:callbackSelector:object:"
                         withObject:[NSSet set], nil, nil, nil];
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  清空别名
 */
- (void)resetAlias
{
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        [APService performSelectors:@"setAlias:callbackSelector:object:"
                         withObject:@"", nil, nil, nil];
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  设置tag与别名
 *
 *  @param tags  tag
 *  @param alias 别名
 */
- (void)setTagsAlias:(NSSet *)tags
               alias:(NSString *)alias
{
    if (!tags && !tags.count)
        tags = nil;
    if (!alias && !alias.length)
        alias = nil;
    
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        [APService performSelectors:@"setTags:alias:callbackSelector:target"
                         withObject:tags, alias, @selector(tagsAliasCallback:tags:alias:), self, nil];
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  设置极光响应回调
 *
 *  @param iResCode 响应结果码
 *  @param tags     tags值
 *  @param alias    别名值
 */
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithInt:iResCode] forKey:@"iResCode"];
    [dic setObject:tags forKey:@"tags"];
    [dic setObject:alias forKey:@"alias"];
    
    if (_callback)
        _callback(dic);
}

#pragma mark :. 发送本地通知
/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  本地推送(本地推送，最多支持64个)
 *
 *  @param fireDate           本地推送触发的时间
 *  @param alertBody          本地推送需要显示的内容
 *  @param badge              角标的数字。如果不需要改变角标传-1
 *  @param alertAction        弹框的按钮显示的内容（IOS 8默认为"打开",其他默认为"启动"）
 *  @param notificationKey    本地推送标示符
 *  @param userInfo           自定义参数，可以用来标识推送和增加附加信息
 *  @param soundName          自定义通知声音，设置为nil为默认声音
 *
 *  @return 返回通知结果
 */
- (BOOL)setLocalNotification:(NSDate *)fireDate
                   alertBody:(NSString *)alertBody
                       badge:(int)badge
                 alertAction:(NSString *)alertAction
               identifierKey:(NSString *)notificationKey
                    userInfo:(NSDictionary *)userInfo
                   soundName:(NSString *)soundName
{
    
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        _notification = [APService performSelectors:@"setLocalNotification:alertBody:badge:alertAction:identifierKey:userInfo:soundName:"
                                         withObject:fireDate, alertBody, badge, alertAction, notificationKey, userInfo, soundName, nil];
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
    
    BOOL bol = YES;
    if (!_notification)
        bol = NO;
    return bol;
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  本地推送(本地推送，最多支持64个)
 *
 *  @param fireDate           本地推送触发的时间
 *  @param alertBody          本地推送需要显示的内容
 *  @param badge              角标的数字。如果不需要改变角标传-1
 *  @param alertAction        弹框的按钮显示的内容（IOS 8默认为"打开",其他默认为"启动"）
 *  @param notificationKey    本地推送标示符
 *  @param userInfo           自定义参数，可以用来标识推送和增加附加信息
 *  @param soundName          自定义通知声音，设置为nil为默认声音
 *  @param region             自定义参数
 *  @param regionTriggersOnce 自定义参数
 *  @param category           自定义参数
 *
 *  @return 返回通知结果
 */
- (BOOL)setLocalNotification:(NSDate *)fireDate
                   alertBody:(NSString *)alertBody
                       badge:(int)badge
                 alertAction:(NSString *)alertAction
               identifierKey:(NSString *)notificationKey
                    userInfo:(NSDictionary *)userInfo
                   soundName:(NSString *)soundName
                      region:(CLRegion *)region
          regionTriggersOnce:(BOOL)regionTriggersOnce
                    category:(NSString *)category NS_AVAILABLE_IOS(8_0)
{
    
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        _notification = [APService performSelectors:@"setLocalNotification:alertBody:badge:alertAction:identifierKey:userInfo:soundName:region:regionTriggersOnce:category:"
                                         withObject:fireDate, alertBody, badge, alertAction, notificationKey, userInfo, soundName, region, regionTriggersOnce, category, nil];
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
    
    BOOL bol = YES;
    if (!_notification)
        bol = NO;
    return bol;
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  清理上一个通知
 */
- (void)clearLastNotification
{
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        [APService performSelectors:@"deleteLocalNotification:"
                         withObject:_notification, nil];
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
}

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  清理所有通知
 */
- (void)clearAllNotification
{
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        [APService performSelectors:@"clearAllLocalNotifications" 
                         withObject:nil]; 
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
}

#pragma - mark :. 设置Badge
/**
 *  set setBadge
 *  @param value 设置JPush服务器的badge的值
 *  本地仍须调用UIApplication:setApplicationIconBadgeNumber函数,来设置脚标
 */
- (BOOL)setBadge:(NSInteger)value
{
    if (NSClassFromString(@"APService")) {
        Class APService = NSClassFromString(@"APService");
        
        return [[APService performSelectors:@"setBadge:" 
                                 withObject:@(value),nil] boolValue]; 
    } else {
        NSLog(@"请在工程中导入APService.a文件");
    }
    return NO;
}

@end
