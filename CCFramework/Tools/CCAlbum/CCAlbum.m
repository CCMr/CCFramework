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
#import "CCProperty.h"

#define documentFolder [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface CCAlbum ()

@property(nonatomic, strong) NSString *representedAssetIdentifier;
@property(nonatomic, assign) PHImageRequestID imageRequestID;

@property(nonatomic, copy) void (^photosBlock)(NSArray *photos);

@end

@implementation CCAlbum

-(void)cameraRolls:(float)photoWith PhotoBlock:(void (^)(NSArray *photos))block
{
    self.photosBlock = block;
    [TZImageManager manager].columnNumber = 4;
    [TZImageManager manager].photoPreviewMaxWidth = 600;
    [TZImageManager manager].shouldFixOrientation = YES;
    [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
        [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {            
            __block NSMutableArray *photos = [NSMutableArray arrayWithArray:models];
            for (NSInteger i =  0; i < models.count; i++) {
                TZAssetModel *assetModel = [models objectAtIndex:i];
                if (iOS8Later) {
                    self.representedAssetIdentifier = [[TZImageManager manager] getAssetIdentifier:assetModel.asset];
                }
                PHImageRequestID imageRequestID = [[TZImageManager manager] getPhotoWithAsset:assetModel.asset photoWidth:photoWith completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    NSMutableDictionary *imageDic = [NSMutableDictionary dictionary];
                    if (!iOS8Later) {
                        [imageDic setObject:photo forKey:@"image"]; return ;
                    }
                    if ([self.representedAssetIdentifier isEqualToString:[[TZImageManager manager] getAssetIdentifier:assetModel.asset]]) {
                        [imageDic setObject:photo forKey:@"image"];
                    } else {
                        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
                    }
                    if (!isDegraded) {
                        self.imageRequestID = 0;
                    }else{
                        [imageDic setObject:assetModel.asset forKey:@"asset"];
                        [photos replaceObjectAtIndex:i withObject:imageDic];
                        for (id item in photos) { if ([item isKindOfClass:[TZAssetModel class]]) return;}
                        self.photosBlock?self.photosBlock(photos):nil;

                    }
                } progressHandler:nil networkAccessAllowed:NO];
                if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
                    [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
                    // NSLog(@"cancelImageRequest %d",self.imageRequestID);
                }
                self.imageRequestID = imageRequestID;
            }
        }];
    }];
}


/**
 获取一组相片大小
 */
+ (void)photosBytesWithArray:(NSArray *)photos completion:(void (^)(NSInteger totalBytes))completion 
{
    [[TZImageManager manager] photosBytesWithArray:photos completion:^(NSInteger totalBytes) {
        completion?completion(totalBytes):nil;
    }];
}

/**
 获取原图
 */
+(void)photoOriginalImage:(id)asset completion:(void (^)(id photo))completion
{
    [[TZImageManager manager] getPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        completion?completion(photo):nil;
    } progressHandler:nil networkAccessAllowed:YES];
}

@end
