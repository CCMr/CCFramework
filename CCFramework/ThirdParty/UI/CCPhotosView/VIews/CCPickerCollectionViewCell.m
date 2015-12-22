//
//  CCPickerCollectionViewCell.m
//  CC
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

#import "CCPickerCollectionViewCell.h"
#import "UIButton+BUIButton.h"
#import "UIControl+BUIControl.h"
#import "config.h"

@implementation CCPickerCollectionViewCell{
    UIImageView *imageView,*overImageView;
    UIButton *CheckBtn;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.tag = 9999;
        [self addSubview:imageView];
        
        CheckBtn = [UIButton buttonWith];
        CheckBtn.frame = CGRectMake(imageView.frame.size.width - 40, 0, 40, 40);
        [self addSubview:CheckBtn];
        
        overImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 4, 20, 20)];
        [CheckBtn addSubview:overImageView];
    }
    return self;
}

-(void)setData:(CCPhoto *)asset IsOver:(BOOL)isOver CallBlock:(callBackBlock)callBlock{
    
    imageView.image = asset.thumbImage;
    
    overImageView.image  = CCResourceImage( isOver ? @"AssetsYES" : @"AssetsNO");
    
    [CheckBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        callBlock(overImageView);
    }];
}

@end
