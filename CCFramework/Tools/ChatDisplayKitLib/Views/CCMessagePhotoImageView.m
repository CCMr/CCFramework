//
//  CCMessagePhotoImageView.m
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

#import "CCMessagePhotoImageView.h"
#import "UIImage+Additions.h"
#import "UIImageView+Additions.h"

@interface CCMessagePhotoImageView ()

/**
 *  @author CC, 2016-12-28
 *  
 *  @brief  显示图片
 */
@property(nonatomic, strong) UIImageView *imageView;

@end

@implementation CCMessagePhotoImageView

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.backgroundColor = [UIColor clearColor];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 1.0f, 1.0f)];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.imageView];
}

/**
 *  @author CC, 2016-12-28
 *  
 *  @brief  设置图片
 *
 *  @param image 图片
 */
- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

/**
 *  @author CC, 2016-12-28
 *  
 *  @brief  设置图片
 *
 *  @param imageFilePath 图片路径
 */
- (void)setImageFilePath:(NSString *)imageFilePath
{
    if ([imageFilePath rangeOfString:@"http://"].location != NSNotFound) {
        [self.imageView sd_setImageWithURLStr:imageFilePath placeholderImage:[UIImage imageNamed:@"other_placeholderImg"]];
    } else {
        self.image = [UIImage cc_imageWithData:[NSData dataWithContentsOfFile:imageFilePath]];
    }
}

@end
