//
//  CCAlbum.m
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

#import "CCAlbum.h"
#import "TZImageManager.h"
#import "TZAssetModel.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation CCAlbum

/**
 获取相机胶卷所有照片
 */
+(void)cameraRolls:(void (^)(NSArray *photos))block
{
   __block void (^photosBlock)(NSArray *photos) = block;
    [TZImageManager manager].photoPreviewMaxWidth = 600;
    [TZImageManager manager].shouldFixOrientation = YES;
    [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
        [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
             __block NSMutableArray *photos = [NSMutableArray array];
            for (NSInteger i = 0; i < models.count; i++) {
                TZAssetModel *assetModel = [models objectAtIndex:i];
                [photos addObject:@1];
                [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    if (isDegraded) return;
                    if (photo) {
                        NSString *imageType;
                        NSString *imageFileURL = [info objectForKey:@"PHImageFileURLKey"];
                        if ([info[@"PHImageFileUTIKey"] isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                            imageType = @"gif";
                        }else if ([info[@"PHImageFileUTIKey"] isEqualToString:(__bridge NSString *)kUTTypeJPEG]){
                            imageType = @"jpge";
                        }else if ([info[@"PHImageFileUTIKey"] isEqualToString:(__bridge NSString *)kUTTypePNG]){
                            imageType = @"png";
                        }
                        
                        NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
                        [imageDic setObject:photo forKey:@"image"];
                        [imageDic setObject:imageType?:@"" forKey:@"imageType"];
                        [imageDic setObject:imageFileURL?:@"" forKey:@"imageFileURL"];
                        [photos replaceObjectAtIndex:i withObject:imageDic];
                        
                        NSArray *arr = [photos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %d", 1]];
                        if (arr.count != 0)
                            return;
                        
                        photosBlock?photosBlock(photos):nil;
                    }
                }];
            }
        }];
    }];
}

@end
