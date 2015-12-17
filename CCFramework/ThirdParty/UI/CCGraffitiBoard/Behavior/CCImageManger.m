//
//  CCImageManger.m
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

#import "CCImageManger.h"


/** 自己的图片缓存文件夹路径. */
static inline NSString *CCImageCachesPath()
{
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent:@"CCImageCaches"];
}

/** 指定缓存文件索引并生成保存路径. */
static inline NSString *CCImageCachePathForIndex(NSInteger imageIndex)
{
    return [CCImageCachesPath() stringByAppendingPathComponent:
            [NSString stringWithFormat:@"%ld.png", (long)(imageIndex)]];
}

/** 无效索引. */
static const NSInteger kInvalidIndex = -1;


@interface CCImageManger ()

/** 当前图片索引. */
@property(nonatomic) NSInteger imageIndex;

/** 图片总数. */
@property(nonatomic) NSUInteger totalOfImages;

/** 读写图片的串行队列. */
@property(nonatomic, strong) dispatch_queue_t imageIOQueue;

@end


@implementation CCImageManger

#pragma mark - 获取图片管理者

+ (instancetype)sharedImageManger
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedImageManger];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageIndex = kInvalidIndex;
        _imageIOQueue = dispatch_queue_create("com.nizi.imageIOQueue", DISPATCH_QUEUE_SERIAL);
        [[NSFileManager defaultManager] createDirectoryAtPath:CCImageCachesPath()
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return self;
}

#pragma mark - 添加图片

- (void)addImage:(UIImage *)image
{
    self.totalOfImages = ++self.imageIndex + 1;
    
    // 后台写入硬盘.
    NSInteger index = self.imageIndex;
    dispatch_async(self.imageIOQueue, ^{
        [UIImagePNGRepresentation(image) writeToFile:CCImageCachePathForIndex(index) atomically:YES];
    });
}

#pragma mark - 撤销

- (BOOL)canUndo
{
    return self.imageIndex >= 0;
}

- (UIImage *)imageForUndo
{
    if (![self canUndo]) return nil;
    
    if (--self.imageIndex == kInvalidIndex) return nil;
    
    __block UIImage *image;
    dispatch_sync(self.imageIOQueue, ^{
        image = [UIImage imageWithContentsOfFile:CCImageCachePathForIndex(self.imageIndex)];
    });
    return image;
}

#pragma mark - 恢复

- (BOOL)canRedo
{
    return ((NSUInteger)self.imageIndex + 1) < self.totalOfImages;
}

- (UIImage *)imageForRedo
{
    if (![self canRedo]) return nil;
    
    __block UIImage *image;
    dispatch_sync(self.imageIOQueue, ^{
        image = [UIImage imageWithContentsOfFile:CCImageCachePathForIndex(++self.imageIndex)];
    });
    return image;
}

#pragma mark - 移除所有图片

- (void)removeAllImages
{
    self.imageIndex = kInvalidIndex;
    
    dispatch_sync(self.imageIOQueue, ^{
        [[NSFileManager defaultManager] removeItemAtPath:CCImageCachesPath() error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:CCImageCachesPath()
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    });
}

@end