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
//#import "CCPickerViewController.h"
#import "CCActionSheet.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CCPhotoPickerController.h"

@interface CCCameraViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(strong, nonatomic) UIViewController *currentViewController;

@property(nonatomic, copy) Completion callBackBlock;

@end

@implementation CCCameraViewController

- (instancetype)init
{
    if (self = [super init])
        self.minCount = 9;
    return self;
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  启动相机或照片文件视图控制器
 *
 *  @param viewController 显示视图对象
 *  @param complate       回调函数
 */
- (void)startCameraOrPhotoFileWithViewController:(UIViewController *)viewController
                                        complate:(Completion)complate
{
    _currentViewController = viewController;
    
    CCActionSheet *actionSheet = [[CCActionSheet alloc] initWithAdvancedExample];
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
 *  @param viewController 显示视图对象
 *  @param complate       回调函数
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
 *  @param viewController 显示视图对象
 *  @param complate       回调函数
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
    CCPhotoPickerController *photoPickerC = [[CCPhotoPickerController alloc] initWithMaxCount:self.minCount delegate:nil];
    [photoPickerC setDidFinishPickingPhotosBlock:^(NSArray<UIImage *> *_Nullable images, NSArray<CCAssetModel *> *_Nullable assets) {
        self.callBackBlock(images);
    }];
    [[[[UIApplication sharedApplication].windows firstObject] rootViewController] presentViewController:photoPickerC animated:YES completion:nil];
}

/**
 *  @author CC, 2015-12-24
 *  
 *  @brief  选择照片回调
 *
 *  @param imageArray 照片集合
 */
- (void)pickerViewControllerCompleteImage:(NSArray *)imageArray
{
    if (self.callBackBlock)
        self.callBackBlock(imageArray);
}

#pragma mark - 照相机

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  判断设备是否有摄像头
 *
 *  @return 返回判断设备是否有摄像头
 */
- (BOOL)isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  前面的摄像头是否可用
 *
 *  @return 返回前面的摄像头是否可用
 */
- (BOOL)isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  后面的摄像头是否可用
 *
 *  @return 返回后面的摄像头是否可用
 */
- (BOOL)isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  检查摄像头是否支持录像
 *
 *  @return 返回检查摄像头是否支持录像
 */
- (BOOL)doesCameraSupportShootingVideos
{
    return [self cameraSupportsMedia:(NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypeCamera];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  检查摄像头是否支持拍照
 *
 *  @return 返回检查摄像头是否支持拍照
 */
- (BOOL)doesCameraSupportTakingPhotos
{
    return [self cameraSupportsMedia:(NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  判断是否支持某种多媒体类型：拍照，视频
 *
 *  @param paramMediaType  检验类型
 *  @param paramSourceType 判断对象
 *
 *  @return 返回是否支持某种多媒体类型：拍照，视频
 */
- (BOOL)cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType
{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        NSLog(@"Media type is empty.");
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark - 相册文件选取相关
/**
 *  @author CC, 2015-10-13
 *
 *  @brief  相册是否可用
 *
 *  @return 返回相册是否可用
 */
- (BOOL)isPhotoLibraryAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  是否可以在相册中选择视频
 *
 *  @return 返回是否可以在相册中选择视频
 */
- (BOOL)canUserPickVideosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  是否可以在相册中选择视频
 *
 *  @return 返回是否可以在相册中选择视频
 */
- (BOOL)canUserPickPhotosFromPhotoLibrary
{
    return [self cameraSupportsMedia:(NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  初始化相机
 *
 *  @since 1.0
 */
- (void)cameras
{
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init]; //初始化图片选择控制器
        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];	   // 设置类型
        controller.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;      //设置闪光灯模式
        
        // 设置所支持的类型，设置只能拍照，或则只能录像，或者两者都可以
        NSString *requiredMediaType = (NSString *)kUTTypeImage;
        //        NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
        //        NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType, requiredMediaType1,nil];
        NSArray *arrMediaTypes = [NSArray arrayWithObjects:requiredMediaType, nil];
        [controller setMediaTypes:arrMediaTypes];
        
        
        // 设置录制视频的质量
        // [controller setVideoQuality:UIImagePickerControllerQualityTypeHigh];
        //设置最长摄像时间
        // [controller setVideoMaximumDuration:10.f];
        
        //        [controller setAllowsEditing:YES];// 设置是否可以管理已经存在的图片或者视频
        [controller setDelegate:self]; // 设置代理
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            _currentViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        
        [_currentViewController presentViewController:controller animated:YES completion:nil];
    }
}

/**
 *  @author CC, 2015-07-23
 *
 *  @brief  拍照后回调
 *
 *  @param picker 拍照视图对象
 *  @param info   回传数据
 *
 *  @since 1.0
 */
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *theImage = nil;
        if ([picker allowsEditing])					       //判断，图片是否允许修改
            theImage = [info objectForKey:UIImagePickerControllerEditedImage]; //获取用户编辑之后的图像
        else
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage]; // 照片的元数据参数
        
        // 保存图片到相册中
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(theImage, self, selectorToCall, NULL);
        
        NSMutableArray *SelectImageArray = [NSMutableArray array];
        [SelectImageArray addObject:theImage];
        
        _callBackBlock(SelectImageArray);
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // 判断获取类型：视频 => 获取视频文件的url
        NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //创建ALAssetsLibrary对象并将视频保存到媒体库 => Assets Library 框架包是提供了在应用程序中操作图片和视频的相关功能。相当于一个桥梁，链接了应用程序和多媒体文件。
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:mediaURL completionBlock:^(NSURL *assetURL, NSError *error) { // 将视频保存到相册中
            if (!error) {
                NSLog(@"captured video saved with no error.");
            }else{
                NSLog(@"error occured while saving the video:%@", error);
            }
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  保存图片后到相册后，调用的相关方法，查看是否保存成功
 *
 *  @param paramImage       保存图片
 *  @param paramError       错误日志
 *  @param paramContextInfo 结果信息
 */
- (void) imageWasSavedSuccessfully: (UIImage *)paramImage
          didFinishSavingWithError: (NSError *)paramError
                       contextInfo: (void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  当用户取消时，调用该方法
 *
 *  @param picker 拍照视图对象
 */
- (void)imagePickerControllerDidCancel: (UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
