//
//  NSURL+Additions.m
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

#import "NSURL+Additions.h"
#import "NSDictionary+Additions.h"
#import "NSString+Additions.h"
#import <objc/runtime.h>

static char *kSizeRequestDataKey = "NSURL.sizeRequestData";
static char *kSizeRequestTypeKey = "NSURL.sizeRequestType";
static char *kSizeRequestCompletionKey = "NSURL.sizeRequestCompletion";

typedef uint32_t dword;

@implementation NSURL (Additions)

- (void)setSizeRequestCompletion:(void (^)(NSURL *imgURL, CGSize size))block
{
    objc_setAssociatedObject(self, &kSizeRequestCompletionKey, block, OBJC_ASSOCIATION_COPY);
}

- (void (^)(NSURL *imgURL, CGSize size))sizeRequestCompletion
{
    return objc_getAssociatedObject(self, &kSizeRequestCompletionKey);
}

- (void)setSizeRequestData:(NSMutableData *)sizeRequestData
{
    objc_setAssociatedObject(self, &kSizeRequestDataKey, sizeRequestData, OBJC_ASSOCIATION_RETAIN);
}

- (NSMutableData *)sizeRequestData
{
    return objc_getAssociatedObject(self, &kSizeRequestDataKey);
}

- (void)setSizeRequestType:(NSString *)sizeRequestType
{
    objc_setAssociatedObject(self, &kSizeRequestTypeKey, sizeRequestType, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)sizeRequestType
{
    return objc_getAssociatedObject(self, &kSizeRequestTypeKey);
}

#pragma mark :. NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [self.sizeRequestData setLength:0]; //Redirected => reset data
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    NSMutableData *receivedData = self.sizeRequestData;
    
    if (!receivedData) {
        receivedData = [NSMutableData data];
        self.sizeRequestData = receivedData;
    }
    
    [receivedData appendData:data];
    
    //Parse metadata
    const unsigned char *cString = [receivedData bytes];
    const NSInteger length = [receivedData length];
    
    const char pngSignature[8] = {137, 80, 78, 71, 13, 10, 26, 10};
    const char bmpSignature[2] = {66, 77};
    const char gifSignature[2] = {71, 73};
    const char jpgSignature[2] = {255, 216};
    
    if (!self.sizeRequestType) {
        if (memcmp(pngSignature, cString, 8) == 0) {
            self.sizeRequestType = @"PNG";
        } else if (memcmp(bmpSignature, cString, 2) == 0) {
            self.sizeRequestType = @"BMP";
        } else if (memcmp(jpgSignature, cString, 2) == 0) {
            self.sizeRequestType = @"JPG";
        } else if (memcmp(gifSignature, cString, 2) == 0) {
            self.sizeRequestType = @"GIF";
        }
    }
    
    if ([self.sizeRequestType isEqualToString:@"PNG"]) {
        char type[5];
        int offset = 8;
        
        dword chunkSize = 0;
        int chunkSizeSize = sizeof(chunkSize);
        
        if (offset + chunkSizeSize > length)
            return;
        
        memcpy(&chunkSize, cString + offset, chunkSizeSize);
        chunkSize = OSSwapInt32(chunkSize);
        offset += chunkSizeSize;
        
        if (offset + chunkSize > length)
            return;
        
        memcpy(&type, cString + offset, 4);
        type[4] = '\0';
        offset += 4;
        
        if (strcmp(type, "IHDR") == 0) { //Should always be first
            dword width = 0, height = 0;
            memcpy(&width, cString + offset, 4);
            offset += 4;
            width = OSSwapInt32(width);
            
            memcpy(&height, cString + offset, 4);
            offset += 4;
            height = OSSwapInt32(height);
            
            if (self.sizeRequestCompletion) {
                self.sizeRequestCompletion(self, CGSizeMake(width, height));
            }
            
            self.sizeRequestCompletion = nil;
            
            [connection cancel];
        }
    } else if ([self.sizeRequestType isEqualToString:@"BMP"]) {
        int offset = 18;
        dword width = 0, height = 0;
        memcpy(&width, cString + offset, 4);
        offset += 4;
        
        memcpy(&height, cString + offset, 4);
        offset += 4;
        
        if (self.sizeRequestCompletion) {
            self.sizeRequestCompletion(self, CGSizeMake(width, height));
        }
        
        self.sizeRequestCompletion = nil;
        
        [connection cancel];
    } else if ([self.sizeRequestType isEqualToString:@"JPG"]) {
        int offset = 4;
        dword block_length = cString[offset] * 256 + cString[offset + 1];
        
        while (offset < length) {
            offset += block_length;
            
            if (offset >= length)
                break;
            if (cString[offset] != 0xFF)
                break;
            if (cString[offset + 1] == 0xC0 ||
                cString[offset + 1] == 0xC1 ||
                cString[offset + 1] == 0xC2 ||
                cString[offset + 1] == 0xC3 ||
                cString[offset + 1] == 0xC5 ||
                cString[offset + 1] == 0xC6 ||
                cString[offset + 1] == 0xC7 ||
                cString[offset + 1] == 0xC9 ||
                cString[offset + 1] == 0xCA ||
                cString[offset + 1] == 0xCB ||
                cString[offset + 1] == 0xCD ||
                cString[offset + 1] == 0xCE ||
                cString[offset + 1] == 0xCF) {
                
                dword width = 0, height = 0;
                
                height = cString[offset + 5] * 256 + cString[offset + 6];
                width = cString[offset + 7] * 256 + cString[offset + 8];
                
                if (self.sizeRequestCompletion) {
                    self.sizeRequestCompletion(self, CGSizeMake(width, height));
                }
                
                self.sizeRequestCompletion = nil;
                
                [connection cancel];
                
            } else {
                offset += 2;
                block_length = cString[offset] * 256 + cString[offset + 1];
            }
        }
    } else if ([self.sizeRequestType isEqualToString:@"GIF"]) {
        int offset = 6;
        dword width = 0, height = 0;
        memcpy(&width, cString + offset, 2);
        offset += 2;
        
        memcpy(&height, cString + offset, 2);
        offset += 2;
        
        if (self.sizeRequestCompletion) {
            self.sizeRequestCompletion(self, CGSizeMake(width, height));
        }
        
        self.sizeRequestCompletion = nil;
        
        [connection cancel];
    }
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    if (self.sizeRequestCompletion)
        self.sizeRequestCompletion(self, CGSizeZero);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Basically, we failed to obtain the image size using metadata and the
    // entire image was downloaded...
    
    if (!self.sizeRequestData.length) {
        self.sizeRequestData = nil;
    } else {
        //Try parse to UIImage
        UIImage *image = [UIImage imageWithData:self.sizeRequestData];
        
        if (self.sizeRequestCompletion && image) {
            self.sizeRequestCompletion(self, [image size]);
            return;
        }
    }
    
    self.sizeRequestCompletion(self, CGSizeZero);
}

#pragma mark -
#pragma mark :. Param
/**
 *  @brief  url参数转字典
 *
 *  @return 参数转字典结果
 */
- (NSDictionary *)parameters
{
    NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];
    NSArray *queryComponents = [self.query componentsSeparatedByString:@"&"];
    for (NSString *queryComponent in queryComponents) {
        NSString *key = [queryComponent componentsSeparatedByString:@"="].firstObject;
        NSString *value = [queryComponent substringFromIndex:(key.length + 1)];
        [parametersDictionary setObject:value forKey:key];
    }
    return parametersDictionary;
}
/**
 *  @brief  根据参数名 取参数值
 *
 *  @param parameterKey 参数名的key
 *
 *  @return 参数值
 */
- (NSString *)valueForParameter:(NSString *)parameterKey
{
    return [[self parameters] objectForKey:parameterKey];
}

#pragma mark-
#pragma mark :. QueryDictionary

static NSString *const kQuerySeparator = @"&";
static NSString *const kQueryBegin = @"?";
static NSString *const kFragmentBegin = @"#";

- (NSDictionary *)cc_queryDictionary
{
    return self.query.cc_URLQueryDictionary;
}

- (NSURL *)cc_URLByAppendingQueryDictionary:(NSDictionary *)queryDictionary
{
    return [self cc_URLByAppendingQueryDictionary:queryDictionary withSortedKeys:NO];
}

- (NSURL *)cc_URLByAppendingQueryDictionary:(NSDictionary *)queryDictionary
                             withSortedKeys:(BOOL)sortedKeys
{
    NSMutableArray *queries = [self.query length] > 0 ? @[ self.query ].mutableCopy : @[].mutableCopy;
    NSString *dictionaryQuery = [queryDictionary cc_URLQueryStringWithSortedKeys:sortedKeys];
    if (dictionaryQuery) {
        [queries addObject:dictionaryQuery];
    }
    NSString *newQuery = [queries componentsJoinedByString:kQuerySeparator];
    
    if (newQuery.length) {
        NSArray *queryComponents = [self.absoluteString componentsSeparatedByString:kQueryBegin];
        if (queryComponents.count) {
            return [NSURL URLWithString:
                    [NSString stringWithFormat:@"%@%@%@%@%@",
                     queryComponents[0], // existing url
                     kQueryBegin,
                     newQuery,
                     self.fragment.length ? kFragmentBegin : @"",
                     self.fragment.length ? self.fragment : @""]];
        }
    }
    return self;
}

- (NSURL *)cc_URLByRemovingQuery
{
    NSArray *queryComponents = [self.absoluteString componentsSeparatedByString:kQueryBegin];
    if (queryComponents.count) {
        return [NSURL URLWithString:queryComponents.firstObject];
    }
    return self;
}

- (NSURL *)cc_URLByReplacingQueryWithDictionary:(NSDictionary *)queryDictionary
{
    return [self cc_URLByReplacingQueryWithDictionary:queryDictionary withSortedKeys:NO];
}

- (NSURL *)cc_URLByReplacingQueryWithDictionary:(NSDictionary *)queryDictionary
                                 withSortedKeys:(BOOL)sortedKeys
{
    NSURL *stripped = [self cc_URLByRemovingQuery];
    return [stripped cc_URLByAppendingQueryDictionary:queryDictionary withSortedKeys:sortedKeys];
}

@end
