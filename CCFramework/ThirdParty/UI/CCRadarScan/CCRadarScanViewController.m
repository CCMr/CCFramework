//
//  CCRadarScanViewController.m
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

#import "CCRadarScanViewController.h"
#import "CCRadarPointView.h"

@interface CCRadarScanViewController ()

@property(nonatomic, strong) CCRadarView *radarView;

@property(nonatomic, readonly) UIStatusBarStyle statusBarStyle;

@end

@implementation CCRadarScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self InitControl];
    [self InitLoadData];
}

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  页面被激活
 *
 *  @param animated animated description
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent)
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  页面加载完成
 *
 *  @param animated animated description
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_radarView startScanning];
}

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  页面销毁
 *
 *  @param animated animated description
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle animated:YES];
}

- (void)InitControl
{
    _radarView = [[CCRadarView alloc] initWithFrame:self.view.bounds];
    _radarView.dataSource = self;
    _radarView.delegate = self;
    _radarView.radius = 180;
    _radarView.imageRadius = 38;
    _radarView.labelText = @"正在搜索附近的目标";
    [self.view addSubview:_radarView];
}

- (void)setBackgroundImage:(NSString *)backgroundImage
{
    _radarView.backgroundImage = [UIImage imageNamed:backgroundImage];
}

- (void)setPersonImage:(NSString *)personImage
{
    _radarView.PersonImage = [UIImage imageNamed:personImage];
}

/**
 *  @author CC, 15-09-30
 *
 *  @brief  加载数据
 */
- (void)InitLoadData
{
}

/**
 *  @author CC, 15-09-30
 *
 *  @brief  刷新数据
 */
- (void)reloadData
{
    [_radarView reloadData];
}

#pragma mark - CCRaderViewDataSource
- (NSInteger)numberOfSectionsInRadarView:(CCRadarView *)radarView
{
    return 4;
}


- (NSInteger)numberOfPointsInRadarView:(CCRadarView *)radarView
{
    return self.userDataArray.count;
}

- (void)didDropOut
{
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 转屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id context) {
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            
        } else {
            
        }
        _radarView.frame = self.view.bounds;
        [self.view setNeedsLayout];
    } completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
