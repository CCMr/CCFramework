//
//  CCRadarView.m
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

#import "CCRadarView.h"
#import "CCRadarIndicatorView.h"
#import "CCRadarPointView.h"

#import <QuartzCore/QuartzCore.h>
#define RADAR_DEFAULT_SECTIONS_NUM 3
#define RADAR_DEFAULT_RADIUS 150.f  //默认的半径大小  150
#define RADAR_DEFAULT_IMGRADIUS 20.f  //默认的头像半径大小  150
#define RADAR_ROTATE_SPEED 80.0f
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

@interface CCRadarView()<CCRadarPointViewDelegate>

@end

@implementation CCRadarView

#pragma mark - life cycle

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (!self.indicatorView)
    {
        CCRadarIndicatorView *indicatorView = [[CCRadarIndicatorView alloc] init];
        [self addSubview:indicatorView];
        _indicatorView = indicatorView;
    }

    if (!self.textLabel)
    {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.center.y + self.radius, self.bounds.size.width, 30)];
        [self addSubview:textLabel];
        _textLabel = textLabel;
    }

    if (!self.dropOutButton)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"退出" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.frame = CGRectMake(10, 20, 60, 30);
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = .5;
        [self addSubview:button];
        self.dropOutButton = button;
    }

    if (!self.pointsView)
    {
        UIView *pointsView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:pointsView];
        _pointsView = pointsView;
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();

    /*背景图片*/
    if (self.backgroundImage){
        UIImage *image = self.backgroundImage;
        [image drawInRect:self.bounds];//在坐标中画出图片
    }

    //默认的圈数
    NSUInteger sectionsNum = RADAR_DEFAULT_SECTIONS_NUM;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInRadarView:)])
        sectionsNum = [self.dataSource numberOfSectionsInRadarView:self];


    CGFloat radius = RADAR_DEFAULT_RADIUS;
    if (self.radius)
        radius = self.radius;

    CGFloat imgradius = RADAR_DEFAULT_IMGRADIUS;
    if (self.imageRadius)
        imgradius = self.imageRadius;

    //画很多的圆圈
    CGFloat sectionRadius = (radius-imgradius)/sectionsNum+imgradius;
    for (int i = 0; i < sectionsNum ; i++) {
        /*画圆*/
        //边框圆
        CGContextSetRGBStrokeColor(context, 1, 1, 1, (1-(float)i/(sectionsNum + 1))*0.5);//画笔线的颜色(透明度渐变)
        CGContextSetLineWidth(context, 1.0);//线的宽度
        //void CGContextAddArc(CGContextRef c,CGFloat x, CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle, int clockwise)1弧度＝180°/π （≈57.3°） 度＝弧度×180°/π 360°＝360×π/180 ＝2π 弧度
        // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
        CGContextAddArc(context, self.center.x, self.center.y, sectionRadius, 0, 2*M_PI, 0); //添加一个圆
        CGContextDrawPath(context, kCGPathStroke); //绘制路径

        sectionRadius += (radius-imgradius)/sectionsNum;
    }

    //那个线条 和 后面的扇形弧度，，其实frame是整个屏幕，所以旋转是绕着用户头像
    if (self.indicatorView) {
        self.indicatorView.frame = self.bounds;
        self.indicatorView.backgroundColor = [UIColor clearColor];
        self.indicatorView.radius = self.radius;
    }

    if (self.textLabel)
    {
        self.textLabel.frame = CGRectMake(0, self.center.y + ([UIScreen mainScreen].bounds.size.height)/3.3, rect.size.width, 30);
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont systemFontOfSize:13];
        if (self.labelText)
            self.textLabel.text = self.labelText;

        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self bringSubviewToFront:self.textLabel];
    }

    if (self.dropOutButton)
    {
        self.dropOutButton.frame = CGRectMake(20, 30, 45, 25);
        self.dropOutButton.titleLabel.font = [UIFont systemFontOfSize:13];
        self.dropOutButton.layer.cornerRadius = 5;
        self.dropOutButton.layer.masksToBounds = YES;
        self.dropOutButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.dropOutButton.layer.borderWidth = 1;
        [self.dropOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.dropOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.dropOutButton addTarget:self action:@selector(dropOut:) forControlEvents:UIControlEventTouchUpInside];
        [self bringSubviewToFront:self.dropOutButton];
    }

    if(self.PersonImage && self.imageRadius)
    {
        UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(self.center.x - self.imageRadius, self.center.y - self.imageRadius, self.imageRadius * 2, self.imageRadius * 2)];
        avatarView.layer.cornerRadius = self.imageRadius;
        avatarView.layer.masksToBounds = YES;

        [avatarView setImage:self.PersonImage];
        [self addSubview:avatarView];
        [self bringSubviewToFront:avatarView];
    }
}

- (void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    if (self.textLabel)
        self.textLabel.text = labelText;
}

- (void)dropOut:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didDropOut)])
        [self.delegate didDropOut];
}

#pragma mark - Actions
/**
 *  @author CC, 15-09-30
 *
 *  @brief  启动扫描
 */
- (void)startScanning
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 360.f/RADAR_ROTATE_SPEED;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INT_MAX;
    [_indicatorView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

/**
 *  @author CC, 15-09-30
 *
 *  @brief  停止扫描
 */
- (void)stopScanning
{
    [_indicatorView.layer removeAnimationForKey:@"rotationAnimation"];
}

/**
 *  @author CC, 15-09-30
 *
 *  @brief  刷新数据源
 */
- (void)reloadData
{
    for (UIView *subview in self.pointsView.subviews)
        [subview removeFromSuperview];

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPointsInRadarView:)]) {
        NSUInteger pointsNum = [self.dataSource numberOfPointsInRadarView:self];

        //添加每一个点数
        for (int index = 0; index < pointsNum; index++) {
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(radarView:viewForIndex:)]) {
                //CGPoint point = [self.dataSource radarView:self positionForIndex:index];
                CCRadarPointView *pointView = [self.dataSource radarView:self viewForIndex:index];
                pointView.frame = CGRectMake(0, 0, 50, 50);
                pointView.delegate = self;
                pointView.radius = self.radius;
                pointView.imageRadius = self.imageRadius;

                int posDirection = pointView.pointAngle;     //方向(角度)
                int posDistance = pointView.pointRadius;    //距离(半径)

                pointView.tag = index;
                pointView.layer.cornerRadius = pointView.frame.size.width / 2;
                pointView.layer.masksToBounds = YES;

                //蛋疼的求坐标点
                pointView.center = CGPointMake(self.center.x + posDistance * cos(posDirection * M_PI / 180), self.center.y + posDistance * sin(posDirection * M_PI / 180));
                //pointView.delegate = self;

                //动画
                pointView.alpha = 0.0;
                CGAffineTransform fromTransform = CGAffineTransformScale(pointView.transform, 0.1, 0.1);
                [pointView setTransform:fromTransform];

                CGAffineTransform toTransform = CGAffineTransformConcat(pointView.transform,  CGAffineTransformInvert(pointView.transform));

                double delayInSeconds = 2 * index;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [UIView beginAnimations:nil context:NULL];
                    [UIView setAnimationDuration:1.5];
                    pointView.alpha = 1.0;
                    [pointView setTransform:toTransform];
                    [UIView commitAnimations];
                });

                [self.pointsView addSubview:pointView];
            }
        }
    }
}

/**
 *  @author CC, 15-09-30
 *
 *  @brief  选中回调
 *
 *  @param radarPointView <#radarPointView description#>
 */
-(void)didSeletcdRadarPointView:(CCRadarPointView *)radarPointView
{
    if ([self.delegate respondsToSelector:@selector(radarView:didSelectItemAtIndex:)])
        [self.delegate radarView:self didSelectItemAtIndex:radarPointView.tag];
}

@end
