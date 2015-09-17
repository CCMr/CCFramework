//
//  UIImage+Utility.m
//  CCFramework
//
//  Created by C C on 15/8/17.
//  Copyright (c) 2015年 C C. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

+ (UIImage *)decode:(UIImage *)image {
    if(image == nil) {
        return nil;
    }

    UIGraphicsBeginImageContext(image.size);

    {
        [image drawAtPoint:CGPointMake(0, 0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();

    return image;
}

+ (UIImage *)fastImageWithData:(NSData *)data {
    UIImage *image = [UIImage imageWithData:data];
    return [self decode:image];
}

+ (UIImage *)fastImageWithContentsOfFile:(NSString *)path {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
    return [self decode:image];
}


@end
