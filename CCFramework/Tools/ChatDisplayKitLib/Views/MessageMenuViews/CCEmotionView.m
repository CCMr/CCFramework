//
//  CCEmotionView.m
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


#import "CCEmotionView.h"
#import "CCEmotion.h"
#import "UIButton+BUIButton.h"
#import "UIImageView+WebCache.h"
#import "UIImage+MultiFormat.h"

@implementation CCEmotionView

- (instancetype)initWithFrame:(CGRect)frame
                      Section:(NSInteger)section
                          Row:(NSInteger)row
                   dataSource:(NSArray *)data
{
    if (self = [super initWithFrame:frame]) {
        
        CGRect frames = CGRectMake(0, 0, frame.size.width / row, frame.size.height / section);
        
        
        if (data.count) {
            NSInteger index = data.count / row + (data.count % row == 0 ? 0 : 1);
            if (index != section)
                section = index;
            
            for (NSInteger i = 0; i < section; i++) {
                
                
                NSArray *datas = [data subarrayWithRange:NSMakeRange(i * row, i == section - 1 ? (data.count - i * row) % (row + 1) : row)];
                
                for (int j = 0; j < datas.count; j++) {
                    CCEmotion *emotion = [datas objectAtIndex:j];
                    
                    UIButton *button = [UIButton buttonWith];
                    button.frame = frames;
                    
                    button.carryObjects = emotion;
                    [button addTarget:self action:@selector(didButtonClick:)
                     forControlEvents:UIControlEventTouchUpInside];
                    
                    [self addSubview:button];
                    
                    UIImageView *images = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, frames.size.width - 20, frames.size.height - 10)];
                    images.contentMode = UIViewContentModeScaleAspectFit;
                    [button addSubview:images];
                    
                    NSData *data = [NSData dataWithContentsOfFile:emotion.emotionConverPhoto];
                    images.image = [UIImage sd_imageWithData:data];
                    if ([emotion.emotionConverPhoto rangeOfString:@"http://"].location != NSNotFound)
                        [images sd_setImageWithURLStr:emotion.emotionConverPhoto];
                    else if (!images.image) {
                        if (emotion.emotionConverPhotoUrl)
                            [images sd_setImageWithURLStr:emotion.emotionConverPhotoUrl];
                    }
                    
                    frames.origin.x += frames.size.width;
                }
                
                frames.origin.x = 0;
                frames.origin.y += frames.size.height;
            }
        }
    }
    return self;
}

- (void)didButtonClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didSelected:Emotion:EmotionType:)]) {
        [self.delegate didSelected:self
                           Emotion:sender.carryObjects
                       EmotionType:self.emotionType];
    }
}

@end
