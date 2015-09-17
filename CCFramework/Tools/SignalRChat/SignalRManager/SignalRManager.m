//
//  SignalRManager.m
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

#import "SignalRManager.h"

@interface SignalRManager()

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  长连接对象
 *
 *  @since 1.0
 */
@property (nonatomic, strong) SRHubConnection *hubConnection;

@end

static SignalRManager *_sharedlnstance = nil;
@implementation SignalRManager

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  单例实例
 *
 *  @return 创建对象
 *
 *  @since 1.0
 */
+ (id)sharedInstance
{
    @synchronized(self){
        if (_sharedlnstance == nil) {
            _sharedlnstance = [[self alloc] init];
        }
    }
    return _sharedlnstance;
}

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  初始化对象
 *
 *  @return 返回当前对象
 *
 *  @since 1.0
 */
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self initObject];
    }
    
    return self;
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  获取Signalr服务地址
 *
 *  @return 返回当前服务地址
 *
 *  @since 1.0
 */
- (NSString *)SignalRServiceAddress
{
    return @"";
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  获取Signalr端口号
 *
 *  @return 返回当前服务端口号
 *
 *  @since 1.0
 */
- (NSString *)SignalRProxyPort
{
    return @"";
}

/**
 *  @author CC, 15-09-09
 *
 *  @brief  添加监听服务
 *
 *  @since 1.0
 */
- (void)addNotification
{

}

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  初始化对象属性
 *
 *  @since 1.0
 */
- (void)initObject
{
    //建立服务长连接
    _hubConnection = [SRHubConnection connectionWithURLString:[self SignalRServiceAddress]];

    //设置聊天代理
    _chatProxy = [_hubConnection createHubProxy:[self SignalRProxyPort]];

    [self addNotification];
}

/**
 *  @author CC, 15-09-17
 *
 *  @brief  注册响应事件回调
 *
 *  @param responseEventName 响应事件名称
 *  @param eventCallback     响应事件
 *
 *  @since 1.0
 */
- (void)registerNotice: (NSString *)responseEventName
              Selector: (id)selectorSelf
         ResponseEvent: (SEL)eventCallback
{
    
}

/**
 *  @author CC, 15-09-14
 *
 *  @brief  启动连接服务
 *
 *  @since 1.0
 */
- (void)startLink
{
    [_hubConnection start];
}

@end
