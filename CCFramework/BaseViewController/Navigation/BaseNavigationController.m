//
//  BaseNavigationController.m
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

#import "BaseNavigationController.h"

@interface BaseNavigationController() <UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController title:(NSString *)rootTitle SelImage:(UIImage *) SelecteImage Image:(UIImage *)image{
    self =  [super initWithRootViewController:rootViewController];
    if (self) {
        [rootViewController setTitle:rootTitle];
        SelecteImage = [SelecteImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.tabBarItem setFinishedSelectedImage:SelecteImage withFinishedUnselectedImage:image];
//        [self.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]} forState:UIControlStateSelected];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    /* UINavigationControllerDelegate */
    self.delegate = self;
    
    __weak typeof (self)weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.interactivePopGestureRecognizer.delegate = weakSelf;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.interactivePopGestureRecognizer.enabled = NO;

    if (self.viewControllers.count)
        viewController.hidesBottomBarWhenPushed = YES;

    [super pushViewController:viewController animated:animated];
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if (navigationController.viewControllers.count == 1) {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
        navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(BOOL)shouldAutorotate
{
    return [self.viewControllers.lastObject shouldAutorotate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.viewControllers.lastObject preferredInterfaceOrientationForPresentation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
