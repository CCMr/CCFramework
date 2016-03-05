//
//  CCDebugHttpDataSource.m
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

#import "CCDebugHttpDataSource.h"

@implementation CCDebugHttpModel
@end

@implementation CCDebugHttpDataSource


+ (instancetype)manager
{
    static CCDebugHttpDataSource *tool;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[CCDebugHttpDataSource alloc] init];
    });
    return tool;
}

- (id)init
{
    self = [super init];
    if (self) {
        _httpArray = [NSMutableArray array];
        _arrRequest = [NSMutableArray array];
    }
    return self;
}

- (void)addHttpRequset:(CCDebugHttpModel *)model
{
    @synchronized(self.httpArray)
    {
        [self.httpArray insertObject:model atIndex:0];
    }
    @synchronized(self.arrRequest)
    {
        if (model.requestId && model.requestId.length > 0) {
            [self.arrRequest addObject:model.requestId];
        }
    }
}

- (void)clear
{
    @synchronized(self.httpArray)
    {
        [self.httpArray removeAllObjects];
    }
    @synchronized(self.arrRequest)
    {
        [self.arrRequest removeAllObjects];
    }
}


#pragma mark - parse
+ (NSString *)prettyJSONStringFromData:(NSData *)data
{
    NSString *prettyString = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
        prettyString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL] encoding:NSUTF8StringEncoding];
        // NSJSONSerialization escapes forward slashes. We want pretty json, so run through and unescape the slashes.
        prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    } else {
        prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    return prettyString;
}

@end
