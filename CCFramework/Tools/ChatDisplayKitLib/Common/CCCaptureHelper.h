//
//  CCCaptureHelper.h
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


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  二维码扫描模式
 */
typedef NS_ENUM(NSInteger, CCCaptureHelperType){
    /** 扫描图像三方解析 */
    CCCaptureHelperTypeVideo,
    /** 扫描图像系统解析 */
    CCCaptureHelperTypeMeta, //默认模式
};

@class CCCaptureHelper;

typedef void(^DidOutputScanResultBlock)(id scanResult);

@protocol CCCaptureHelperDelegate <NSObject>

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  扫描返回的结果
 *
 *  @param capture      当前对象
 *  @param sampleBuffer 扫描结果对象
 */
-(void)DidOutputSampleBufferBlock: (CCCaptureHelper *)capture
                CMSampleBufferRef: (CMSampleBufferRef) sampleBuffer;

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  扫描返回结果系统自带
 *
 *  @param capture 当前对象
 *  @param result  扫描之后的结果
 */
-(void)DidOutputSampleBufferBlock: (CCCaptureHelper *)capture
                       ScanResult: (NSString *)result;

@end

@interface CCCaptureHelper : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  扫描方式
 */
@property (nonatomic, assign) CCCaptureHelperType captureType;

/**
 *  @author CC, 2015-10-12
 *
 *  @brief  扫描结果委托
 */
@property (nonatomic, weak) id<CCCaptureHelperDelegate> delegate;


/**
 *  @author CC, 2015-10-12
 *
 *  @brief  扫描结果回调函数
 *
 *  @param didOutputSampleBuffer 返回结果
 */
- (void)setDidOutputSampleBufferHandle:(DidOutputScanResultBlock)didOutputSampleBuffer;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  设置布局
 *
 *  @param preview 父View
 */
- (void)showCaptureOnView:(UIView *)preview;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  启动扫描
 */
- (void)startRunning;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  停止扫描
 */
- (void)stopRunning;

@end
