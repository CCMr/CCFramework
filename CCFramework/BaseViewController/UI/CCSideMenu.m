//
//  CCSideMenu.h
// CCSideMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
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

#import "CCSideMenu.h"
#import "AccelerationAnimation.h"
#import "Evaluate.h"
#import "UIWindow+BUIWindow.h"
#import "Config.h"

const int INTERSTITIAL_STEPS = 99;

@interface CCSideMenu ()

@property (assign, readonly, nonatomic) BOOL appIsHidingStatusBar;
@property (assign, readonly, nonatomic) BOOL isInSubMenu;

@property (assign, readwrite, nonatomic) NSInteger initialX;
@property (assign, readwrite, nonatomic) CGSize originalSize;
@property (strong, readonly, nonatomic) CCBackgroundView *backgroundView;
@property (strong, readonly, nonatomic) UIImageView *screenshotView;

// Array containing menu (which are array of items)
@property (strong, readwrite, nonatomic) NSMutableArray *menuStack;
@property (strong, readwrite, nonatomic) CCSideMenuItem *backMenu;

@end

@implementation CCSideMenu

@synthesize isSide;

- (id)init
{
    self = [super init];
    if (!self)
        return nil;

    self.verticalOffset = 100;
    self.horizontalOffset = 50;
    self.itemHeight = 40;
    self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    self.textColor = [UIColor whiteColor];
    self.highlightedTextColor = [UIColor lightGrayColor];
    self.hideStatusBarArea = YES;
    self.hideStatusBarArea = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7;

    self.menuStack = [NSMutableArray array];

    return self;
}

- (id)initWithItems:(NSDictionary *)items
{
    self = [self init];
    if (!self)
        return nil;

    _items = items;
    [_menuStack addObject:items];
    _backMenu = [[CCSideMenuItem alloc] initWithTitle:@"<" action:nil];

    return self;
}

- (void) showItems:(NSDictionary *)items
{
    // Animate to deappear
    __typeof (&*self) __weak weakSelf = self;
    weakSelf.containerView.transform = CGAffineTransformScale(_containerView.transform, 0.9, 0.9);
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.containerView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.containerView.alpha = 0;
    }];

    // Set items and reload
    _items = items;
    if ([self.containerView isKindOfClass:[UITableView class]])
        [((UITableView *)self.containerView) reloadData];

    // Animate to reappear once reloaded
    weakSelf.containerView.transform = CGAffineTransformScale(_containerView.transform, 1, 1);
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.containerView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.containerView.alpha = 1;
    }];

}

- (void)show
{
    if (_isShowing)
        return;

    _isShowing = YES;

    // keep track of whether or not it was already hidden
    _appIsHidingStatusBar = [[UIApplication sharedApplication] isStatusBarHidden];

    //    if(!_appIsHidingStatusBar)
    //        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    [self performSelector:@selector(showAfterDelay) withObject:nil afterDelay:0.1];
}

- (void)hide
{
    if (_isShowing)
        [self restoreFromRect:_screenshotView.frame];

}

- (void)setRootViewController:(UIViewController *)viewController
{
    if (_isShowing)
        [self hide];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = viewController;
    _screenshotView.image = [window re_snapshotWithStatusBar:!self.hideStatusBarArea];
    [window bringSubviewToFront:_backgroundView];
    [window bringSubviewToFront:_containerView];
    [window bringSubviewToFront:_screenshotView];
}

- (void)addAnimation:(NSString *)path view:(UIView *)view startValue:(double)startValue endValue:(double)endValue
{
    AccelerationAnimation *animation = [AccelerationAnimation animationWithKeyPath:path
                                                                        startValue:startValue
                                                                          endValue:endValue
                                                                  evaluationObject:[[ExponentialDecayEvaluator alloc] initWithCoefficient:6.0]
                                                                 interstitialSteps:INTERSTITIAL_STEPS];
    animation.removedOnCompletion = NO;
    [view.layer addAnimation:animation forKey:path];
}

//- (void)animate

- (void)showAfterDelay
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    // Take a snapshot
    //
    _screenshotView = [[UIImageView alloc] initWithFrame:CGRectNull];
    _screenshotView.image = [window re_snapshotWithStatusBar:!self.hideStatusBarArea];
    _screenshotView.frame = CGRectMake(0, 0, _screenshotView.image.size.width, _screenshotView.image.size.height);
    _screenshotView.userInteractionEnabled = YES;
    _screenshotView.layer.anchorPoint = CGPointMake(0, 0);

    _originalSize = _screenshotView.frame.size;

    // Add views
    //
    _backgroundView = [[CCBackgroundView alloc] initWithFrame:window.bounds];
    _backgroundView.backgroundImage = _backgroundImage;
    [window addSubview:_backgroundView];

    if (!self.containerView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, window.frame.size.width - 120, window.frame.size.height - 20)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.delegate = self;
        tableView.scrollEnabled = NO;
        tableView.dataSource = self;
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, self.verticalOffset)];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.alpha = 0;
        [window addSubview:tableView];
        self.containerView = tableView;
    }

    //setContainerView
    [window addSubview:self.containerView];

    [window addSubview:_screenshotView];

    [self minimizeFromRect:CGRectMake(0, 0, _originalSize.width, _originalSize.height)];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [_screenshotView addGestureRecognizer:panGestureRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [_screenshotView addGestureRecognizer:tapGestureRecognizer];
}

- (void)minimizeFromRect:(CGRect)rect{

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat m = 0.7;
    CGFloat newWidth = _originalSize.width * m;
    CGFloat newHeight = _originalSize.height * m;

    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.8] forKey:kCATransactionAnimationDuration];
    float wh = window.frame.size.width - 80;
    if (!isSide)
        wh = -80;

    [self addAnimation:@"position.x" view:_screenshotView startValue:rect.origin.x endValue:wh];
    [self addAnimation:@"position.y" view:_screenshotView startValue:rect.origin.y endValue:(window.frame.size.height - newHeight) / 2.0];
    [self addAnimation:@"bounds.size.width" view:_screenshotView startValue:rect.size.width endValue:newWidth];
    [self addAnimation:@"bounds.size.height" view:_screenshotView startValue:rect.size.height endValue:newHeight];

    _screenshotView.layer.position = CGPointMake(wh, (window.frame.size.height - newHeight) / 2.0);
    _screenshotView.layer.bounds = CGRectMake(wh, (window.frame.size.height - newHeight) / 2.0, newWidth, newHeight);

    [CATransaction commit];

    if (_containerView.alpha == 0) {
        __typeof (&*self) __weak weakSelf = self;
        weakSelf.containerView.transform = CGAffineTransformScale(_containerView.transform, 0.9, 0.9);
        [UIView animateWithDuration:0.6 animations:^{
            weakSelf.containerView.transform = CGAffineTransformIdentity;
        }];

        [UIView animateWithDuration:0.6 animations:^{
            weakSelf.containerView.alpha = 1;
        }];
    }
}

- (void)restoreFromRect:(CGRect)rect
{
    _screenshotView.userInteractionEnabled = NO;
    while (_screenshotView.gestureRecognizers.count) {
        [_screenshotView removeGestureRecognizer:[_screenshotView.gestureRecognizers objectAtIndex:0]];
    }

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.8] forKey:kCATransactionAnimationDuration];

    [self addAnimation:@"position.x" view:_screenshotView startValue:rect.origin.x endValue:0];
    [self addAnimation:@"position.y" view:_screenshotView startValue:rect.origin.y endValue:0];
    [self addAnimation:@"bounds.size.width" view:_screenshotView startValue:rect.size.width endValue:window.frame.size.width];
    [self addAnimation:@"bounds.size.height" view:_screenshotView startValue:rect.size.height endValue:window.frame.size.height];

    _screenshotView.layer.position = CGPointMake(0, 0);
    _screenshotView.layer.bounds = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    [CATransaction commit];
    [self performSelector:@selector(restoreView) withObject:nil afterDelay:0.8];

    __typeof (&*self) __weak weakSelf = self;
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.containerView.alpha = 0;
        weakSelf.containerView.transform = CGAffineTransformScale(_containerView.transform, 0.7, 0.7);
    }];

    // restore the status bar to its original state.
    [[UIApplication sharedApplication] setStatusBarHidden:_appIsHidingStatusBar withAnimation:UIStatusBarAnimationFade];
    _isShowing = NO;
}

- (void)restoreView
{
    __typeof (&*self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.screenshotView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.screenshotView removeFromSuperview];
    }];
    [_backgroundView removeFromSuperview];
    [_containerView removeFromSuperview];
}

#pragma mark -
#pragma mark Gestures

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    CGPoint translation = [sender translationInView:window];
    if (sender.state == UIGestureRecognizerStateBegan) {
        _initialX = _screenshotView.frame.origin.x;
    }

    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat x = translation.x + _initialX;
        CGFloat m = 1 - ((x / window.frame.size.width) * 210/window.frame.size.width);
        CGFloat y = (window.frame.size.height - _originalSize.height * m) / 2.0;

        _containerView.alpha = (x + 80.0) / window.frame.size.width;

        if (x < 0 || y < 0) {
            _screenshotView.frame = CGRectMake(0, 0, _originalSize.width, _originalSize.height);
        } else {
            _screenshotView.frame = CGRectMake(x, y, _originalSize.width * m, _originalSize.height * m);
        }
    }

    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([sender velocityInView:window].x < 0) {
            [self restoreFromRect:_screenshotView.frame];
        } else {
            [self minimizeFromRect:_screenshotView.frame];
        }
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender
{
    [self restoreFromRect:_screenshotView.frame];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_items objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] objectForKey:@"array"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSDictionary *dic = [_items objectForKey:[NSString stringWithFormat:@"%ld",(long)section]];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winsize.width - 120, 40)];
    headerView.backgroundColor  = [UIColor clearColor];

    UIImageView *images = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    images.image = [UIImage imageNamed:[dic objectForKey:@"Image"]];
    [headerView addSubview:images];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 200, 20)];
    title.text = [dic objectForKey:@"Title"];
    title.textColor = [UIColor whiteColor];
    //    title.font = Font19And17(systemFontOfSize, 15);
    [headerView addSubview:title];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 39, winsize.width - 140, 1)];
    line.backgroundColor = [UIColor whiteColor];
    line.alpha = .4;
    [headerView addSubview:line];

    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"CCSideMenuCell";

    CCSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CCSideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.textLabel.font = self.font;
        cell.textLabel.textColor = self.textColor;
        cell.textLabel.highlightedTextColor = self.highlightedTextColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSArray *array = [[_items objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]] objectForKey:@"array"];
    CCSideMenuItem *item = [array objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.imageView.image = item.image;
    cell.imageView.highlightedImage = item.highlightedImage;
    NSString *noticescount = [userDefaults objectForKey:@"noticescount"];
    if (item.Point) {
        if (noticescount&&noticescount.intValue>0) {
            UILabel *point = [[UILabel alloc] init];
            point.font  = [UIFont systemFontOfSize:13];
            point.textAlignment = NSTextAlignmentCenter;
            point.textColor = [UIColor whiteColor];
            point.text = noticescount;
            CGSize size =[point.text sizeWithAttributes:@{NSFontAttributeName:point.font}];
            if (size.width<size.height) {
                size.width = size.height;
            }
            point.frame = CGRectMake(130, (self.itemHeight-size.height)/2.0, size.width+2, size.height+2);
            point.layer.cornerRadius = size.height/2.0+1;
            point.layer.masksToBounds = YES;
            point.backgroundColor = [UIColor redColor];
            [cell.contentView addSubview:point];
        }
    }
    cell.horizontalOffset = self.horizontalOffset;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CCSideMenuItem *item = [[[_items objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]] objectForKey:@"array"] objectAtIndex:indexPath.row];
    // Case back on subMenu
    if(_isInSubMenu &&
       indexPath.row==0 &&
       indexPath.section == 0){

        [_menuStack removeLastObject];
        if(_menuStack.count==1){
            _isInSubMenu = NO;
        }
        [self showItems:_menuStack.lastObject];

        return;
    }

    // Case menu with subMenu
    if(item.subItems){
        _isInSubMenu = YES;

        // Concat back menu to submenus and show
        NSMutableArray * array = [NSMutableArray arrayWithObject:_backMenu];
        [array addObjectsFromArray:item.subItems];
        //        [self showItems:array];
        
        // Push new menu on stack
        [_menuStack addObject:array];
    }
    
    if (item.action){
        [self hide];
        item.action(self, item);
    }
}


@end
