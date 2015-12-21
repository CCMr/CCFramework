//
//  CCPickerViewController.m
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

#import "CCPickerViewController.h"
#import "CCPickerGroupViewController.h"
#import "BaseNavigationController.h"

@interface CCPickerViewController ()

@property(nonatomic, weak) CCPickerGroupViewController *groupVc;

@property(nonatomic, copy) Completion callBackBlock;

@end

@implementation CCPickerViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self createNavigationController];
    }
    return self;
}

#pragma mark 初始化导航控制器
/**
 *  @author CC, 2015-06-04 20:06:49
 *
 *  @brief  初始化导航控制器
 *
 *  @since 1.0
 */
- (void)createNavigationController
{
    CCPickerGroupViewController *groupVc = [[CCPickerGroupViewController alloc] init];
    groupVc.IsPush = YES;
    groupVc.minCount = 9;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:groupVc];
    nav.view.frame = self.view.bounds;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.groupVc = groupVc;
}

#pragma mark - 展示控制器
/**
 *  @author CC, 2015-06-04 20:06:32
 *
 *  @brief  显示页面控制器
 *
 *  @since 1.0
 */
- (void)show
{
    [[[[UIApplication sharedApplication].windows firstObject] rootViewController] presentViewController:self animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self addNotification];
}

/**
 *  @author CC, 2015-06-04 20:06:19
 *
 *  @brief  监听异步done通知
 *
 *  @since 1.0
 */
- (void)addNotification
{
    cc_NoticeObserver(self, @selector(done:), @"CC_PICKER_TAKE_DONE", nil);
}

/**
 *  @author CC, 2015-06-04 20:06:49
 *
 *  @brief  完成选择触发委托或Block
 *
 *  @param note <#note description#>
 *
 *  @since 1.0
 */
- (void)done:(NSNotification *)note
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSArray *selectArray = note.object;
    MainThread(^{
        if ([self.delegate respondsToSelector:@selector(pickerViewControllerCompleteImage:)])
            [self.delegate pickerViewControllerCompleteImage:selectArray];
        else if (_callBackBlock)
            _callBackBlock(selectArray);
    });
}

- (void)setDelegate:(id<CCPickerDelegate>)delegate
{
    _delegate = delegate;
    self.groupVc.delegate = delegate;
}

/**
 *  @author CC, 2015-06-04 20:06:14
 *
 *  @brief  Block回调函数
 *
 *  @param block <#block description#>
 *
 *  @since 1.0
 */
- (void)CompleteImage:(Completion)block
{
    _callBackBlock = block;
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
        self.view.frame = self.view.bounds;
        [self.view setNeedsLayout];
    } completion:nil];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
