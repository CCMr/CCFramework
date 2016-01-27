//
//  CCVoiceProgressHUD.m
//  CCFramework
//
//  Created by CC on 16/1/26.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCVoiceProgressHUD.h"
#import "UIView+BUIView.h"
#import "CCPulsingHaloLayer.h"
#import "config.h"
#import "NSString+BNSString.h"

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
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    if (!_pulsingHaloLayer) {
        CCPulsingHaloLayer *pulsingHaloLayer = [CCPulsingHaloLayer layer];
        pulsingHaloLayer.haloLayerNumber = 10;
        pulsingHaloLayer.radius = 80;
        pulsingHaloLayer.animationDuration = 5;
        _pulsingHaloLayer = pulsingHaloLayer;
    }
    
    if (!_beaconView) {
        UIView *beaconView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bounds) - 80) / 2, (CGRectGetHeight(self.bounds) - 80) / 2, 80, 80)];
        cc_View_Border_Radius(beaconView, 40, 0.5, [UIColor whiteColor]);
        [self addSubview:beaconView];
        [beaconView.superview.layer insertSublayer:_pulsingHaloLayer below:beaconView.layer];
        _pulsingHaloLayer.position = beaconView.center;
        _beaconView = beaconView;
    }
    
    if (!_timeLabel) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, _beaconView.width, 20)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_beaconView addSubview:timeLabel];
        _timeLabel = timeLabel;
    }
    
    if (!_microPhoneImageView) {
        UIImageView *microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, _timeLabel.bottom, _beaconView.width - 30, _beaconView.height - 30)];
        microPhoneImageView.layer.cornerRadius = 25;
        microPhoneImageView.layer.masksToBounds = YES;
        microPhoneImageView.hidden = YES;
        microPhoneImageView.backgroundColor = [UIColor redColor];
        [_beaconView addSubview:microPhoneImageView];
        _microPhoneImageView = microPhoneImageView;
    }
    
    if (!_recordingHUDImageView) {
        UIImageView *recordingHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _beaconView.width, _beaconView.height)];
        recordingHUDImageView.layer.cornerRadius = 40;
        recordingHUDImageView.layer.masksToBounds = YES;
        recordingHUDImageView.hidden = YES;
        recordingHUDImageView.backgroundColor = [UIColor redColor];
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
    //    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
    //    self.center = center;
    _time = nil;
    _time = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(startAnimation)
                                           userInfo:nil
                                            repeats:YES];
    
    [view.window addSubview:self];
    [self configRecoding:YES];
}

- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower
{
    float value = 0;
    if (peakPower >= 0 && peakPower <= 0.1) {
        value = 1;
    } else if (peakPower > 0.1 && peakPower <= 0.2) {
        value = 2;
    } else if (peakPower > 0.3 && peakPower <= 0.4) {
        value = 3;
    } else if (peakPower > 0.4 && peakPower <= 0.5) {
        value = 4;
    } else if (peakPower > 0.5 && peakPower <= 0.6) {
        value = 5;
    } else if (peakPower > 0.7 && peakPower <= 0.8) {
        value = 6;
    } else if (peakPower > 0.8 && peakPower <= 0.9) {
        value = 7;
    } else if (peakPower > 0.9 && peakPower <= 1.0) {
        value = 8;
    }
    self.pulsingHaloLayer.radius = value * 30;
}

- (void)setPeakPower:(CGFloat)peakPower
{
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

- (void)setColor:(UIColor *)color
{
    [self.pulsingHaloLayer setBackgroundColor:color.CGColor];
    [self.beaconView setBackgroundColor:color];
}

- (void)pauseRecord
{
    [self configRecoding:YES];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = NSLocalizedStringFromTable(@"SlideToCancel", @"MessageDisplayKitString", nil);
    CGFloat w = [self.remindLabel.text calculateTextWidthHeight:self.remindLabel.font].width + 20;
    self.remindLabel.frame = CGRectMake((CGRectGetWidth(self.bounds) - w) / 2, _beaconView.bottom + 10, w, 20);
}

- (void)resaueRecord
{
    [self configRecoding:NO];
    self.remindLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.630];
    self.remindLabel.text = NSLocalizedStringFromTable(@"ReleaseToCancel", @"MessageDisplayKitString", nil);
    CGFloat w = [self.remindLabel.text calculateTextWidthHeight:self.remindLabel.font].width + 20;
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
    [UIView setAnimationDuration:0.09];
    UIView.AnimationRepeatAutoreverses = YES;
    float second = [_timeLabel.text floatValue];
    if (second >= 50.0f) {
        _timeLabel.textColor = [UIColor redColor];
    } else {
        _timeLabel.textColor = [UIColor whiteColor];
    }
    _timeLabel.text = [NSString stringWithFormat:@"%.1f", second + 0.1];
    [UIView commitAnimations];
}

@end
