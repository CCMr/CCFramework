//
//  CCEmotionCollectionViewCell.m
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

#import "CCEmotionCollectionViewCell.h"

@interface CCEmotionCollectionViewCell ()

/**
 *  显示表情封面的控件
 */
@property (nonatomic, weak) UIImageView *emotionImageView;

/**
 *  配置默认控件和参数
 */
- (void)setup;
@end


@implementation CCEmotionCollectionViewCell

#pragma setter method

- (void)setEmotion:(CCEmotion *)emotion {
    _emotion = emotion;

    // TODO:
    self.emotionImageView.image = emotion.emotionConverPhoto;
}

#pragma mark - Life cycle

- (void)setup {
    if (!_emotionImageView) {
        UIImageView *emotionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCCEmotionImageViewSize, kCCEmotionImageViewSize)];
        emotionImageView.backgroundColor = [UIColor colorWithRed:0.000 green:0.251 blue:0.502 alpha:1.000];
        [self.contentView addSubview:emotionImageView];
        self.emotionImageView = emotionImageView;
    }
}

- (void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.emotion = nil;
}


@end
