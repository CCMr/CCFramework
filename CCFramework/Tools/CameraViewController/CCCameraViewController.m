//
//  CCCameraViewController.m
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

#import "CCCameraViewController.h"
#import "CCPickerViewController.h"
#import "CCActionSheet.h"

@interface CCCameraViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIViewController *currentViewController;

@property (nonatomic, copy) Completion callBackBlock;

@end

@implementation CCCameraViewController

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  启动相机或照片文件视图控制器
 *
 *  @param viewController <#viewController description#>
 *  @param complate       <#complate description#>
 *
 *  @since 1.0
 */
- (void)startCameraOrPhotoFileWithViewController:(UIViewController *)viewController
                                        complate:(Completion)complate
{
    _currentViewController = viewController;

    CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithTitle:@""];
    [actionSheet addButtonWithTitle:@"拍照获取" image:nil type:CCActionSheetButtonTypeTextAlignmentCenter handler:^(CCActionSheet *actionSheet) {
        [self cameras];
    }];

    [actionSheet addButtonWithTitle:@"从相册选择" image:nil type:CCActionSheetButtonTypeTextAlignmentCenter handler:^(CCActionSheet *actionSheet) {
        [self LocalPhoto];
    }];
    [actionSheet show];

    _callBackBlock = complate;
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  启动相机试图控制器
 *
 *  @param viewController <#viewController description#>
 *  @param complate       <#complate description#>
 *
 *  @since <#1.0#>
 */
- (void)startCcameraWithViewController:(UIViewController *)viewController
                              complate:(Completion)complate
{
    _currentViewController = viewController;
    [self cameras];
    _callBackBlock = complate;
}

/**
 *  @author CC, 15-08-19
 *
 *  @brief  启动照片文件视图控制器
 *
 *  @param viewController <#viewController description#>
 *  @param complate       <#complate description#>
 *
 *  @since <#1.0#>
 */
- (void)startPhotoFileWithViewController:(UIViewController *)viewController
                                complate:(Completion)complate
{
    _currentViewController = viewController;
    [self LocalPhoto];
    _callBackBlock = complate;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  打开本地相册
 *
 *  @since 1.0
 */
- (void)LocalPhoto
{
    CCPickerViewController *pickerViewcontroller = [[CCPickerViewController alloc] init];
    pickerViewcontroller.minCount = 9;
    [pickerViewcontroller CompleteImage:^(id obj) {
        _callBackBlock(obj);
    }];
    [pickerViewcontroller show];
}

#pragma mark - 照相机
/**
 *  @author CC, 2015-07-23
 *
 *  @brief  初始化相机
 *
 *  @since 1.0
 */
-(void)cameras{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *viewController = [[UIImagePickerController alloc]init];
        viewController.delegate = self;
        viewController.allowsEditing = NO;
        viewController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  拍照后回调
 *
 *  @param picker <#picker description#>
 *  @param info   <#info description#>
 *
 *  @since 1.0
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSData *data = UIImagePNGRepresentation(image);
        if (!data)
            data = UIImageJPEGRepresentation(image, 1.0);
        NSString *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:[documentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
        //        NSString *filePath = [[NSString alloc] initWithFormat:@"%@%@",documentsPath,@"/image.png"]; //保存路径与名字
        [picker dismissViewControllerAnimated:YES completion:nil];

        NSMutableArray *SelectImageArray = [NSMutableArray array];
        [SelectImageArray addObject:image];

        _callBackBlock(SelectImageArray);
    }
}

@end
