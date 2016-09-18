//
//  CCQRCodeViewController.h
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

#import "BaseViewController.h"

@interface CCQRCodeViewController : BaseViewController

/**
 *  @author CC, 2015-10-20
 *
 *  @brief  是否系统处理
 */
@property(nonatomic, assign) BOOL scanDealWithResult;

@property(nonatomic, strong) UIView *buttonContainerView;

/**
 *  @author CC, 2015-10-09
 *
 *  @brief  二维码分析结果
 *
 *  @param block 返回结果回调函数
 */
- (void)diAnalysisOutcome:(void (^)(NSString *outcome))block;

/**
 *  @author CC, 16-02-22
 *
 *  @brief 分析二维码
 *
 *  @param qrCode 二维码图片
 */
- (void)analysisQRCode:(UIImage *)qrCode;

/**
 *  @author CC, 16-02-22
 *
 *  @brief 切换照明
 */
- (void)switchTorch;

/**
 *  @author CC, 16-02-23
 *
 *  @brief 选着相册
 */
- (void)showPhotoLibray;

/**
 *  @author CC, 16-02-23
 *
 *  @brief 启动扫描
 */
- (void)startRunning;

/**
 *  @author CC, 16-02-23
 *
 *  @brief 关闭扫描
 */
- (void)stopRunning;

/**
 *  @author CC, 16-09-18
 *
 *  @brief 二维码解析结果
 *
 *  @param outcome 解析结果
 */
-(void)didDiAnalysisOutcome:(NSString *)outcome;

@end
