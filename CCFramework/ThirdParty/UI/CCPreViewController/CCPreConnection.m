//
//  CCPreViewController.h
//  CCFramework
//
// Copyright (c) 2017 CC ( http://www.ccskill.com )
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


#import "CCPreConnection.h"

@interface CCPreConnection () <NSURLConnectionDataDelegate>

/** 用来写数据的文件句柄对象 **/
@property (nonatomic, strong) NSFileHandle *writeHandle;

/** 网络请求地址 **/
@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, copy) void (^success)();
@property (nonatomic, copy) void (^failure)(NSError *error);

@end

@implementation CCPreConnection

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    if (self = [super init]) {
        self.request = request;
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure
{
    self.success = success;
    self.failure = failure;
    [NSURLConnection connectionWithRequest:_request delegate:self];
}

#pragma mark -
#pragma mark :. NSURLConnectionDataDelegate
/**
 请求失败时调用（请求超时、网络异常）
 
 @param connection connection
 @param error 错误原因
 */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.failure ? self.failure(error) : nil;
}

/**
 接收到服务器的响应就会调用
 
 @param connection connection
 @param response 响应请求
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSString *filepath = _filepath;
    if (!filepath) {
        NSString *ceches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        filepath = [ceches stringByAppendingPathComponent:response.suggestedFilename];
    }
    
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr createFileAtPath:filepath contents:nil attributes:nil];
    
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
}

/**
 当接收到服务器返回的实体数据时调用
 
 @param connection connection
 @param data 这次返回的数据
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.writeHandle seekToEndOfFile];
    [self.writeHandle writeData:data];
}

/** 加载完毕后调用（服务器的数据已经完全返回后）**/
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.writeHandle closeFile];
    self.writeHandle = nil;
    self.success?self.success():nil;
}


@end
