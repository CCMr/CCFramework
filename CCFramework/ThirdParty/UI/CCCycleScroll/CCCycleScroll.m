//
//  CCCycleScroll.m
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

#import "CCCycleScroll.h"
#import "Config.h"
#import "UIView+BUIView.h"
#import "UIImageView+Additional.h"

@interface CCCycleScroll()

@property (nonatomic, strong) NSArray *containerArray;
@property (nonatomic, strong) UIScrollView *SrcollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation CCCycleScroll

static CGFloat SWITCH_FOCUS_PICTURE_INTERVAL = 5.0; //switch interval time

-(id)init{
    if (self = [super init]) {
        [self setupViews];
    }
    return self;
}

-(id)initWithFrame: (CGRect)frame
        ImageItems: (NSArray *)items
       Placeholder: (UIImage *)placeholder
        IsAutoPlay: (BOOL)isAuto
      IsLocalImage: (BOOL)isLocalImage
{
    if (self = [super initWithFrame:frame]) {
        _IsAutoPlay = isAuto;
        _containerArray = items;
        _IsLocalImage = isLocalImage;
        _placeholder = placeholder;
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    
    _SrcollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _SrcollView.scrollsToTop = NO;
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 26, winsize.width, 10)];
    _pageControl.userInteractionEnabled = NO;
    
    [self addSubview:_SrcollView];
    [self addSubview:_pageControl];
    
    _SrcollView.showsHorizontalScrollIndicator = NO;
    _SrcollView.pagingEnabled = YES;
    _SrcollView.delegate = self;
    
    _pageControl.numberOfPages = _containerArray.count > 1 ? _containerArray.count - 2 : _containerArray.count;
    _pageControl.currentPage = 0;
    
    [self initData:YES];
}

-(void)initData:(BOOL)bol{
    float space = 0;
    CGSize size = CGSizeMake(winsize.width, 0);
    
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_SrcollView addGestureRecognizer:tapGestureRecognize];
    _SrcollView.contentSize = CGSizeMake(_SrcollView.frame.size.width * _containerArray.count, _SrcollView.frame.size.height);
    
    for (int i = 0; i < _containerArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _SrcollView.frame.size.width+space, space, _SrcollView.frame.size.width-space*2, _SrcollView.frame.size.height-2*space-size.height)];
        if (_IsLocalImage) {
            imageView.image = [UIImage imageNamed:_containerArray[i]];
        }else{
            if (_placeholder)
                [imageView setImageWithURL:_containerArray[i] placeholder:_placeholder];
        }
        imageView.tag =  1000 + i;
        [_SrcollView addSubview:imageView];
        if (bol)
            imageView.image = [UIImage imageNamed:_containerArray[i]];
    }
    
    if (_containerArray.count > 1) {
        [_SrcollView setContentOffset:CGPointMake(winsize.width, 0) animated:NO];
        if (_IsAutoPlay)
            [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
    }
}

-(void)setUrlImages:(NSArray *)urlImages{
    _containerArray = urlImages;
    [_SrcollView removeAllSubviews];
    [self initData:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float targetX = scrollView.contentOffset.x;
    if (_containerArray.count >= 3){
        if (targetX >= winsize.width * (_containerArray.count - 1)) {
            targetX = winsize.width;
            [_SrcollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }else if(targetX <= 0){
            targetX = winsize.width *(_containerArray.count - 2);
            [_SrcollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
    }
    
    int page = (_SrcollView.contentOffset.x + winsize.width / 2.0) / winsize.width;
    
    if (_containerArray.count > 1)
    {
        page --;
        if (page >= _pageControl.numberOfPages)
            page = 0;
        else if(page <0)
            page = (int)_pageControl.numberOfPages -1;
    }
    _pageControl.currentPage = page;
}

-(void)switchFocusImageItems{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    
    CGFloat targetX = _SrcollView.contentOffset.x + _SrcollView.frame.size.width;
    targetX = (int)(targetX / winsize.width) * winsize.width;
    [self moveToTargetPosition:targetX];
    
    if (_containerArray.count > 1 && _IsAutoPlay)
        [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:SWITCH_FOCUS_PICTURE_INTERVAL];
}

- (void)moveToTargetPosition:(CGFloat)targetX{
    BOOL animated = YES;
    [_SrcollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    NSInteger page = (_SrcollView.contentOffset.x / _SrcollView.frame.size.width);
    if (page > -1 && page < _containerArray.count) {
        if ([self.delegate respondsToSelector:@selector(didScrollSelect:)])
            [self.delegate didScrollSelect:page];
        
        if ([self.delegate respondsToSelector:@selector(didScrollSelect:SelectView:)])
            [self.delegate didScrollSelect:page SelectView:[gestureRecognizer.view viewWithTag:1000 + page - 1]];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate){
        CGFloat targetX = _SrcollView.contentOffset.x + _SrcollView.frame.size.width;
        targetX = (int)(targetX / winsize.width) * winsize.width;
        [self moveToTargetPosition:targetX];
    }
}

- (void)scrollToIndex:(int)aIndex{
    if (_containerArray.count > 1){
        if (aIndex >= (_containerArray.count - 2))
            aIndex = (int)_containerArray.count - 3;
        [self moveToTargetPosition:winsize.width * (aIndex + 1)];
    }else
        [self moveToTargetPosition:0];
    [self scrollViewDidScroll:_SrcollView];
    
}

@end
