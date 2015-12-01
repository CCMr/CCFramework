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
#import "SignalR.h"

@interface SignalRManager () <SRConnectionDelegate>

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  长连接对象
 *
 *  @since 1.0
 */
@property(nonatomic, strong) SRHubConnection *hubConnection;

/**
 *  @author CC, 2015-08-15
 *
 *  @brief  注册监听对象
 *
 *  @since 1.0
 */
@property(nonatomic, strong) SRHubProxy *chatProxy;

@end

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
    static SignalRManager *_sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
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
 *  @author CC, 2015-11-11
 *  
 *  @brief  建立服务器连接
 *
 *  @return 返回连接
 */
- (SRHubConnection *)hubConnection
{
    if (!_hubConnection) {
        _hubConnection = [SRHubConnection connectionWithURLString:[self SignalRServiceAddress]];
        _hubConnection.delegate = self;
    }
    return _hubConnection;
}

/**
 *  @author CC, 2015-11-11
 *  
 *  @brief  连接代理通道
 *
 *  @return 返回连接代理通道
 */
- (SRHubProxy *)chatProxy
{
    if (!_chatProxy) {
        _chatProxy = [self.hubConnection createHubProxy:[self SignalRProxyPort]];
    }
    return _chatProxy;
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
    if (self.hubConnection.state == disconnected){
        [self addNotification];
        [self.hubConnection start];
    }
}

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  停止链接
 */
- (void)stopLink
{
    [self.hubConnection stop];
    [self.hubConnection didClose];
}

#pragma mark -_- 事件处理
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
- (void)registerNotice:(NSString *)responseEventName
              Selector:(id)selectorSelf
         ResponseEvent:(SEL)eventCallback
{
    [self.chatProxy on:responseEventName
               perform:selectorSelf
              selector:eventCallback];
}

/**
 *  @author CC, 2015-11-11
 *  
 *  @brief  发送调用
 *
 *  @param eventName 事件名称
 *  @param args      参数
 */
- (void)sendInvoke:(NSString *)eventName
          withArgs:(id)args, ... NS_REQUIRES_NIL_TERMINATION
{
    
    NSMutableArray *array = [NSMutableArray array];
    if (args) {
        [array addObject:args];
        va_list arguments;
        id eachObject;
        va_start(arguments, args);
        while ((eachObject = va_arg(arguments, id))) {
            [array addObject:args];
        }
        va_end(arguments);
    }
    
    [self.chatProxy invoke:eventName
                  withArgs:array];
}

#pragma mark - 回调函数
/**
 *  @author CC, 15-09-18
 *
 *  @brief  注册设备
 *
 *  @since 1.0
 */
- (void)registerDevice
{
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  重新链接服务
 *
 *  @since 1.0
 */
- (void)connectionWillReconnect
{
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接关闭
 *
 *  @since 1.0
 */
- (void)connectionDidClose
{
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接错误
 *
 *  @param error 错误实体
 *
 *  @since 1.0
 */
- (void)connectionReceiveError:(NSError *)error
{
}

#pragma mark - SignalRDeletgate
/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接完成回调
 *
 *  @param connection <#connection description#>
 *
 *  @since 1.0
 */
- (void)SRConnectionDidOpen:(id<SRConnectionInterface>)connection
{
    [self registerDevice];
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  连接将重新连接
 *
 *  @param connection 链接
 *
 *  @since 1.0
 */
- (void)SRConnectionWillReconnect:(id<SRConnectionInterface>)connection
{
    [self connectionWillReconnect];
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  是否重新链接
 *
 *  @param connection 链接
 *
 *  @since 1.0
 */
- (void)SRConnectionDidReconnect:(id<SRConnectionInterface>)connection
{
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接成功收到服务器回调数据
 *
 *  @param connection 链接
 *  @param data       接收数据
 *
 *  @since 1.0
 */
- (void)SRConnection:(id<SRConnectionInterface>)connection didReceiveData:(id)data
{
    [self connectionDidClose];
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接关闭
 *
 *  @param connection 链接
 *
 *  @since 1.0
 */
- (void)SRConnectionDidClose:(id<SRConnectionInterface>)connection
{
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接错误
 *
 *  @param connection 链接
 *  @param error      错误消息
 *
 *  @since 1.0
 */
- (void)SRConnection:(id<SRConnectionInterface>)connection didReceiveError:(NSError *)error
{
    [self connectionReceiveError:error];
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接地址
 *
 *  @param connection 链接
 *  @param oldState   更改状态
 *  @param newState   新状态
 *
 *  @since 1.0
 */
- (void)SRConnection:(id <SRConnectionInterface>)connection didChangeState:(connectionState)oldState newState:(connectionState)newState
{
    
}

/**
 *  @author CC, 15-09-18
 *
 *  @brief  链接通道缓慢
 *
 *  @param connection 链接
 *
 *  @since 1.0
 */
- (void)SRConnectionDidSlow:(id <SRConnectionInterface>)connection
{
    
}



@end
