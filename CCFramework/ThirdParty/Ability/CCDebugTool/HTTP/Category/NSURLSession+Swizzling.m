//
//  NSURLSession+Swizzling.m
//  CCFramework
//
//  Created by CC on 16/3/5.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "NSURLSession+Swizzling.h"
#import <objc/runtime.h>
#import "CCDebugHttpDataSource.h"
#import "CCDebugTool.h"
#import "NSURLRequest+Identify.h"
#import "NSURLResponse+Data.h"
#import "NSURLSessionTask+Data.h"

@class NSURLSession;

@implementation NSURLSession (Swizzling)

+ (void)load
{
    
    Method oriMethod = class_getInstanceMethod([NSURLSession class], @selector(dataTaskWithRequest:));
    Method newMethod = class_getInstanceMethod([NSURLSession class], @selector(dataTaskWithRequest_swizzling:));
    method_exchangeImplementations(oriMethod, newMethod);
    
    const SEL selectors_data[] = {
        @selector(URLSession:dataTask:didReceiveResponse:completionHandler:),
        @selector(URLSession:dataTask:didBecomeDownloadTask:),
        @selector(URLSession:dataTask:didBecomeStreamTask:),
        @selector(URLSession:dataTask:didReceiveData:),
        @selector(URLSession:dataTask:willCacheResponse:completionHandler:)
    };
    
    const int numSelectors_data = sizeof(selectors_data) / sizeof(SEL);
    
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);
    for (NSInteger classIndex = 0; classIndex < numClasses; ++classIndex) {
        Class class = classes[classIndex];
        
        unsigned int methodCount = 0;
        Method *methods = class_copyMethodList(class, &methodCount);
        BOOL matchingSelectorFound = NO;
        for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex++) {
            for (int selectorIndex = 0; selectorIndex < numSelectors_data; ++selectorIndex) {
                if (method_getName(methods[methodIndex]) == selectors_data[selectorIndex]) {
                    [self swizzling_selectors_task:class];
                    [self swizzling_selectors_data:class];
                    matchingSelectorFound = YES;
                    break;
                }
            }
            if (matchingSelectorFound) {
                break;
            }
        }
    }
}

#pragma mark - NSURLSession task delegate with swizzling
+ (void)swizzling_selectors_task:(Class)cls
{
    [self swizzling_TaskWillPerformHTTPRedirectionIntoDelegateClass:cls];
    [self swizzling_TaskDidSendBodyDataIntoDelegateClass:cls];
    [self swizzling_TaskDidReceiveChallengeIntoDelegateClass:cls];
    [self swizzling_TaskNeedNewBodyStreamIntoDelegateClass:cls];
    [self swizzling_TaskDidCompleteWithErrorIntoDelegateClass:cls];
}

+ (void)swizzling_TaskWillPerformHTTPRedirectionIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:);
    SEL swizzledSelector = @selector(URLSession_swizzling:task:willPerformHTTPRedirection:newRequest:completionHandler:);
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)swizzling_TaskDidSendBodyDataIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:);
    SEL swizzledSelector = @selector(URLSession_swizzling:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:);
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)swizzling_TaskDidReceiveChallengeIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:task:didReceiveChallenge:completionHandler:);
    SEL swizzledSelector = @selector(URLSession_swizzling:task:didReceiveChallenge:completionHandler:);
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)swizzling_TaskNeedNewBodyStreamIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession_swizzling:task:needNewBodyStream:);
    SEL swizzledSelector = @selector(URLSession_swizzling:task:needNewBodyStream:);
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)swizzling_TaskDidCompleteWithErrorIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:task:didCompleteWithError:);
    SEL swizzledSelector = @selector(URLSession_swizzling:task:didCompleteWithError:);
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

#pragma mark - NSURLSession task delegate
- (void)URLSession_swizzling:(NSURLSession *)session
                        task:(NSURLSessionTask *)task
  willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                  newRequest:(NSURLRequest *)request
           completionHandler:(void (^)(NSURLRequest *__nullable))completionHandler
{
    [self URLSession_swizzling:session
                          task:task
    willPerformHTTPRedirection:response
                    newRequest:request
             completionHandler:completionHandler];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                        task:(NSURLSessionTask *)task
             didSendBodyData:(int64_t)bytesSent
              totalBytesSent:(int64_t)totalBytesSent
    totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSURLRequest *req = task.originalRequest;
    req.requestId = [[NSUUID UUID] UUIDString];
    req.startTime = @([[NSDate date] timeIntervalSince1970]);
    [self URLSession_swizzling:session
                          task:task
               didSendBodyData:bytesSent
                totalBytesSent:totalBytesSent
      totalBytesExpectedToSend:totalBytesExpectedToSend];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                        task:(NSURLSessionTask *)task
         didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
           completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler
{
    [self URLSession_swizzling:session
                          task:task
           didReceiveChallenge:challenge
             completionHandler:completionHandler];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                        task:(NSURLSessionTask *)task
           needNewBodyStream:(void (^)(NSInputStream *__nullable bodyStream))completionHandler
{
    [self URLSession_swizzling:session
                          task:task
             needNewBodyStream:completionHandler];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                        task:(NSURLSessionTask *)task
        didCompleteWithError:(nullable NSError *)error
{
    [self URLSession_swizzling:session task:task didCompleteWithError:error];
    
    NSURLRequest *req = task.originalRequest;
    if ([[[CCDebugHttpDataSource manager] arrRequest] containsObject:req.requestId])
        return;
    
    BOOL canHandle = YES;
    if ([[CCDebugTool manager] arrOnlyHosts].count > 0) {
        canHandle = NO;
        NSString *url = [req.URL.absoluteString lowercaseString];
        for (NSString *_url in [CCDebugTool manager].arrOnlyHosts) {
            if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound) {
                canHandle = YES;
                break;
            }
        }
    }
    if (!canHandle)
        return;
    
    NSURLResponse *resp = task.response;
    
    CCDebugHttpModel *model = [[CCDebugHttpModel alloc] init];
    model.requestId = req.requestId;
    model.url = req.URL;
    model.method = req.HTTPMethod;
    if (req.HTTPBody) {
        model.requestBody = [CCDebugHttpDataSource prettyJSONStringFromData:req.HTTPBody];
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)resp;
    model.statusCode = [NSString stringWithFormat:@"%d", (int)httpResponse.statusCode];
    if (task.responseDatas) {
        model.responseBody = [CCDebugHttpDataSource prettyJSONStringFromData:task.responseDatas];
    }
    model.mineType = resp.MIMEType;
    
    model.totalDuration = [NSString stringWithFormat:@"%fs", [[NSDate date] timeIntervalSince1970] - req.startTime.doubleValue];
    model.startTime = [NSString stringWithFormat:@"%fs", req.startTime.doubleValue];
    
    [[CCDebugHttpDataSource manager] addHttpRequset:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCCNotifyKeyReloadHttp object:nil];
}


#pragma mark - NSUrlSession data delegate with swizzling
+ (void)swizzling_selectors_data:(Class)cls
{
    [self swizzling_TaskDidReceiveResponseIntoDelegateClass:cls];
    [self swizzling_TaskDidReceiveDataIntoDelegateClass:cls];
    [self swizzling_TaskDidBecomeDownloadTaskIntoDelegateClass:cls];
    [self swizzling_TaskDidBecomeStreamTaskIntoDelegateClass:cls];
    //    [self swizzling_TaskWillCacheResponseIntoDelegateClass:cls];
}

+ (void)swizzling_TaskDidReceiveResponseIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:didReceiveResponse:completionHandler:);
    SEL swizzledSelector = @selector(URLSession_swizzling:dataTask:didReceiveResponse:completionHandler:);
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)swizzling_TaskDidReceiveDataIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:didReceiveData:);
    SEL swizzledSelector = @selector(URLSession_swizzling:dataTask:didReceiveData:);
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)swizzling_TaskDidBecomeDownloadTaskIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:didBecomeDownloadTask:);
    SEL swizzledSelector = @selector(URLSession_swizzling:dataTask:didBecomeDownloadTask:);
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}
+ (void)swizzling_TaskDidBecomeStreamTaskIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:didBecomeStreamTask:);
    SEL swizzledSelector = @selector(URLSession_swizzling:dataTask:didBecomeStreamTask:);
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)swizzling_TaskWillCacheResponseIntoDelegateClass:(Class)cls
{
    SEL selector = @selector(URLSession:dataTask:willCacheResponse:completionHandler:);
    SEL swizzledSelector = @selector(URLSession_swizzling:dataTask:willCacheResponse:completionHandler:);
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodDescription = protocol_getMethodDescription(protocol, selector, NO, YES);
    [self replaceImplementationOfSelector:selector
                             withSelector:swizzledSelector
                                 forClass:cls
                    withMethodDescription:methodDescription];
}

+ (void)replaceImplementationOfSelector:(SEL)selector
                           withSelector:(SEL)swizzledSelector
                               forClass:(Class)cls
                  withMethodDescription:(struct objc_method_description)methodDescription
{
    IMP implementation = class_getMethodImplementation([self class], swizzledSelector);
    Method oldMethod = class_getInstanceMethod(cls, selector);
    if (oldMethod) {
        class_addMethod(cls, swizzledSelector, implementation, methodDescription.types);
        Method newMethod = class_getInstanceMethod(cls, swizzledSelector);
        method_exchangeImplementations(oldMethod, newMethod);
    } else {
        class_addMethod(cls, selector, implementation, methodDescription.types);
    }
}


#pragma mark - NSUrlSession delegate
- (NSURLSessionDataTask *)dataTaskWithRequest_swizzling:(NSURLRequest *)request
{
    return [self dataTaskWithRequest_swizzling:request];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                    dataTask:(NSURLSessionDataTask *)dataTask
          didReceiveResponse:(NSURLResponse *)response
           completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self URLSession_swizzling:session
                      dataTask:dataTask
            didReceiveResponse:response
             completionHandler:completionHandler];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                    dataTask:(NSURLSessionDataTask *)dataTask
              didReceiveData:(NSData *)data
{
    if (!dataTask.responseDatas) {
        dataTask.responseDatas = [NSMutableData data];
        dataTask.taskDataIdentify = NSStringFromClass([self class]);
    }
    if ([dataTask.taskDataIdentify isEqualToString:NSStringFromClass([self class])])
        [dataTask.responseDatas appendData:data];
    [self URLSession_swizzling:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                    dataTask:(NSURLSessionDataTask *)dataTask
       didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    [self URLSession_swizzling:session
                      dataTask:dataTask
         didBecomeDownloadTask:downloadTask];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                    dataTask:(NSURLSessionDataTask *)dataTask
         didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask
{
    [self URLSession_swizzling:session
                      dataTask:dataTask
           didBecomeStreamTask:streamTask];
}

- (void)URLSession_swizzling:(NSURLSession *)session
                    dataTask:(NSURLSessionDataTask *)dataTask
           willCacheResponse:(NSCachedURLResponse *)proposedResponse
           completionHandler:(void (^)(NSCachedURLResponse *__nullable cachedResponse))completionHandler
{
    [self URLSession_swizzling:session
                      dataTask:dataTask
             willCacheResponse:proposedResponse
             completionHandler:completionHandler];
}


@end
