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

@interface CCCaptureHelper ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, copy) DidOutputScanResultBlock didOutputSampleBuffer;

@property (nonatomic, strong) dispatch_queue_t captureSessionQueue;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadataOutput;
@property (strong, nonatomic) AVCaptureDevice *defaultDevice;
@end

@implementation CCCaptureHelper

- (void)setDidOutputSampleBufferHandle:(DidOutputScanResultBlock)didOutputSampleBuffer {
    self.didOutputSampleBuffer = didOutputSampleBuffer;
}

- (void)showCaptureOnView:(UIView *)preview {
    dispatch_async(self.captureSessionQueue, ^{
        [self.captureSession startRunning];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.captureVideoPreviewLayer.frame = preview.bounds;
            [preview.layer addSublayer:self.captureVideoPreviewLayer];
        });
    });
}

#pragma mark - Propertys

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];

        if ([_captureSession canAddInput:self.captureInput])
            [self.captureSession addInput:self.captureInput];

        [self.captureSession addOutput: self.captureType == CCCaptureHelperTypeMeta ? self.captureMetadataOutput : self.captureOutput];

//        NSString* preset = 0;
//        if (NSClassFromString(@"NSOrderedSet") && // Proxy for "is this iOS 5" ...
//            [UIScreen mainScreen].scale > 1 &&
//            [inputDevice
//             supportsAVCaptureSessionPreset:AVCaptureSessionPresetiFrame960x540]) {
//                preset = AVCaptureSessionPresetiFrame960x540;
//            }
//        if (!preset) {
//            preset = AVCaptureSessionPresetMedium;
//        }
//        self.captureSession.sessionPreset = preset;
    }
    return _captureSession;
}

-(AVCaptureDevice *)defaultDevice
{
    if (!_defaultDevice) {
        _defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _defaultDevice;
}

-(AVCaptureDeviceInput *)captureInput
{
    if (!_captureInput) {
        _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:self.defaultDevice error:nil];
    }
    return _captureInput;
}

- (AVCaptureMetadataOutput *)captureMetadataOutput
{
    if (!_captureMetadataOutput) {
        _captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureMetadataOutput setMetadataObjectsDelegate:self queue:self.captureSessionQueue];

        if ([[_captureMetadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
            [_captureMetadataOutput setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode ]];
        }
    }
    return _captureMetadataOutput;
}

-(AVCaptureVideoDataOutput *)captureOutput
{
    if (!_captureOutput) {
        _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
        _captureOutput.alwaysDiscardsLateVideoFrames = YES;
        [_captureOutput setSampleBufferDelegate:self queue:self.captureSessionQueue];
        NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
        NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [_captureOutput setVideoSettings:videoSettings];
    }
    return _captureOutput;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer {
    if (!_captureVideoPreviewLayer) {
        _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _captureVideoPreviewLayer;
}

#pragma mark - Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        _captureSessionQueue = dispatch_queue_create("com.CC.captureSessionQueue", 0);
        self.captureType = CCCaptureHelperTypeMeta;
    }
    return self;
}

- (void)startRunning
{
    [self.captureSession startRunning];
}

- (void)stopRunning
{
    [self.captureSession stopRunning];
}

- (void)dealloc {
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
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [current.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];

            if ([self.delegate respondsToSelector:@selector(DidOutputSampleBufferBlock:ScanResult:)])
                [self.delegate DidOutputSampleBufferBlock:self ScanResult:scannedResult];
            else if (self.didOutputSampleBuffer)
                self.didOutputSampleBuffer(scannedResult);
            break;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(DidOutputSampleBufferBlock:CMSampleBufferRef:)])
        [self.delegate DidOutputSampleBufferBlock:self CMSampleBufferRef:sampleBuffer];
    else if (self.didOutputSampleBuffer)
        self.didOutputSampleBuffer((__bridge id)(sampleBuffer));
}

@end
