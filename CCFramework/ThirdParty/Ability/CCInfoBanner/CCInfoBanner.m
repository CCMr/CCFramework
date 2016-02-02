//
//  CCInfoBanner.m
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

#import "CCInfoBanner.h"
#import "UIView+BUIView.h"
#import "NSString+BNSString.h"
#import "CCHierarchySearcher.h"
#import "config.h"
#import "UIImage+MultiFormat.h"

static const NSTimeInterval kAnimationDuration = 0.3;

typedef NS_ENUM(NSInteger, CCInfoBannerShowType) {
    CCInfoBannerShowTypeMessage,
    CCInfoBannerShowTypeIndicatorView,
};

@interface CCInfoBanner ()

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  图标
 */
@property(nonatomic, strong) UIImageView *iconImageView;

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  加载视图
 */
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  标题
 */
@property(nonatomic, strong) UILabel *titleLabel;

/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  详细信息
 */
@property(nonatomic, strong) UILabel *detailsLabel;

@property(nonatomic, strong) UIView *targetView;
@property(nonatomic, strong) UIView *viewAboveBanner;
@property(nonatomic) CGFloat additionalTopSpacing;

@property(nonatomic, assign) CCInfoBannerShowType showType;

@end

@implementation CCInfoBanner

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


#pragma mark :. 初始化
/**
 *  @author CC, 2016-12-29
 *  
 *  @brief  初始化控件
 */
- (void)initialization
{
    self.tag = 204517;
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self addSubview:_iconImageView];
    }
    
    CGFloat x = _iconImageView.x + _iconImageView.width + 10;
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.bounds.size.width - x, 20)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];
    }
    
    if (!_detailsLabel) {
        _detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, _titleLabel.y + _titleLabel.height, self.bounds.size.width - x, 20)];
        _detailsLabel.font = [UIFont systemFontOfSize:14];
        _detailsLabel.textAlignment = NSTextAlignmentCenter;
        _detailsLabel.backgroundColor = [UIColor clearColor];
        _detailsLabel.textColor = [UIColor whiteColor];
        [self addSubview:_detailsLabel];
    }
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  加载控件
 */
- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.hidesWhenStopped = YES;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w;
    CGFloat tw = [self.titleLabel.text calculateTextWidthHeight:self.bounds.size.width Font:self.titleLabel.font].width;
    CGFloat cw = [self.detailsLabel.text calculateTextWidthHeight:self.bounds.size.width Font:self.detailsLabel.font].width;
    
    w = tw;
    if (cw > w)
        w = cw;
    
    CGFloat x = (self.bounds.size.width - w) / 2;
    CGRect frame;
    if (self.iconImageView.image) {
        frame = self.iconImageView.frame;
        x = (self.bounds.size.width - (frame.size.width + w)) / 2;
        x = x < 0 ?: x;
        frame.origin.x = x - 15;
        frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
        self.iconImageView.frame = frame;
        
        x += frame.size.width;
    } else if (self.indicatorView) {
        x = (self.bounds.size.width - (self.indicatorView.width + w)) / 2;
        x = x < 0 ?: x;
        CGFloat indicatorCenterY = self.frame.size.height * 0.5;
        self.indicatorView.center = CGPointMake(x - 15, indicatorCenterY);
        
        x += self.indicatorView.width;
    }
    
    frame = self.titleLabel.frame;
    frame.origin.x = x;
    frame.size.width = tw;
    frame.size.height = self.bounds.size.height;
    self.titleLabel.frame = frame;
    
    if (self.detailsLabel.text.length) {
        frame.size.height = frame.size.height / 2;
        self.titleLabel.frame = frame;
        
        frame = self.detailsLabel.frame;
        frame.origin.x = x;
        frame.size.width = cw;
        frame.size.height = self.bounds.size.height / 2;
        
        self.detailsLabel.frame = frame;
    }
    
    cc_View_SingleFillet(self, UIRectCornerBottomLeft | UIRectCornerBottomRight, 5);
}

#pragma mark :. 显示函数
/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  初始化设置
 */
+ (instancetype)initializationShow
{
    CCInfoBanner *banner = [[[self class] alloc] init];
    banner.showType = CCInfoBannerShowTypeMessage;
    return banner;
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示
 *
 *  @param text 标题
 */
+ (void)showWithText:(NSString *)text
{
    CCInfoBanner *banner = [self initializationShow];
    banner.titleLabel.text = text;
    [banner show];
    [banner hide:YES afterDelay:3];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示
 *
 *  @param title       标题
 *  @param detailsText 详细内容
 */
+ (void)showWithTitle:(NSString *)title
          DetailsText:(NSString *)detailsText
{
    [self showWithIcon:nil
                 Title:title
           DetailsText:detailsText];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示图标
 *
 *  @param icon  图标
 *  @param title 标题
 */
+ (void)showWithIcon:(NSString *)icon
               Title:(NSString *)title
{
    [self showWithIcon:icon
                 Title:title
           DetailsText:nil];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示图标
 *
 *  @param icon        图标
 *  @param title       标题
 *  @param detailsText 详细内容
 */
+ (void)showWithIcon:(NSString *)icon
               Title:(NSString *)title
         DetailsText:(NSString *)detailsText
{
    CCInfoBanner *banner = [self initializationShow];
    if (icon) {
        banner.iconImageView.image = [UIImage imageNamed:icon];
        [banner.indicatorView stopAnimating];
    }
    
    banner.titleLabel.text = title;
    banner.detailsLabel.text = detailsText;
    [banner show];
    [banner hide:YES afterDelay:3];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示GIF图标
 *
 *  @param icon  图标
 *  @param title 标题
 */
+ (void)showWithIconGIF:(NSString *)icon
                  Title:(NSString *)title
{
    [self showWithIconGIF:icon
                    Title:title
              DetailsText:nil];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示GIF图标
 *
 *  @param icon        图标
 *  @param title       标题
 *  @param detailsText 详细内容
 */
+ (void)showWithIconGIF:(NSString *)icon
                  Title:(NSString *)title
            DetailsText:(NSString *)detailsText
{
    CCInfoBanner *banner = [self initializationShow];
    if (icon) {
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:icon ofType:@"gif"]];
        banner.iconImageView.image = [UIImage sd_imageWithData:data];
    }
    banner.titleLabel.text = title;
    banner.detailsLabel.text = detailsText;
    [banner show];
    [banner hide:YES afterDelay:3];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示加载
 *
 *  @param title           标题
 *  @param executingBlock  执行函数
 */
+ (void)showWithExecutingBlock:(NSString *)title
           whileExecutingBlock:(dispatch_block_t)executingBlock
{
    [self showWithExecutingBlock:title
             whileExecutingBlock:executingBlock
            whileCompletionBlock:nil];
}


/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示加载
 *
 *  @param title           标题
 *  @param executingBlock  执行函数
 *  @param completionBlock 完成函数
 */
+ (void)showWithExecutingBlock:(NSString *)title
           whileExecutingBlock:(dispatch_block_t)executingBlock
          whileCompletionBlock:(dispatch_block_t)completionBlock
{
    [self showWithExecutingBlock:title
                     DetailsText:nil
             whileExecutingBlock:executingBlock
            whileCompletionBlock:completionBlock];
}

/**
 *  @author CC, 2016-12-30
 *  
 *  @brief  提示加载
 *
 *  @param title           标题
 *  @param detailsText     详细
 *  @param executingBlock  执行函数
 *  @param completionBlock 完成回调函数
 */
+ (void)showWithExecutingBlock:(NSString *)title
                   DetailsText:(NSString *)detailsText
           whileExecutingBlock:(dispatch_block_t)executingBlock
          whileCompletionBlock:(dispatch_block_t)completionBlock
{
    CCInfoBanner *banner = [self initializationShow];
    banner.titleLabel.text = title;
    banner.detailsLabel.text = detailsText;
    
    [banner showAnimated:YES
     whileExecutingBlock:executingBlock
         completionBlock:completionBlock];
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  创建指示器视图
 */
+ (CCInfoBanner *)showWithIndicatorView
{
    CCInfoBanner *banner = [self initializationShow];
    [banner.indicatorView startAnimating];
    banner.showType = CCInfoBannerShowTypeIndicatorView;
    return banner;
}

#pragma mark :. 设置属性
/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  设置标题
 *
 *  @param title 标题
 */
- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    if (self.showType == CCInfoBannerShowTypeIndicatorView) {
        self.iconImageView.hidden = YES;
        self.indicatorView.hidden = NO;
    }
}

/**
 *  @author CC, 2016-01-05
 *  
 *  @brief  设置图标与标题
 *
 *  @param icon  图标
 *  @param title 标题
 */
- (void)setIconWithTile:(NSString *)icon
                  Title:(NSString *)title
{
    self.iconImageView.image = [UIImage imageNamed:icon];
    [self.indicatorView stopAnimating];
    self.iconImageView.hidden = NO;
    self.iconImageView.center = self.indicatorView.center;
    
    self.indicatorView.hidden = YES;
    self.titleLabel.text = title;
}

#pragma mark :. Show & hide
- (void)show
{
    [self show:YES];
}

- (void)show:(BOOL)animated
{
    [self setupViewsAndFrames];
    [[self.targetView viewWithTag:204517] removeFromSuperview];
    
    // In previously indicated, send subview to be below another view.
    // This is used when showing below navigation bar
    if (self.viewAboveBanner)
        [self.targetView insertSubview:self belowSubview:self.viewAboveBanner];
    else
        [self.targetView addSubview:self];
    
    [self setHidden:NO];
    
    self.frame = CGRectMake(10, self.additionalTopSpacing, CGRectGetWidth(self.targetView.frame) - 20, 44);
    [self layoutSubviews];
    if (animated) {
        [self.superview layoutIfNeeded];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            [self.superview layoutIfNeeded];
        }];
    }
}

- (void)setupViewsAndFrames
{
    UINavigationController *navVC = [[[CCHierarchySearcher alloc] init] topmostNavigationController];
    if (navVC && navVC.navigationBar.superview) {
        self.targetView = navVC.navigationBar.superview;
        self.viewAboveBanner = navVC.navigationBar;
        self.additionalTopSpacing = CGRectGetMaxY(self.viewAboveBanner.frame);
    } else {
        // If there isn't a navigation controller with a bar, show in window instead.
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        // Forget the frame convertions, smallest is the height, no doubt
        CGFloat statusBarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);
        
        self.additionalTopSpacing = statusBarHeight;
        self.targetView = window;
    }
}

- (void)hide
{
    [self hide:YES];
}

- (void)hide:(BOOL)animated
{
    if (animated) {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            weakSelf.frame = CGRectOffset(weakSelf.frame, 0, -weakSelf.frame.size.height);
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

- (void)hide:(BOOL)animated
  afterDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(hideDelayed:)
               withObject:[NSNumber numberWithBool:animated]
               afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated
{
    [self hide:[animated boolValue]];
}

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block
{
    [self showAnimated:animated
   whileExecutingBlock:block
       completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block
     completionBlock:(void (^)())completion
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self showAnimated:animated
   whileExecutingBlock:block
               onQueue:queue
       completionBlock:completion];
}

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block
             onQueue:(dispatch_queue_t)queue
{
    [self showAnimated:animated
   whileExecutingBlock:block
               onQueue:queue
       completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated
 whileExecutingBlock:(dispatch_block_t)block
             onQueue:(dispatch_queue_t)queue
     completionBlock:(void (^)())completion
{
    [self.indicatorView startAnimating];
    dispatch_async(queue, ^(void) {
        block();
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self hide:animated];
            if (completion)
                completion();
        });
    });
    [self show:animated];
}

@end
