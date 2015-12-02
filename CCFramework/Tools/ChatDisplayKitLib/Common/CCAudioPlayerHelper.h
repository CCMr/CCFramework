//
//  CCAudioPlayerHelper.h
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
#import <AVFoundation/AVAudioPlayer.h>

@protocol CCAudioPlayerHelperDelegate <NSObject>

@optional
- (void)didAudioPlayerBeginPlay:(AVAudioPlayer *)audioPlayer;
- (void)didAudioPlayerStopPlay:(AVAudioPlayer *)audioPlayer;
- (void)didAudioPlayerPausePlay:(AVAudioPlayer *)audioPlayer;

@end

@interface CCAudioPlayerHelper : NSObject <AVAudioPlayerDelegate>

@property(nonatomic, strong) AVAudioPlayer *player;

@property(nonatomic, copy) NSString *playingFileName;

@property(nonatomic, copy) NSString *dFileName;

@property(nonatomic, assign) id<CCAudioPlayerHelperDelegate> delegate;

@property(nonatomic, strong) NSIndexPath *playingIndexPathInFeedList; //给动态列表用

+ (id)shareInstance;

- (AVAudioPlayer *)player;
- (BOOL)isPlaying;

/**
 *  @author CC, 2015-12-02
 *  
 *  @brief  网络获取缓存播放
 *
 *  @param ptah 请求地址
 */
- (void)downloadManagerAudioWithFileName:(NSString *)ptah
                                Complete:(void (^)(NSString *path))complete;

- (void)managerAudioWithFileName:(NSString *)amrName
                          toPlay:(BOOL)toPlay;

- (void)pausePlayingAudio; //暂停
- (void)stopAudio;         //停止

@end
