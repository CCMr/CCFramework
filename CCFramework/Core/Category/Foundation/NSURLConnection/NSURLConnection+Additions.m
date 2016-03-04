//
//  NSURLConnection+Additions.m
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

#import "NSURLConnection+Additions.h"

/**
 *  Internal wrapper for the connection and handler
 */
@interface NSURLConnectionDelegateWrapper : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

+ (NSURLConnectionDelegateWrapper *)wrapperWithHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler;
+ (NSMutableArray *)wrappers;
@property(nonatomic, strong) NSURLConnection *connection;

@end

@implementation NSURLConnectionDelegateWrapper {
    void (^_handler)(NSURLResponse *, NSData *, NSError *);
    NSMutableData *_responseData;
    NSURLResponse *_urlResponse;
    NSError *_error;
}

/**
 *  Convenience method to get a wrapper with given handler
 *
 */
+ (NSURLConnectionDelegateWrapper *)wrapperWithHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSURLConnectionDelegateWrapper *wrapper = [NSURLConnectionDelegateWrapper new];
    wrapper->_handler = handler;
    wrapper->_responseData = [NSMutableData new];
    @synchronized([NSURLConnectionDelegateWrapper wrappers])
    {
        [[NSURLConnectionDelegateWrapper wrappers] addObject:wrapper];
    }
    return wrapper;
}

/**
 *  Contains the wrappers that are currently in-use
 */
+ (NSMutableArray *)wrappers
{
    static NSMutableArray *_wrappers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _wrappers = [NSMutableArray new];
    });
    return _wrappers;
}

#pragma mark - NSURLConnection delegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _urlResponse = response;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The request is complete and data has been received
    _handler(_urlResponse, _responseData, _error);
    @synchronized([NSURLConnectionDelegateWrapper wrappers])
    {
        [[NSURLConnectionDelegateWrapper wrappers] removeObject:self];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    _error = error;
    _handler(_urlResponse, _responseData, _error);
    @synchronized([NSURLConnectionDelegateWrapper wrappers])
    {
        [[NSURLConnectionDelegateWrapper wrappers] removeObject:self];
    }
}

@end


@implementation NSURLConnection (Additions)

+ (void)sendAsynchronousRequestAcceptingAllCerts:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler
{
    NSURLConnectionDelegateWrapper *wrapper = [NSURLConnectionDelegateWrapper wrapperWithHandler:handler];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:wrapper startImmediately:NO];
    [wrapper setConnection:connection];
    [connection setDelegateQueue:queue];
    [connection start];
}

@end
