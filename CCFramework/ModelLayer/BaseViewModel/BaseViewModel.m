//
//  BaseViewModel.m
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

#import "BaseViewModel.h"
#import <objc/runtime.h>

static char OperationKey;

@implementation BaseViewModel

#pragma mark - 委托回调函数

-(void)setReturnBlock:(Completion)returnBlock
{
    NSString *key = [NSString stringWithFormat:@"%@returnBlock",NSStringFromClass(self.class)];
    [self callBackFunction:key withBlock:returnBlock];
}

- (Completion)returnBlock
{
    NSString *key = [NSString stringWithFormat:@"%@returnBlock",NSStringFromClass(self.class)];
    return [self callActionBlockFunction:key];
}

-(void)setErrorBlock:(ErrorCodeBlock)errorBlock
{
    NSString *key = [NSString stringWithFormat:@"%@errorBlock",NSStringFromClass(self.class)];
    [self callBackFunction:key withBlock:errorBlock];
}

- (ErrorCodeBlock)errorBlock
{
    NSString *key = [NSString stringWithFormat:@"%@errorBlock",NSStringFromClass(self.class)];
    return [self callActionBlockFunction:key];
}

-(void)setFailureBlock:(FailureBlock)failureBlock
{
    NSString *key = [NSString stringWithFormat:@"%@failureBlock",NSStringFromClass(self.class)];
    [self callBackFunction:key withBlock:failureBlock];
}

- (FailureBlock)failureBlock
{
    NSString *key = [NSString stringWithFormat:@"%@failureBlock",NSStringFromClass(self.class)];
    return [self callActionBlockFunction:key];
}

#pragma mark - Private 函数
/**
 *  @author CC, 15-09-21
 *
 *  @brief  存储回调函数
 *
 *  @param key   函数KEY名
 *  @param block 回调函数
 */
- (void)callBackFunction: (NSString *)key withBlock: (id)block
{
    NSMutableDictionary *opreations = (NSMutableDictionary*)objc_getAssociatedObject(self, &OperationKey);

    if(!opreations)
    {
        opreations = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &OperationKey, opreations, OBJC_ASSOCIATION_RETAIN);
    }
    [opreations setObject:block forKey:key];
}

/**
 *  @author CC, 15-09-21
 *
 *  @brief  获取回调函数
 *
 *  @param event 函数KEY名
 *
 *  @return 返回回调函数
 */
-(id)callActionBlockFunction:(NSString *)event
{
    NSMutableDictionary *opreations = (NSMutableDictionary*)objc_getAssociatedObject(self, &OperationKey);
    void(^block)(id sender) = [opreations objectForKey:event];
    return block;
}

#pragma mark - Public 函数
/**
 *  @author CC, 15-08-20
 *
 *  @brief  检测链接服务器网络是否畅通
 *
 *  @param netConnectBlock  网络状态回调
 *  @param requestURLString 服务器网络地址
 *
 *  @since 1.0
 */
- (void) netWorkStateWithNetConnectBlock: (NetWorkBlock) netConnectBlock
                        RequestURLString: (NSString *) requestURLString
{
    BOOL newState = [CCHTTPRequest netWorkReachabilityWithURLString:requestURLString];
    netConnectBlock(newState);
}

/**
 *  @author CC, 15-08-20
 *
 *  @brief  传入交互的Block块
 *
 *  @param returnBlock   完成响应回调
 *  @param errorBlock    错误响应函数
 *  @param faiilureBlock 超时或者请求失败响应函数
 *
 *  @since <#1.0#>
 */
- (void) responseWithBlock: (Completion) returnBlock
            WithErrorBlock: (ErrorCodeBlock) errorBlock
          WithFailureBlock: (FailureBlock)failureBlock
{
    self.returnBlock = returnBlock;
    self.errorBlock = errorBlock;
    self.failureBlock = failureBlock;
}

/**
 *  @author CC, 15-08-20
 *
 *  @brief  获取数据
 *
 *  @since 1.0
 */
- (void) fetchDataSource
{

}

@end
