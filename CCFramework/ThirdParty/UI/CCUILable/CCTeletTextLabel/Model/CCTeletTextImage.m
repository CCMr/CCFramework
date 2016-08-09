//
//  CCTeletTextImage.m
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCTeletTextImage.h"

@implementation CCTeletTextImage

- (UIImageView *)imageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.imageRect];
    imageView.image = self.image;
    return imageView;
}

/**
 *  @author CC, 16-07-20
 *
 *  @brief 设置网络图片大小
 */
- (void)setURLImageSize
{
    _imageSize = [self getImageSizeWithURL:_imagePath];
}

// 根据图片url获取图片尺寸
- (CGSize)getImageSizeWithURL:(id)imageURL
{
    NSURL *URL = nil;
    if ([imageURL isKindOfClass:[NSURL class]]) {
        URL = imageURL;
    }
    if ([imageURL isKindOfClass:[NSString class]]) {
        URL = [NSURL URLWithString:imageURL];
    }
    if (URL == nil)
        return CGSizeZero; // url不正确返回CGSizeZero

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSString *pathExtendsion = [URL.pathExtension lowercaseString];

    CGSize urlImageSize = CGSizeZero;
    if ([pathExtendsion isEqualToString:@"png"]) {
        urlImageSize = [self getPNGImageSizeWithRequest:request];
    } else if ([pathExtendsion isEqual:@"gif"]) {
        urlImageSize = [self getGIFImageSizeWithRequest:request];
    } else {
        urlImageSize = [self getJPGImageSizeWithRequest:request];
    }

    if (CGSizeEqualToSize(CGSizeZero, urlImageSize)) { // 如果获取文件头信息失败,发送异步请求请求原图
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
        UIImage *image = [UIImage imageWithData:data];
        if (image)
            urlImageSize = image.size;
    }

    CGSize linkSize = self.imageSize;
    if (self.adjustType == 1) {
        linkSize = urlImageSize;
    } else if (self.adjustType == 2) { //指定宽度，等比缩放
        if (linkSize.width < urlImageSize.width)
            linkSize.height = (linkSize.width / urlImageSize.width) * urlImageSize.height;
        else
            linkSize.height = urlImageSize.height;
    } else if (self.adjustType == 3) { //指定高度，等比缩放
        if (linkSize.height < urlImageSize.height)
            linkSize.width = (linkSize.height / urlImageSize.height) * urlImageSize.width;
        else
            linkSize.width = urlImageSize.width;
    }

    return linkSize;
}
//  获取PNG图片的大小
- (CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data.length == 8) {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取gif图片的大小
- (CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (data.length == 4) {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}
//  获取jpg图片的大小
- (CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest *)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

    if ([data length] <= 0x58) {
        return CGSizeZero;
    }

    if ([data length] < 210) { // 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) { // 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else { // 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

@end
