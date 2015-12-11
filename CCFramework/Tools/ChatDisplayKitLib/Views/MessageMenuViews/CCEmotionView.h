//
//  CCEmotionView.h
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


#import <UIKit/UIKit.h>

@class CCEmotionView;
@class CCEmotion;

@protocol CCEmotionViewDelegate <NSObject>

@optional

/**
 *  @author CC, 2015-12-11
 *  
 *  @brief  选中表情
 *
 *  @param emotionView 表情视图
 *  @param emotion     表情对象
 *  @param emotionType 表情类型
 */
- (void)didSelected:(CCEmotionView *)emotionView
            Emotion:(CCEmotion *)emotion
        EmotionType:(NSInteger)emotionType;

@end


@interface CCEmotionView : UIView

@property(nonatomic, weak) id<CCEmotionViewDelegate> delegate;

/**
 *  @author CC, 2015-12-11
 *  
 *  @brief  表情类型
 */
@property(nonatomic, assign) NSInteger emotionType;

- (instancetype)initWithFrame:(CGRect)frame
                      Section:(NSInteger)section
                          Row:(NSInteger)row
                   dataSource:(NSArray *)data;

@end
