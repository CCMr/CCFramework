//
//  CCStarRatingView.m
//  CCFramework
//
// Copyright (c) 2016 CC ( http://www.ccskill.com )
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

#import "CCStarRatingView.h"
#import "config.h"

#define kDuration 0.2

#define kCCDefaultStarRatingNumber 5

#define kCCDefaultstarBackgroundImageName @"icon_star_gray"
#define kCCDefaultstarForegroundImageName @"icon_star_yellow"

typedef void (^didStarRatingView)(CCStarRatingView *starRationView, float scroe);

@interface CCStarRatingView ()

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 背景星星
 */
@property(nonatomic, strong) UIView *starBackgroundView;

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 评分星星
 */
@property(nonatomic, strong) UIView *starForegroundView;

@property(nonatomic, strong) didStarRatingView starRatinBlock;

@end

@implementation CCStarRatingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialization];
}

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

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 初始化
 *
 *  @param frame            位置
 *  @param starRatingNumber 评分星数
 */
- (instancetype)initWithFrame:(CGRect)frame
             StarRatingNumber:(NSInteger)starRatingNumber
{
    if (self = [super initWithFrame:frame]) {
        _StarRatingNumber = starRatingNumber;
        [self initialization];
    }
    return self;
}

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 设置评分
 *
 *  @param score     评分
 *  @param animation 动画
 */
- (void)setScore:(float)score
       Animation:(bool)animation
{
    [self setScore:score
         Animation:YES
        Completion:nil];
}

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 设置评分
 *
 *  @param score      评分
 *  @param animate    动画
 *  @param completion 完成回调
 */
- (void)setScore:(float)score
       Animation:(bool)animation
      Completion:(void (^)(bool finished))completion
{
    if (score < 0)
        score = 0;
    
    if (score > self.maxNumber)
        score = self.maxNumber;
    
    CGPoint point = CGPointMake((score / self.maxNumber) * self.frame.size.width, 0);
    if (animation) {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:kDuration animations:^{
            [weakSelf changeStarForegroundViewWithPoint:point];
        } completion:^(BOOL finished) {
            if (completion)
                completion(finished);
        }];
    } else {
        [self changeStarForegroundViewWithPoint:point];
    }
}

- (void)changeStarForegroundViewWithPoint:(CGPoint)point
{
    CGPoint p = point;
    if (p.x < 0)
        p.x = 0;
    
    if (p.x > self.frame.size.width)
        p.x = self.frame.size.width;
    
    NSString *str = [NSString stringWithFormat:@"%0.2f", p.x / self.frame.size.width];
    float score = [str floatValue];
    p.x = score * self.frame.size.width;
    self.starForegroundView.frame = CGRectMake(0, 0, p.x, self.frame.size.height);
    
    if ([self.delegate respondsToSelector:@selector(didStarRatingView:Score:)]) {
        [self.delegate didStarRatingView:self Score:score * self.maxNumber];
    } else if (self.starRatinBlock) {
        self.starRatinBlock(self, score * self.maxNumber);
    }
}

- (void)didStarRatingView:(void (^)(CCStarRatingView *, float))block
{
    _starRatinBlock = block;
}

#pragma mark - Touche Event
- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (CGRectContainsPoint(rect, point)) {
        [self changeStarForegroundViewWithPoint:point];
    }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:kDuration animations:^{
        [weakSelf changeStarForegroundViewWithPoint:point];
    }];
}


#pragma mark :. 属性设置
/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 初始化参数
 */
- (void)initialization
{
    if (!self.StarRatingNumber)
        self.StarRatingNumber = kCCDefaultStarRatingNumber;
    
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeRedraw;
    
    [self addSubview:self.starBackgroundView];
    [self addSubview:self.starForegroundView];
}

- (UIView *)starBackgroundView
{
    if (!_starBackgroundView) {
        if (self.starBackgroundImageName)
            _starBackgroundView = [self buidlStarViewWithImageName:self.starBackgroundImageName];
        else
            _starBackgroundView = [self buidlStarViewWithImage:CCResourceImage(kCCDefaultstarBackgroundImageName)];
    }
    return _starBackgroundView;
}

- (void)setStarBackgroundImageName:(NSString *)starBackgroundImageName
{
    _starBackgroundImageName = starBackgroundImageName;
    [self.starBackgroundView removeFromSuperview];
    [self addSubview:self.starBackgroundView];
}

- (UIView *)starForegroundView
{
    if (!_starForegroundView) {
        if (self.starForegroundImageName)
            _starForegroundView = [self buidlStarViewWithImageName:self.starForegroundImageName];
        else
            _starForegroundView = [self buidlStarViewWithImage:CCResourceImage(kCCDefaultstarForegroundImageName)];
    }
    return _starForegroundView;
}

- (void)setStarForegroundImageName:(NSString *)starForegroundImageName
{
    _starForegroundImageName = starForegroundImageName;
    [self.starForegroundView removeFromSuperview];
    [self addSubview:self.starForegroundView];
}

/**
 *  @author CC, 2016-01-11
 *  
 *  @brief 星星视图
 *
 *  @param imageName 图片名称
 */
- (UIView *)buidlStarViewWithImageName:(NSString *)imageName
{
    return [self buidlStarViewWithImage:[UIImage imageNamed:imageName]];
}

- (UIView *)buidlStarViewWithImage:(UIImage *)imageName
{
    CGRect frame = self.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.clipsToBounds = YES;
    for (NSInteger i = 0; i < self.StarRatingNumber; i++) {
        UIImageView *starRatingImageView = [[UIImageView alloc] initWithImage:imageName];
        starRatingImageView.frame = CGRectMake(i * frame.size.width / self.StarRatingNumber, 0, frame.size.width / self.StarRatingNumber, frame.size.height);
        [view addSubview:starRatingImageView];
    }
    return view;
}


@end
