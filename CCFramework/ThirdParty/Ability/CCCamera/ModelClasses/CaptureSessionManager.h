//
//  CaptureSessionManager.h
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

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#import "Constants.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

///Protocol Definition
@protocol CaptureSessionManagerDelegate <NSObject>
@required - (void)cameraSessionManagerDidCaptureImage;
@required - (void)cameraSessionManagerFailedToCaptureImage;
@required - (void)cameraSessionManagerDidReportAvailability:(BOOL)deviceAvailability forCameraType:(CameraType)cameraType;
@required - (void)cameraSessionManagerDidReportDeviceStatistics:(CameraStatistics)deviceStatistics; //Report every .125 seconds

@end

@interface CaptureSessionManager : NSObject

//Weak pointers
@property (nonatomic, weak) id<CaptureSessionManagerDelegate>delegate;
@property (nonatomic, weak) AVCaptureDevice *activeCamera;

//Strong Pointers
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIImage *stillImage;
@property (nonatomic, strong) NSData *stillImageData;

//Primative Variables
@property (nonatomic,assign,getter=isTorchEnabled) BOOL enableTorch;

//API Methods
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)addVideoPreviewLayer;
- (void)initiateCaptureSessionForCamera:(CameraType)cameraType;
- (void)stop;

@end
