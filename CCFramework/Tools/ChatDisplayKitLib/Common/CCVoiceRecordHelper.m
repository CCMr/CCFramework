//
//  CCVoiceRecordHelper.m
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CCVoiceRecordHelper.h"
#import "CCVoiceCommonHelper.h"
#import "Config.h"

@interface CCVoiceRecordHelper () <AVAudioRecorderDelegate> {
    NSTimer *_timer;
    
    BOOL _isPause;
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    UIBackgroundTaskIdentifier _backgroundIdentifier;
#endif
}

@property(nonatomic, copy, readwrite) NSString *recordPath;
@property(nonatomic, readwrite) NSTimeInterval currentTimeInterval;

@property(nonatomic, strong) AVAudioRecorder *recorder;

@end

@implementation CCVoiceRecordHelper

- (id)init
{
    self = [super init];
    if (self) {
        self.maxRecordTime = kVoiceRecorderTotalTime;
        self.recordDuration = @"0";
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        _backgroundIdentifier = UIBackgroundTaskInvalid;
#endif
    }
    return self;
}

- (void)dealloc
{
    [self stopRecord];
    self.recordPath = nil;
    [self stopBackgroundTask];
}

- (void)startBackgroundTask
{
    [self stopBackgroundTask];
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    _backgroundIdentifier = [[UIApplication sharedApplication]
                             beginBackgroundTaskWithExpirationHandler:^{
                                 [self stopBackgroundTask];
                             }];
#endif
}

- (void)stopBackgroundTask
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    if (_backgroundIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundIdentifier];
        _backgroundIdentifier = UIBackgroundTaskInvalid;
    }
#endif
}

- (void)resetTimer
{
    if (!_timer)
        return;
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)cancelRecording
{
    if (!_recorder)
        return;
    
    if (self.recorder.isRecording) {
        [self.recorder stop];
    }
    
    self.recorder = nil;
}

- (void)stopRecord
{
    [self cancelRecording];
    [self resetTimer];
}

- (void)prepareRecordingWithPath:(NSString *)path
       prepareRecorderCompletion:(CCPrepareRecorderCompletion)prepareRecorderCompletion
{
    WEAKSELF;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _isPause = NO;
        
        NSError *error = nil;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (error) {
            NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
            return;
        }
        
        error = nil;
        [audioSession setActive:YES error:&error];
        if (error) {
            NSLog(@"audioSession: %@ %ld %@", [error domain], (long)[error code], [[error userInfo] description]);
            return;
        }
        
        if (weakSelf) {
            STRONGSELF;
            strongSelf.recordPath = path;
            error = nil;
            
            if (strongSelf.recorder) {
                [strongSelf cancelRecording];
            } else {
                strongSelf.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[CCVoiceCommonHelper getPathByFileName:strongSelf.recordPath ofType:@"wav"]] settings:[CCVoiceCommonHelper getAudioRecorderSettingDict] error:&error];
                strongSelf.recorder.delegate = strongSelf;
                
                [strongSelf.recorder prepareToRecord];
                strongSelf.recorder.meteringEnabled = YES;
                [strongSelf.recorder recordForDuration:(NSTimeInterval)160];
                [strongSelf startBackgroundTask];
            }
            
            if (error) {
                NSLog(@"audioSession: %@ %ld %@", [error domain],
                      (long)[error code], [[error userInfo] description]);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //上層如果傳會來說已經取消了, 那這邊就做原先取消的動作
                if (!prepareRecorderCompletion()) {
                    [strongSelf cancelledDeleteWithCompletion:^{
                    }];
                }
            });
        }
    });
}

- (void)startRecordingWithStartRecorderCompletion:(CCStartRecorderCompletion)startRecorderCompletion
{
    if ([_recorder record]) {
        [self resetTimer];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                  target:self
                                                selector:@selector(updateMeters)
                                                userInfo:nil
                                                 repeats:YES];
        if (startRecorderCompletion)
            dispatch_async(dispatch_get_main_queue(), ^{
                startRecorderCompletion();
            });
    }
}

- (void)resumeRecordingWithResumeRecorderCompletion:(CCResumeRecorderCompletion)resumeRecorderCompletion
{
    _isPause = NO;
    if (_recorder) {
        if ([_recorder record]) {
            dispatch_async(dispatch_get_main_queue(), resumeRecorderCompletion);
        }
    }
}

- (void)pauseRecordingWithPauseRecorderCompletion:(CCPauseRecorderCompletion)pauseRecorderCompletion
{
    _isPause = YES;
    if (_recorder) {
        [_recorder pause];
    }
    if (!_recorder.isRecording)
        dispatch_async(dispatch_get_main_queue(), pauseRecorderCompletion);
}

- (void)stopRecordingWithStopRecorderCompletion:(CCStopRecorderCompletion)stopRecorderCompletion
{
    _isPause = NO;
    [self stopBackgroundTask];
    [self stopRecord];
    [self getVoiceDuration:_recordPath];
    dispatch_async(dispatch_get_main_queue(), stopRecorderCompletion);
}

- (void)cancelledDeleteWithCompletion:(CCCancellRecorderDeleteFileCompletion)cancelledDeleteCompletion
{
    
    _isPause = NO;
    [self stopBackgroundTask];
    [self stopRecord];
    
    if (self.recordPath) {
        // 删除目录下的文件
        NSFileManager *fileManeger = [NSFileManager defaultManager];
        if ([fileManeger fileExistsAtPath:self.recordPath]) {
            NSError *error = nil;
            [fileManeger removeItemAtPath:self.recordPath error:&error];
            if (error) {
                NSLog(@"error :%@", error.description);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                cancelledDeleteCompletion(error);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                cancelledDeleteCompletion(nil);
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            cancelledDeleteCompletion(nil);
        });
    }
}

- (void)updateMeters
{
    if (!_recorder)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_recorder updateMeters];
        
        self.currentTimeInterval = _recorder.currentTime;
        
        if (!_isPause) {
            float progress = self.currentTimeInterval / self.maxRecordTime * 1.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_recordProgress) {
                    _recordProgress(progress);
                }
            });
        }
        
        float peakPower = [_recorder averagePowerForChannel:0];
        double ALPHA = 0.015;
        double peakPowerForChannel = pow(10, (ALPHA * peakPower));
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新扬声器
            if (_peakPowerForChannel) {
                _peakPowerForChannel(peakPowerForChannel);
            }
        });
        
        if (self.currentTimeInterval > self.maxRecordTime) {
            [self stopRecord];
            dispatch_async(dispatch_get_main_queue(), ^{
                _maxTimeStopRecorderCompletion();
            });
        }
    });
}

- (void)getVoiceDuration:(NSString *)recordPath
{
    NSError *error = nil;
    AVAudioPlayer *play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:recordPath] error:&error];
    if (error) {
        NSLog(@"recordPath：%@ error：%@", recordPath, error);
        self.recordDuration = @"";
    } else {
        NSLog(@"时长:%f", play.duration);
        self.recordDuration = [NSString stringWithFormat:@"%.1f", play.duration];
    }
}


@end
