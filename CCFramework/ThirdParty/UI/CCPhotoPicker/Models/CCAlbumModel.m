//
//  CCAlbumModel.m
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

#import "CCAlbumModel.h"
#import <Photos/PHFetchResult.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import "config.h"

@interface CCAlbumModel ()

/** 相册的名称 */
@property (nonatomic, copy)   NSString *name;

/** 照片的数量 */
@property (nonatomic, assign) NSUInteger count;

/** PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset> */
@property (nonatomic, strong) id fetchResult;

@end

@implementation CCAlbumModel

#pragma mark - Methods

+ (CCAlbumModel *)albumWithResult:(id)result name:(NSString *)name {
    CCAlbumModel *model = [[CCAlbumModel alloc] init];
    model.fetchResult = result;
    model.name = [self _albumNameWithOriginName:name];
    if ([result isKindOfClass:[PHFetchResult class]]) {
        PHFetchResult *fetchResult = (PHFetchResult *)result;
        model.count = fetchResult.count;
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    } else if ([result isKindOfClass:[ALAssetsGroup class]]) {
        ALAssetsGroup *gruop = (ALAssetsGroup *)result;
        model.count = [gruop numberOfAssets];
#pragma clang diagnostic pop
    }
    return model;
}

+ (NSString *)_albumNameWithOriginName:(NSString *)name {
    if (iOS8Later) {
        NSString *newName;
        if ([name containsString:@"Roll"])         newName = @"相机胶卷";
        else if ([name containsString:@"Stream"])  newName = @"我的照片流";
        else if ([name containsString:@"Added"])   newName = @"最近添加";
        else if ([name containsString:@"Selfies"]) newName = @"自拍";
        else if ([name containsString:@"shots"])   newName = @"截屏";
        else if ([name containsString:@"Videos"])  newName = @"视频";
        else newName = name;
        return newName;
    } else {
        return name;
    }
}


#pragma mark - Getters

- (NSString *)description {
    return [NSString stringWithFormat:@"\n-----album desc start--\nalbum :%@ have %zi photos \nresult :%@\n-----album desc end----",self.name,self.count,self.fetchResult];
}


@end
