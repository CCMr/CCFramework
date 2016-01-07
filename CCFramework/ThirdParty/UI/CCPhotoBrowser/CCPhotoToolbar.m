/*
 *  CCPhotoToolbar.m
 *  CCFramework
 *
 * Copyright (c) 2015 CC (http://www.ccskill.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCPhotoToolbar.h"
#import "CCPhoto.h"
#import "MBProgressHUD+Add.h"
#import "UIControl+BUIControl.h"
#import "Config.h"
#import "UIButton+BUIButton.h"

@interface CCPhotoToolbar()
{
    // 显示页码
    UILabel *_indexLabel;
    UIButton *saveImageBtn;
    
    UIButton *completeBtn;
    UILabel *SendCountLabel;
    BOOL _IsComlete;
}
@end

@implementation CCPhotoToolbar

-(id)initWithComplete{
    if (self = [super init]) {
        _IsComlete = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (_photos.count > 0) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }
    
    // 保存图片按钮
    CGFloat btnWidth = self.bounds.size.height;
    saveImageBtn = [UIButton buttonWith];
    saveImageBtn.frame = CGRectMake(20, 5, btnWidth - 10, btnWidth - 10);
    saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [saveImageBtn setImage:CCResourceImage(@"save_icon") forState:UIControlStateNormal];
    [saveImageBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            CCPhoto *photo = _photos[_currentPhotoIndex];
            UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        });
    }];
    [self addSubview:saveImageBtn];
    
    
    SendCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - (btnWidth + 30), (btnWidth - 20) / 2, 20, 20)];
    SendCountLabel.backgroundColor =  cc_ColorRGBA(0, 204, 51, 1);
    SendCountLabel.layer.cornerRadius = 10;
    SendCountLabel.layer.masksToBounds = YES;
    SendCountLabel.textColor = [UIColor whiteColor];
    SendCountLabel.textAlignment = NSTextAlignmentCenter;
    SendCountLabel.hidden = YES;
    [self addSubview:SendCountLabel];
    
    if (_IsComlete) {
        saveImageBtn.hidden = YES;
        completeBtn = [UIButton buttonWithTitle:@"完成"];
        completeBtn.frame = CGRectMake(self.bounds.size.width - (btnWidth + 10), 0, btnWidth, btnWidth);
        completeBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [completeBtn setTitleColor:cc_ColorRGBA(0, 204, 51, 1) forState:UIControlStateNormal];
        [completeBtn setTitleColor:cc_ColorRGBA(0, 204, 51, 1) forState:UIControlStateHighlighted];
//        completeBtn.titleLabel.font = Font19And17(systemFontOfSize, 15);
        [completeBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            // 通知代理
            if ([self.photoToolbarDelegate respondsToSelector:@selector(didComplete:)])
                [self.photoToolbarDelegate didComplete:self];
        }];
        [self addSubview:completeBtn];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [MBProgressHUD showSuccess:@"保存失败" toView:nil];
    } else {
        CCPhoto *photo = _photos[_currentPhotoIndex];
        photo.save = YES;
        saveImageBtn.enabled = NO;
        [MBProgressHUD showSuccess:@"成功保存到相册" toView:nil];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex{
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", (int)_currentPhotoIndex + 1, (int)_photos.count];
    
    CCPhoto *photo = _photos[_currentPhotoIndex];
    // 按钮
    saveImageBtn.enabled = photo.image != nil && !photo.save;
}

-(void)updataSelectd{
    int SelectdCount = 0;
    for (CCPhoto *photo in _photos) {
        if (photo.selectd)
            SelectdCount++;
    }
    
    SendCountLabel.hidden = YES;
    if(SelectdCount > 0)
         SendCountLabel.hidden = NO;
    SendCountLabel.text = [NSString stringWithFormat:@"%d",SelectdCount];
}
@end
