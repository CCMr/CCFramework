//
//  CCAudioPlayerHelper.m
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


#import "CCAudioPlayerHelper.h"
#import "CCVoiceCommonHelper.h"
#import "VoiceConverter.h"
#import <UIKit/UIKit.h>

@implementation CCAudioPlayerHelper

#pragma mark - Public Methed

- (void)managerAudioWithFileName:(NSString *)amrName toPlay:(BOOL)toPlay
{
    if (toPlay) {
        [self playAudioWithFileName:amrName];
    } else {
        [self pausePlayingAudio];
    }
}

//暂停
- (void)pausePlayingAudio
{
    if (_player) {
        [_player pause];
        if ([self.delegate respondsToSelector:@selector(didAudioPlayerPausePlay:)]) {
            [self.delegate didAudioPlayerPausePlay:_player];
        }
    }
}

- (void)stopAudio
{
    [self setPlayingFileName:@""];
    [self setPlayingIndexPathInFeedList:nil];
    if (_player && _player.isPlaying) {
        [_player stop];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
        [self.delegate didAudioPlayerStopPlay:_player];
    }
}

#pragma mark - action

//播放转换后wav
- (void)playAudioWithFileName:(NSString *)fileName
{
    if (fileName.length > 0) {
        
        //不随着静音键和屏幕关闭而静音。code by Aevit
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        if (_playingFileName && [fileName isEqualToString:_playingFileName]) { //上次播放的录音
            if (_player) {
                [_player play];
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
                    [self.delegate didAudioPlayerBeginPlay:_player];
                }
            }
        } else { //不是上次播放的录音
            if (_player) {
                [_player stop];
                self.player = nil;
            }
            
            NSString *path = [CCVoiceCommonHelper getPathByFileName:fileName ofType:@"wav"];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:path]) {
                NSString *wavName = [CCVoiceCommonHelper getPathByFileName:[path stringByAppendingString:@"amrToWav"] ofType:@"wav"];
                if ([fileManager fileExistsAtPath:wavName]) {
                    path = wavName;
                } else {
                    [self convertAmrToWav:fileName];
                }
            }
            
            AVAudioPlayer *pl = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
            pl.delegate = self;
            [pl play];
            self.player = pl;
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            if ([self.delegate respondsToSelector:@selector(didAudioPlayerBeginPlay:)]) {
                [self.delegate didAudioPlayerBeginPlay:_player];
            }
        }
        self.playingFileName = fileName;
    }
}

#pragma mark - amr转wav

- (void)convertAmrToWav:(NSString *)amrName
{
    if (amrName.length > 0) {
        NSString *wavName = [amrName stringByReplacingOccurrencesOfString:@"wavToAmr" withString:@"amrToWav"]; // [amrName stringByAppendingString:@"amrToWav"];
        //转格式
        [VoiceConverter amrToWav:[CCVoiceCommonHelper getPathByFileName:amrName ofType:@"amr"] wavSavePath:[CCVoiceCommonHelper getPathByFileName:wavName ofType:@"wav"]];
    }
}


#pragma mark - Getter

- (AVAudioPlayer *)player
{
    return _player;
}

- (BOOL)isPlaying
{
    if (!_player) {
        return NO;
    }
    return _player.isPlaying;
}

#pragma mark - Setter

- (void)setDelegate:(id<CCAudioPlayerHelperDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        
        if (_delegate == nil) {
            [self stopAudio];
        }
    }
}

#pragma mark - Life Cycle

+ (id)shareInstance
{
    static CCAudioPlayerHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CCAudioPlayerHelper alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self changeProximityMonitorEnableState:YES];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    return self;
}

- (void)dealloc
{
    [self changeProximityMonitorEnableState:NO];
}

#pragma mark - audio delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopAudio];
    if ([self.delegate respondsToSelector:@selector(didAudioPlayerStopPlay:)]) {
        [self.delegate didAudioPlayerStopPlay:_player];
    }
}

#pragma mark - 近距离传感器

- (void)changeProximityMonitorEnableState:(BOOL)enable
{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        if (enable) {
            
            //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
            
        } else {
            
            //删除近距离事件监听
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

- (void)sensorStateChange:(NSNotificationCenter *)notification
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        //黑屏
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    } else {
        //没黑屏幕
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_player || !_player.isPlaying) {
            //没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}


@end
