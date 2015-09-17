//
//  CCCycleScroll.h
//  CCCycleScroll
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

@protocol CCCycleScrollDelegate <NSObject>
@optional
-(void)didScrollSelect:(NSInteger)index;
-(void)didScrollSelect:(NSInteger)index SelectView:(UIView *)selectView;
@end

@interface CCCycleScroll : UIView<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, assign) id<CCCycleScrollDelegate> delegate;

@property (nonatomic, assign) NSArray *urlImages;

@property (nonatomic, assign) BOOL IsAutoPlay;

@property (nonatomic, assign) UIImage *placeholder;

-(id)initWithFrame:(CGRect)frame ImageItems:(NSArray *)items IsAutoPlay:(BOOL)isAuto;

- (void)scrollToIndex:(int)aIndex;

@end
