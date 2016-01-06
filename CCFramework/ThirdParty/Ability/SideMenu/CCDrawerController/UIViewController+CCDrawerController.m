//
// CCDrawerController.m
// CCFramework
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


#import "UIViewController+CCDrawerController.h"

@implementation UIViewController (CCDrawerController)


- (CCDrawerController *)cc_drawerController
{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if ([parentViewController isKindOfClass:[CCDrawerController class]]) {
            return (CCDrawerController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}

- (CGRect)cc_visibleDrawerFrame
{
    if ([self isEqual:self.cc_drawerController.leftDrawerViewController] ||
        [self.navigationController isEqual:self.cc_drawerController.leftDrawerViewController]) {
        CGRect rect = self.cc_drawerController.view.bounds;
        rect.size.width = self.cc_drawerController.maximumLeftDrawerWidth;
        if (self.cc_drawerController.showsStatusBarBackgroundView) {
            rect.size.height -= 20.0f;
        }
        return rect;
        
    } else if ([self isEqual:self.cc_drawerController.rightDrawerViewController] ||
               [self.navigationController isEqual:self.cc_drawerController.rightDrawerViewController]) {
        CGRect rect = self.cc_drawerController.view.bounds;
        rect.size.width = self.cc_drawerController.maximumRightDrawerWidth;
        rect.origin.x = CGRectGetWidth(self.cc_drawerController.view.bounds) - rect.size.width;
        if (self.cc_drawerController.showsStatusBarBackgroundView) {
            rect.size.height -= 20.0f;
        }
        return rect;
    } else {
        return CGRectNull;
    }
}

- (IBAction)presentLeftDrawerViewController:(id)sender
{
    [self.cc_drawerController toggleDrawerSide:CCDrawerSideLeft
                                      animated:YES
                                    completion:nil];
}

- (IBAction)presentRightDrawerViewController:(id)sender
{
    [self.cc_drawerController toggleDrawerSide:CCDrawerSideLeft
                                      animated:YES
                                    completion:nil];
}

@end
