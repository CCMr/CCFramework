//
//  CCVoiceRecordHelper.h
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

#define kVoiceRecorderTotalTime 60.0

typedef BOOL (^CCPrepareRecorderCompletion)();
typedef void (^CCStartRecorderCompletion)();
typedef void (^CCStopRecorderCompletion)();
typedef void (^CCPauseRecorderCompletion)();
typedef void (^CCResumeRecorderCompletion)();
typedef void (^CCCancellRecorderDeleteFileCompletion)();
typedef void (^CCRecordProgress)(float progress);
typedef void (^CCPeakPowerForChannel)(float peakPowerForChannel);

@interface CCVoiceRecordHelper : NSObject

@property(nonatomic, copy) CCStopRecorderCompletion maxTimeStopRecorderCompletion;
@property(nonatomic, copy) CCRecordProgress recordProgress;
@property(nonatomic, copy) CCPeakPowerForChannel peakPowerForChannel;
@property(nonatomic, copy, readonly) NSString *recordPath;
@property(nonatomic, copy) NSString *recordDuration;
@property(nonatomic) float maxRecordTime; // 默认 60秒为最大
@property(nonatomic, readonly) NSTimeInterval currentTimeInterval;

- (void)prepareRecordingWithPath:(NSString *)path prepareRecorderCompletion:(CCPrepareRecorderCompletion)prepareRecorderCompletion;
- (void)startRecordingWithStartRecorderCompletion:(CCStartRecorderCompletion)startRecorderCompletion;
- (void)pauseRecordingWithPauseRecorderCompletion:(CCPauseRecorderCompletion)pauseRecorderCompletion;
- (void)resumeRecordingWithResumeRecorderCompletion:(CCResumeRecorderCompletion)resumeRecorderCompletion;
- (void)stopRecordingWithStopRecorderCompletion:(CCStopRecorderCompletion)stopRecorderCompletion;
- (void)cancelledDeleteWithCompletion:(CCCancellRecorderDeleteFileCompletion)cancelledDeleteCompletion;


@end
