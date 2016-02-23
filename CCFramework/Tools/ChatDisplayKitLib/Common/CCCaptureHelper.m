//
//  CCCaptureHelper.m
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

#import "CCCaptureHelper.h"

@interface CCCaptureHelper () <AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic, copy) DidOutputScanResultBlock didOutputSampleBuffer;

@property(nonatomic, strong) dispatch_queue_t captureSessionQueue;

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureDeviceInput *captureInput;
@property(nonatomic, strong) AVCaptureDeviceInput *frontDeviceInput;
@property(nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;
@property(nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property(strong, nonatomic) AVCaptureDevice *defaultDevice;
@end

@implementation CCCaptureHelper

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  回调Block
 *
 *  @param didOutputSampleBuffer 委托
 */
- (void)setDidOutputSampleBufferHandle:(DidOutputScanResultBlock)didOutputSampleBuffer
{
    self.didOutputSampleBuffer = didOutputSampleBuffer;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  显示扫描视图
 *
 *  @param preview 父View
 */
- (void)showCaptureOnView:(UIView *)preview
{
    dispatch_async(self.captureSessionQueue, ^{
        [self.captureSession startRunning];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.captureVideoPreviewLayer.frame = preview.bounds;
            [preview.layer addSublayer:self.captureVideoPreviewLayer];
        });
    });
}

#pragma mark - Propertys
/**
 *  @author CC, 2015-10-13
 *
 *  @brief  初始化扫描
 */
- (void)setupAVComponents
{
    self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (_defaultDevice) {
        self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:_defaultDevice error:nil];
        self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        self.captureSession = [[AVCaptureSession alloc] init];
        self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront)
                self.defaultDevice = device;
        }
        
        if (_defaultDevice)
            self.frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_defaultDevice error:nil];
    }
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  加载扫描
 */
- (void)configureDefaultComponents
{
    if (self.captureType == CCCaptureHelperTypeMeta) {
        [_captureSession addOutput:_captureMetadataOutput];
        
        if (_captureInput)
            [_captureSession addInput:_captureInput];
        
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:self.captureSessionQueue];
        
        if ([[_captureMetadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode])
            [_captureMetadataOutput setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode ]];
        
    } else {
        if ([_captureSession canAddInput:_captureInput])
            [self.captureSession addInput:_captureInput];
        
        self.captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        self.captureOutput.alwaysDiscardsLateVideoFrames = YES;
        [self.captureOutput setSampleBufferDelegate:self queue:self.captureSessionQueue];
        NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
        NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [_captureOutput setVideoSettings:videoSettings];
        
        [self.captureSession addOutput:self.captureOutput];
        
        NSString *preset = 0;
        // Proxy for "is this iOS 5" ...
        if (NSClassFromString(@"NSOrderedSet") &&
            [UIScreen mainScreen].scale > 1 &&
            [_defaultDevice supportsAVCaptureSessionPreset:AVCaptureSessionPresetiFrame960x540])
            preset = AVCaptureSessionPresetiFrame960x540;
        
        if (!preset)
            preset = AVCaptureSessionPresetMedium;
        self.captureSession.sessionPreset = preset;
    }
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  扫描视图
 *
 *  @return 返回扫描视图
 */
- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer
{
    if (!_captureVideoPreviewLayer) {
        _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _captureVideoPreviewLayer;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  切换前后置摄像头
 */
- (void)switchDeviceInput
{
    if (_frontDeviceInput) {
        [_captureSession beginConfiguration];
        
        AVCaptureDeviceInput *currentInput = [_captureSession.inputs firstObject];
        [_captureSession removeInput:currentInput];
        
        AVCaptureDeviceInput *newDeviceInput = (currentInput.device.position == AVCaptureDevicePositionFront) ? _captureInput : _frontDeviceInput;
        [_captureSession addInput:newDeviceInput];
        
        [_captureSession commitConfiguration];
    }
}

/**
 *  @author CC, 16-02-22
 *  
 *  @brief 切换照明
 */
- (void)switchTorch
{
    _isTorch = !_isTorch;
    
    AVCaptureTorchMode torch = self.captureInput.device.torchMode;
    
    switch (_captureInput.device.torchMode) {
        case AVCaptureTorchModeAuto:
            break;
        case AVCaptureTorchModeOff:
            torch = AVCaptureTorchModeOn;
            break;
        case AVCaptureTorchModeOn:
            torch = AVCaptureTorchModeOff;
            break;
        default:
            break;
    }
    
    [_captureInput.device lockForConfiguration:nil];
    _captureInput.device.torchMode = torch;
    [_captureInput.device unlockForConfiguration];
    
    
}

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self) {
        self.captureSessionQueue = dispatch_queue_create("com.CC.captureSessionQueue", 0);
        self.captureType = CCCaptureHelperTypeMeta;
        [self setupAVComponents];
        [self configureDefaultComponents];
    }
    return self;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  启动扫描
 */
- (void)startRunning
{
    if (![self.captureSession isRunning])
        [self.captureSession startRunning];
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  停止扫描
 */
- (void)stopRunning
{
    if ([self.captureSession isRunning])
        [self.captureSession stopRunning];
}

- (void)dealloc
{
    _captureSessionQueue = nil;
    _captureVideoPreviewLayer = nil;
    
    if (![_captureSession canAddOutput:self.captureOutput])
        [_captureSession removeOutput:self.captureOutput];
    
    if (![_captureSession canAddOutput:self.captureMetadataOutput])
        [_captureSession removeOutput:self.captureMetadataOutput];
    
    self.captureOutput = nil;
    self.captureMetadataOutput = nil;
    
    [_captureSession stopRunning];
    _captureSession = nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBuffer Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]] && [current.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *)current stringValue];
            
            if ([self.delegate respondsToSelector:@selector(DidOutputSampleBufferBlock:ScanResult:)])
                [self.delegate DidOutputSampleBufferBlock:self ScanResult:scannedResult];
            else if (self.didOutputSampleBuffer)
                self.didOutputSampleBuffer(scannedResult);
            break;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if ([self.delegate respondsToSelector:@selector(DidOutputSampleBufferBlock:CMSampleBufferRef:)])
        [self.delegate DidOutputSampleBufferBlock:self CMSampleBufferRef:sampleBuffer];
    else if (self.didOutputSampleBuffer)
        self.didOutputSampleBuffer((__bridge id)(sampleBuffer));
}

@end
