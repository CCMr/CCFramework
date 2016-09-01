//
//  CCPreViewController.m
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

#import "CCPreViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import "CCPreviewItem.h"


static NSString *CCMD5StringFromNSString(NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([data bytes], [data length], digest);
    NSMutableString *result = [NSMutableString string];
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", (int)(digest[i])];
    }
    return [result copy];
}

static NSString *CCLocalFilePathForURL(NSURL *URL)
{
    NSString *fileExtension = [URL pathExtension];
    NSString *hashedURLString = CCMD5StringFromNSString([URL absoluteString]);
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"com.cc.RemoteQuickLook"];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:&error];
        if (!isDirectoryCreated) {
            NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                             reason:@"Failed to crate cache directory"
                                                           userInfo:@{NSUnderlyingErrorKey : error}];
            @throw exception;
        }
    }
    NSString *temporaryFilePath = [[cacheDirectory stringByAppendingPathComponent:hashedURLString] stringByAppendingPathExtension:fileExtension];
    return temporaryFilePath;
}


@interface CCPreViewController ()

@property(nonatomic, weak) id<QLPreviewControllerDataSource> actualDataSource;

@end

@implementation CCPreViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return [self.actualDataSource numberOfPreviewItemsInPreviewController:controller];
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    id<QLPreviewItem> originalPreviewItem = [self.actualDataSource previewController:controller previewItemAtIndex:index];

    CCPreviewItem *previewItemCopy = [CCPreviewItem previewItemWithURL:originalPreviewItem.previewItemURL
                                                                 title:originalPreviewItem.previewItemTitle];

    NSURL *originalURL = previewItemCopy.previewItemURL;
    if (!originalURL || [originalURL isFileURL])
        return previewItemCopy;

    // If it's a remote file, check cache
    NSString *localFilePath = CCLocalFilePathForURL(originalURL);
    previewItemCopy.previewItemURL = [NSURL fileURLWithPath:localFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath])
        return previewItemCopy;

    // If it's not a local file, put a placeholder instead
    __block NSInteger capturedIndex = index;
    NSURLRequest *request = [NSURLRequest requestWithURL:originalURL];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.inputStream = [NSInputStream inputStreamWithURL:originalURL];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:localFilePath append:NO];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // FIXME: Sometime remote preview item isn't getting updated
            // When pan gesture isn't finished so that two preview items can be seen at the same time upcomming item isn't getting updated, fixes are very welcome!
            if (controller.currentPreviewItemIndex == capturedIndex)
                [controller refreshCurrentPreviewItem];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(cc_previewController:failedToLoadRemotePreviewItem:withError:)]) {
            [self.delegate cc_previewController:self
                  failedToLoadRemotePreviewItem:originalPreviewItem
                                      withError:error];
        }
    }];

    [operation start];

    return previewItemCopy;
}

#pragma mark - Properties

- (void)setDataSource:(id<QLPreviewControllerDataSource>)dataSource
{
    self.actualDataSource = dataSource;
    [super setDataSource:self];
}

- (id<QLPreviewControllerDataSource>)dataSource
{
    return self.actualDataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
