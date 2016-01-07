//
//  CCSystemSound.m
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

#import "CCSystemSound.h"
#import <AudioToolbox/AudioToolbox.h>


// Notifications
NSString *const CCSystemSoundsWillPlayNotification = @"CCSystemSoundsWillPlayNotification";
NSString *const CCSystemSoundsDidPlayNotification = @"CCSystemSoundsDidPlayNotification";

NSString *const CCSystemSoundWillPlayNotification = @"CCSystemSoundWillPlayNotification";
NSString *const CCSystemSoundDidPlayNotification = @"CCSystemSoundDidPlayNotification";

// Internal keys
NSString *const CCSystemSoundKey = @"CCSystemSoundKey";
NSString *const CCSystemSoundContinuesKey = @"CCSystemSoundContinuesKey";

typedef NS_ENUM(NSInteger, CCSystemSoundType) {
    /** 系统无效声音ID */
    CCSystemSoundInvalidID = 0
};

// 回拨声明
void CCSystemSoundCompleted(SystemSoundID ssID, void *clientData);

@interface CCSystemSound ()

@property(nonatomic, assign) SystemSoundID soundID;

@property(nonatomic, assign) unsigned int playing;


- (void)soundCompleted;
+ (CCSystemSoundID)scheduleTimer:(NSTimer *)timer;
+ (void)soundWillPlay:(CCSystemSound *)sound;
+ (void)soundDidPlay:(CCSystemSound *)sound;

@end

// 回拨
void CCSystemSoundCompleted(SystemSoundID ssID, void *clientData)
{
    CCSystemSound *sound = (__bridge CCSystemSound *)clientData;
    if ([sound isKindOfClass:[CCSystemSound class]])
        [sound soundCompleted];
}

@implementation CCSystemSound

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  CCSystemSound使用音频服务API来打短的警报声音。这些音频文件必须在CAF格式。
 *
 *  @param name 文件名
 */
- (instancetype)initWithName:(NSString *)name
{
    NSParameterAssert(name);
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:name
                                                          ofType:([[name pathExtension] length] ? nil : @"caf")];
    self = [self initWithPath:soundPath];
    return self;
}

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  初始化声音
 *
 *  @param path 声音路径
 */
- (instancetype)initWithPath:(NSString *)path
{
    NSParameterAssert(path);
    if ((self = [super init])) {
        NSURL *URL = [NSURL fileURLWithPath:path];
        if ((AudioServicesCreateSystemSoundID((__bridge CFURLRef)URL, &_soundID)) != noErr) {
            NSLog(@"could not load system sound: %@", path);
            return nil;
        }
    }
    return self;
}

+ (CCSystemSound *)soundWithName:(NSString *)name
{
    static NSMutableDictionary *sNamedSounds = nil;
    CCSystemSound *sound = nil;
    @synchronized([CCSystemSound class])
    {
        if (sNamedSounds == nil)
            sNamedSounds = [[NSMutableDictionary alloc] init];
        sound = [sNamedSounds objectForKey:name];
        if (!sound) {
            sound = [[CCSystemSound alloc] initWithName:name];
            [sNamedSounds setObject:sound forKey:name];
        }
    }
    return sound;
}

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  播放系统声音
 *
 *  @param inSystemSoundID 系统对应ID
 */
+ (void)soundWithID:(CCSystemSoundID)inSystemSoundID
{
    AudioServicesPlaySystemSound((unsigned int)inSystemSoundID);
}

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  解析文件名
 *
 *  @param fileName 文件名
 *
 *  @return 返回系统ID
 */
+ (CCSystemSoundID)analysisWithFileNameSystemSoundID:(NSString *)fileName
{
    NSParameterAssert(fileName);
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName
                                                          ofType:([[fileName pathExtension] length] ? nil : @"caf")];
    return [self analysisWithPathSystemSoundID:soundPath];
}

/**
 *  @author CC, 2016-01-07
 *  
 *  @brief  解析路
 *
 *  @param path 路径
 *
 *  @return 返回系统ID
 */
+ (CCSystemSoundID)analysisWithPathSystemSoundID:(NSString *)path
{
    NSParameterAssert(path);
    
    SystemSoundID soundID;
    NSURL *URL = [NSURL fileURLWithPath:path];
    if ((AudioServicesCreateSystemSoundID((__bridge CFURLRef)URL, &soundID)) != noErr)
        NSLog(@"could not load system sound: %@", path);
    
    return soundID;
}

- (void)play
{
    @synchronized(self)
    {
        if (_playing) //如果还没有打，保留（防止-dealloc），并设置声音完成回调
            AudioServicesAddSystemSoundCompletion(_soundID, NULL, NULL, CCSystemSoundCompleted, (__bridge void *_Nullable)(self));
        _playing++;
        
        [[self class] soundWillPlay:self];
        AudioServicesPlaySystemSound(_soundID);
    }
}

static unsigned int kSoundsPlaying = 0;

+ (void)soundWillPlay:(CCSystemSound *)sound
{
    @synchronized([CCSystemSound class])
    {
        // if first sound playing right now, send notification
        if (kSoundsPlaying == 0)
            [[NSNotificationCenter defaultCenter]
             postNotificationName:CCSystemSoundsWillPlayNotification
             object:nil];
        kSoundsPlaying++;
    }
    
    // send notification that specific sound will play
    [[NSNotificationCenter defaultCenter]
     postNotificationName:CCSystemSoundWillPlayNotification
     object:sound];
}

+ (void)soundDidPlay:(CCSystemSound *)sound
{
    // send notification that specific sound did play
    [[NSNotificationCenter defaultCenter]
     postNotificationName:CCSystemSoundDidPlayNotification
     object:sound];
    
    @synchronized([CCSystemSound class])
    {
        kSoundsPlaying--;
        // if this was the last sound, send notification
        if (kSoundsPlaying == 0)
            [[NSNotificationCenter defaultCenter]
             postNotificationName:CCSystemSoundsDidPlayNotification
             object:nil];
    }
}

- (void)soundCompleted
{
    @synchronized(self)
    {
        [[self class] soundDidPlay:self];
        
        _playing--;
        if (_playing == 0) {
            // if we're done playing, release ourselves (retained in -play)
            // and remove completed callback
            AudioServicesRemoveSystemSoundCompletion(_soundID);
        }
    }
}


- (CCSystemSoundID)scheduleRepeatWithInterval:(NSTimeInterval)interval
{
    // the timer retains the sound (self) in the userInfo property (NSDictionary)
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                             target:[self class]
                                           selector:@selector(scheduledTimerFired:)
                                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, CCSystemSoundKey, [NSNumber numberWithBool:YES], CCSystemSoundContinuesKey, nil]
                                            repeats:YES];
    return [[self class] scheduleTimer:timer];
}

- (CCSystemSoundID)schedulePlayInInterval:(NSTimeInterval)interval
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                             target:[self class]
                                           selector:@selector(scheduledTimerFired:)
                                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, CCSystemSoundKey, [NSNumber numberWithBool:NO], CCSystemSoundContinuesKey, nil]
                                            repeats:NO];
    return [[self class] scheduleTimer:timer];
}

- (CCSystemSoundID)schedulePlayAtDate:(NSDate *)date
{
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:date
                                              interval:0
                                                target:[self class]
                                              selector:@selector(scheduledTimerFired:)
                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, CCSystemSoundKey, [NSNumber numberWithBool:NO], CCSystemSoundContinuesKey, nil]
                                               repeats:NO];
    return [[self class] scheduleTimer:timer];
}

static NSMutableDictionary *kScheduledTimers = nil;
static CCSystemSoundID kCurrentSystemSoundID = 0;

+ (CCSystemSoundID)scheduleTimer:(NSTimer *)timer
{
    CCSystemSoundID soundID;
    
    @synchronized([CCSystemSound class])
    {
        // add 1 to the current system sound id counter
        kCurrentSystemSoundID++;
        soundID = kCurrentSystemSoundID;
        
        // add the timer to the schedule timers dictionary
        if (!kScheduledTimers)
            kScheduledTimers = [[NSMutableDictionary alloc] init];
        [kScheduledTimers setObject:timer forKey:[NSString stringWithFormat:@"%zi", soundID]];
        
        // add the timer to the main runloop
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    
    return soundID;
}

+ (CCSystemSoundID)scheduleSound:(CCSystemSound *)sound
                        interval:(NSTimeInterval)interval
{
    CCSystemSoundID soundID;
    
    @synchronized([CCSystemSound class])
    {
        // add 1 to the current system sound id pointer
        kCurrentSystemSoundID++;
        soundID = kCurrentSystemSoundID;
        
        // create the timer, userInfo retains the sound object
        // preveting it from being deallocated while scheduled
        NSTimer *timer = [NSTimer timerWithTimeInterval:interval
                                                 target:self
                                               selector:@selector(scheduledTimerFired:)
                                               userInfo:sound
                                                repeats:YES];
        
        // add the timer to the scheduled timers dictionary
        if (kScheduledTimers == nil)
            kScheduledTimers = [[NSMutableDictionary alloc] init];
        [kScheduledTimers setObject:timer forKey:[NSString stringWithFormat:@"%zi", soundID]];
        
        // add the timer to the main runloop
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    
    return soundID;
}

+ (void)scheduledTimerFired:(NSTimer *)timer
{
    CCSystemSound *sound = [[timer userInfo] objectForKey:CCSystemSoundKey];
    BOOL shouldContinue = [[[timer userInfo] objectForKey:CCSystemSoundContinuesKey] boolValue];
    
    if (sound)
        [sound play];
    
    if (!shouldContinue) {
        @synchronized([CCSystemSound class])
        {
            if ([timer isValid]) {
                [timer invalidate];
                
                NSString *key = [[kScheduledTimers allKeysForObject:timer] lastObject];
                if (key)
                    [self unscheduleSoundID:[key intValue]];
            }
        }
    }
}

+ (void)unscheduleSoundID:(CCSystemSoundID)soundID
{
    if (soundID == CCSystemSoundInvalidID)
        return;
    
    @synchronized([CCSystemSound class])
    {
        NSString *key = [NSString stringWithFormat:@"%zi", soundID];
        NSTimer *timer = [kScheduledTimers objectForKey:key];
        if (timer) {
            [timer invalidate];
            [kScheduledTimers removeObjectForKey:key];
        }
    }
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(_soundID);
}

@end
