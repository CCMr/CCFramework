//
//  LoadLogoView.m
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

#import "CCLoadLogoView.h"

@class CCLoadView;

@interface CCLoadLogoView ()

@property (nonatomic, strong) CCLoadView *LoadViews;
@property (nonatomic) BOOL isAnimating;

@end

@implementation CCLoadLogoView

@synthesize mode;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_LoadViews.layer removeAllAnimations];
}

-(instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(instancetype)initWithLogo:(NSString *)Logo Frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _LoadViews = [[CCLoadView alloc] initWithFrame:frame];
        _LoadViews.mode = CCLoadLogoViewModeIndeterminate;
        [_LoadViews startAnimation];
        [self addSubview:_LoadViews];
        UIImageView *LogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:Logo]];
        LogoImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:LogoImageView];
        
        //按home键回来 继续转动
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

-(instancetype)initWithLoading:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _LoadViews = [[CCLoadView alloc] initWithFrame:frame];
        _LoadViews.mode = CCLoadLogoViewModeIndeterminate;
        _LoadViews.lineColor = [UIColor lightGrayColor];
        [self addSubview:_LoadViews];
        
        
        //按home键回来 继续转动
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)nc
{
    if (!_isAnimating) {
        [self startAnimation];
    }
    else {
        [self stopAnimation];
    }
}

-(void)startAnimation{
    _isAnimating = YES;
    [_LoadViews startAnimation];
}

-(void)stopAnimation{
    _isAnimating = NO;
    [_LoadViews stopAnimation];
}

@end


#define ANGLE(Angle) 2 * M_PI / 360 * Angle

@interface CCLoadView ()

//0.0 - 1.0
@property (nonatomic, assign) CGFloat anglePer;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation CCLoadView
static int stage = 0;
@synthesize mode;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAnglePer:(CGFloat)anglePer{
    _anglePer = anglePer;
    [self setNeedsDisplay];
}

- (void)startAnimation{
    if (self.isAnimating) {
        [self stopAnimation];
        [self.layer removeAllAnimations];
    }
    _isAnimating = YES;
    self.anglePer = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(drawPathAnimation:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation{
    _isAnimating = NO;
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self stopRotateAnimation];
}

- (void)drawPathAnimation:(NSTimer *)timer{
    if (mode == CCLoadLogoViewModeFloatingPoint) {
        stage++;
    }
    self.anglePer += 0.03f;
    
    if (self.anglePer >= 1) {
        self.anglePer = 1;
        [timer invalidate];
        self.timer = nil;
        [self startRotateAnimation];
    }
}

- (void)startRotateAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2*M_PI);
    animation.duration = 1;
    animation.repeatCount = INT_MAX;
    
    [self.layer addAnimation:animation forKey:@"keyFrameAnimation"];
}

- (void)stopRotateAnimation{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.anglePer = 0;
        [self.layer removeAllAnimations];
        self.alpha = 1;
    }];
}

- (void)drawRect:(CGRect)rect{
    if (self.anglePer <= 0)
        _anglePer = 0;
    
    CGFloat lineWidth = 2.f;
    UIColor *lineColor = [UIColor whiteColor];
    if (self.lineWidth)
        lineWidth = self.lineWidth;
    if (self.lineColor)
        lineColor = self.lineColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (mode == CCLoadLogoViewModeIndeterminate) {
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        CGContextAddArc(context,CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds),CGRectGetWidth(self.bounds) / 2 - lineWidth,ANGLE(120), ANGLE(120) + ANGLE(330) * self.anglePer,0);
        CGContextStrokePath(context);
    }else if (mode == CCLoadLogoViewModeFloatingPoint){
        CGContextAddArc(context,CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds),CGRectGetWidth(self.bounds) / 2 - 5,ANGLE(120), ANGLE(120) + ANGLE(330) * self.anglePer,0);
        CGContextDrawPath(context, kCGPathFill);

    }
}
@end