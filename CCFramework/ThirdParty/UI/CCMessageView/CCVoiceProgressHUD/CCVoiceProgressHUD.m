//
//  CCVoiceProgressHUD.m
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

#import "CCVoiceProgressHUD.h"
#import "UIView+Frame.h"
#import "CCPulsingHaloLayer.h"
#import "config.h"
#import "NSString+Additions.h"

@interface CCVoiceProgressHUD ()

@property(nonatomic, weak) UIView *beaconView;

/**
 *  @author CC, 2016-01-26
 *
 *  @brief 指示标签
 */
@property(nonatomic, weak) UILabel *remindLabel;

/**
 *  @author CC, 2016-01-26
 *
 *  @brief 时间长
 */
@property(nonatomic, weak) UILabel *timeLabel;

/**
 *  @author CC, 2016-01-26
 *
 *  @brief 麦克风
 */
@property(nonatomic, weak) UIImageView *microPhoneImageView;

/**
 *  @author CC, 2016-01-26
 *
 *  @brief 语音指示图
 */
@property(nonatomic, weak) UIImageView *recordingHUDImageView;

/**
 *  @author CC, 2016-01-26
 *
 *  @brief 计时器
 */
@property(nonatomic, strong) NSTimer *time;

/**
 *  @author CC, 2016-01-26
 *
 *  @brief 脉冲
 */
@property(nonatomic, weak) CCPulsingHaloLayer *pulsingHaloLayer;

@end

@implementation CCVoiceProgressHUD

- (instancetype)init
{
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

    if (!_pulsingHaloLayer) {
        CCPulsingHaloLayer *pulsingHaloLayer = [CCPulsingHaloLayer layer];
        pulsingHaloLayer.haloLayerNumber = 5;
        pulsingHaloLayer.radius = 80;
        pulsingHaloLayer.animationDuration = 5;
        _pulsingHaloLayer = pulsingHaloLayer;
    }

    if (!_beaconView) {
        UIImage *image = [UIImage imageNamed:@"microphoneBG"];

        UIImageView *beaconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - image.size.width) / 2, (CGRectGetHeight(self.bounds) - image.size.height) / 2, image.size.width, image.size.height)];
        beaconView.image = image;
//        cc_View_Border_Radius(beaconView, 40, 0.5, [UIColor whiteColor]);
        [self addSubview:beaconView];
        [beaconView.superview.layer insertSublayer:_pulsingHaloLayer below:beaconView.layer];
        _pulsingHaloLayer.position = beaconView.center;
        _beaconView = beaconView;
    }

    if (!_timeLabel) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, _beaconView.width, 20)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.text = @"00:00";
        timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_beaconView addSubview:timeLabel];
        _timeLabel = timeLabel;
    }

    if (!_microPhoneImageView) {
        UIImage *images = [UIImage imageNamed:@"microphone"];

        UIImageView *microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_beaconView.width - images.size.width) / 2, _timeLabel.bottom + 10, images.size.width, images.size.height)];
        microPhoneImageView.hidden = YES;
        microPhoneImageView.image = images;
        microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        microPhoneImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_beaconView addSubview:microPhoneImageView];
        _microPhoneImageView = microPhoneImageView;
    }

    if (!_recordingHUDImageView) {
        UIImage *images = [UIImage imageNamed:@"microphoneCancel"];

        UIImageView *recordingHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_beaconView.width - images.size.width) / 2, (_beaconView.height - images.size.height) / 2, images.size.width, images.size.height)];
        recordingHUDImageView.image = images;
        recordingHUDImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        recordingHUDImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_beaconView addSubview:recordingHUDImageView];
        _recordingHUDImageView = recordingHUDImageView;
    }

    if (!_remindLabel) {
        UILabel *remindLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 300) / 2, _beaconView.bottom + 10, 300, 20)];
        remindLabel.textColor = [UIColor whiteColor];
        remindLabel.font = [UIFont systemFontOfSize:13];
        remindLabel.layer.masksToBounds = YES;
        remindLabel.layer.cornerRadius = 4;
        remindLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        remindLabel.backgroundColor = [UIColor clearColor];
        remindLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:remindLabel];
        _remindLabel = remindLabel;
    }
}

- (void)startRecordingHUDAtView:(UIView *)view
{
    _time = nil;
    _time = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(startAnimation)
                                           userInfo:nil
                                            repeats:YES];

//    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
//    self.center = center;
    [view.window addSubview:self];
    [self configRecoding:YES];
    [self pauseRecord];
}

- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower
{
    NSString *imageName = @"microphone";
    float value = 0;
    if (peakPower >= 0 && peakPower <= 0.1) {
        value = 1;
        imageName = [imageName stringByAppendingString:@""];
    } else if (peakPower > 0.1 && peakPower <= 0.2) {
        value = 2;
        imageName = [imageName stringByAppendingString:@"1"];
    } else if (peakPower > 0.3 && peakPower <= 0.4) {
        value = 3;
        imageName = [imageName stringByAppendingString:@"2"];
    } else if (peakPower > 0.4 && peakPower <= 0.5) {
        value = 4;
        imageName = [imageName stringByAppendingString:@"3"];
    } else if (peakPower > 0.5 && peakPower <= 0.6) {
        value = 5;
        imageName = [imageName stringByAppendingString:@"4"];
    } else if (peakPower > 0.7 && peakPower <= 0.8) {
        value = 6;
        imageName = [imageName stringByAppendingString:@"5"];
    } else if (peakPower > 0.8 && peakPower <= 0.9) {
        value = 7;
        imageName = [imageName stringByAppendingString:@"6"];
    } else if (peakPower > 0.9 && peakPower <= 1.0) {
        value = 8;
        imageName = [imageName stringByAppendingString:@"7"];
    }
    self.microPhoneImageView.image = [UIImage imageNamed:imageName];
    self.pulsingHaloLayer.radius = value + 80;
}

- (void)setPeakPower:(CGFloat)peakPower
{
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

- (void)setColor:(UIColor *)color
{
    [self.pulsingHaloLayer setBackgroundColor:color.CGColor];
//    [self.beaconView setBackgroundColor:color];
}

- (void)pauseRecord
{
    [self configRecoding:YES];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = NSLocalizedStringFromTable(@"手指上划，取消发送", @"MessageDisplayKitString", nil);
    CGFloat w = [self.remindLabel.text calculateTextWidthWidth:self.bounds.size.width Font:self.remindLabel.font].width + 20;
    self.remindLabel.frame = CGRectMake((CGRectGetWidth(self.bounds) - w) / 2, _beaconView.bottom + 10, w, 20);
}

- (void)resaueRecord
{
    [self configRecoding:NO];
    self.remindLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.630];
    self.remindLabel.text = NSLocalizedStringFromTable(@"松开手指，取消发送", @"MessageDisplayKitString", nil);
    CGFloat w = [self.remindLabel.text calculateTextWidthWidth:self.bounds.size.width Font:self.remindLabel.font].width + 20;
    self.remindLabel.frame = CGRectMake((CGRectGetWidth(self.bounds) - w) / 2, _beaconView.bottom + 10, w, 20);
}

- (void)stopRecordCompled:(void (^)(BOOL fnished))compled
{
    [self dismissCompled:compled];
}

- (void)cancelRecordCompled:(void (^)(BOOL fnished))compled
{
    [self dismissCompled:compled];
}

- (void)dismissCompled:(void (^)(BOOL fnished))compled
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.time invalidate];
        self.time = nil;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
        compled(finished);
    }];
}

- (void)configRecoding:(BOOL)recording
{
    self.microPhoneImageView.hidden = !recording;
    self.timeLabel.hidden = !recording;
    self.recordingHUDImageView.hidden = recording;
}

/**
 *  @author CC, 2016-01-26
 *
 *  @brief 计时
 */
- (void)startAnimation
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    UIView.AnimationRepeatAutoreverses = YES;

    float second = _timeLabel.tag;
    if (second >= 50.0f)
        _timeLabel.textColor = [UIColor redColor];
    else
        _timeLabel.textColor = [UIColor whiteColor];

    second++;
    _timeLabel.tag = second;

    NSString *seconds;
    if (second < 10)
        seconds = [NSString stringWithFormat:@"0%.0f", second];
    else
        seconds = [NSString stringWithFormat:@"%.0f", second];

    _timeLabel.text = [NSString stringWithFormat:@"00:%@", seconds];
    [UIView commitAnimations];
}

@end
