//
//  CCQRCodeDisplayViewController.m
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

#import "CCQRCodeDisplayViewController.h"
#import "CCWebView.h"

@interface CCQRCodeDisplayViewController ()<CCWebViewDelegate>

@property (nonatomic, strong) CCWebView *webView;

@end

@implementation CCQRCodeDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self InitControl];
}

-(void)InitControl
{
    UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    bgView.backgroundColor = [UIColor redColor];
    [self.view addSubview:bgView];


    CGRect frame = self.view.bounds;
    frame.size.height -= 64;
     _webView = [[CCWebView alloc] initWithFrame:frame];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.webView loadRequest:self.baseURL];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [array removeObjectAtIndex:array.count - 2];
    self.navigationController.viewControllers = array;
}

#pragma mark - CCWebViewDelegate

/**
 *  @author CC, 2015-10-19
 *
 *  @brief  初始化进度条
 *
 *  @return 返回当前视图的导航栏
 */
-(UINavigationBar *)webViewInitWithProgress
{
    return self.navigationController.navigationBar;
}

-(void)webViewDidFinishLoad:(CCWebView *)webView Title:(NSString *)title
{
    self.title = title;
}

-(void)webViewProgress:(CCWebView *)webViewProgress updateProgress:(float)progress
{
    
}

#pragma mark - 转屏
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id  context) {
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {

        } else {

        }
        _webView.frame = self.view.bounds;
        [self.view setNeedsLayout];
    } completion:nil];
}

@end
