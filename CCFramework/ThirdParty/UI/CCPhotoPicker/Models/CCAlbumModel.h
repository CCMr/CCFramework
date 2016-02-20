//
//  CCAlbumModel.h
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

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CCAlbumTypeCarmeraRoll = 1,
    CCAlbumTypeAll,
} CCAlbumType;


@interface CCAlbumModel : NSObject

#pragma mark - Properties

/** 相册的名称 */
@property (nonatomic, copy, readonly, nonnull)   NSString *name;

/** 照片的数量 */
@property (nonatomic, assign, readonly) NSUInteger count;

/** PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset> */
@property (nonatomic, strong, readonly, nonnull) id fetchResult;

#pragma mark - Methods


+ (CCAlbumModel * _Nonnull )albumWithResult:(_Nonnull id)result name:( NSString * _Nonnull )name;

@end
