//
//  CCSystemSound.h
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


/*
 
 音频文件必须在CAF格式
 
 //震动
 [CCSystemSound soundWithID:kSystemSoundID_Vibrate];
 
 play once
 [[CCSystemSound soundWithName:@"ping"] play];
 
 schedule repeated playback
 soundID = [[CCSystemSound soundWithName:@"ping"] scheduleRepeatWithInterval:5];
 
 schedule playback in delta time
 soundID = [[CCSystemSound soundWithName:@"ping"] schedulePlayInInterval:5];
 
 schedule playback at specified date
 soundID = [[CCSystemSound soundWithName:@"ping"] schedulePlayAtDate:date];
 
 unschedule
 [AKSystemSound unscheduleSoundID:soundID];
 
 */

#import <Foundation/Foundation.h>

typedef NSInteger CCSystemSoundID;

@interface CCSystemSound : NSObject

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  CCSystemSound使用音频服务API来打短的警报声音。这些音频文件必须在CAF格式。
 *
 *  @param name 文件名
 */
- (instancetype)initWithName:(NSString *)name;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  初始化声音
 *
 *  @param path 声音路径
 */
- (instancetype)initWithPath:(NSString *)path;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  播放的声音手动一次
 */
- (void)play;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  重复播放
 *
 *  @param interval 间隔秒
 */
- (CCSystemSoundID)scheduleRepeatWithInterval:(NSTimeInterval)interval;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  相隔播放
 *
 *  @param delta 相隔时间
 */
- (CCSystemSoundID)schedulePlayInInterval:(NSTimeInterval)delta;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  计划时间播放
 *
 *  @param date 时间
 */
- (CCSystemSoundID)schedulePlayAtDate:(NSDate *)date;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  播放系统声音
 *
 *  @param inSystemSoundID 系统对应ID
 */
+ (void)soundWithID:(CCSystemSoundID)inSystemSoundID;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  解析文件名
 *
 *  @param fileName 文件名
 *
 *  @return 返回系统ID
 */
+ (CCSystemSoundID)analysisWithFileNameSystemSoundID:(NSString *)fileName;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  解析路
 *
 *  @param path 路径
 *
 *  @return 返回系统ID
 */
+ (CCSystemSoundID)analysisWithPathSystemSoundID:(NSString *)path;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  初始化播放
 *
 *  @param name 文件名
 */
+ (CCSystemSound *)soundWithName:(NSString *)name;

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  取消播放
 *
 *  @param soundID 声音ID 
 */
+ (void)unscheduleSoundID:(CCSystemSoundID)soundID;

@end
