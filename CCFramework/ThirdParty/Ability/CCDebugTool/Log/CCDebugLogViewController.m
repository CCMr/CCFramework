//
//  CCDebugLogViewController.m
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

#import "CCDebugLogViewController.h"
#import <asl.h>
#include <stdio.h>
#import "CCDebugTool.h"

@interface CCDebugLogModel : NSObject

@property(nonatomic, strong) NSDate *date;
@property(nonatomic, copy) NSString *sender;
@property(nonatomic, copy) NSString *messageText;
@property(nonatomic, assign) long long messageID;

@end

@implementation CCDebugLogModel

+ (instancetype)messageFromASLMessage:(aslmsg)aslMessage
{
    CCDebugLogModel *logMessage = [[CCDebugLogModel alloc] init];
    
    const char *timestamp = asl_get(aslMessage, ASL_KEY_TIME);
    if (timestamp) {
        NSTimeInterval timeInterval = [@(timestamp) integerValue];
        const char *nanoseconds = asl_get(aslMessage, ASL_KEY_TIME_NSEC);
        if (nanoseconds) {
            timeInterval += [@(nanoseconds) doubleValue] / NSEC_PER_SEC;
        }
        logMessage.date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    }
    
    const char *sender = asl_get(aslMessage, ASL_KEY_SENDER);
    if (sender) {
        logMessage.sender = @(sender);
    }
    
    const char *messageText = asl_get(aslMessage, ASL_KEY_MSG);
    if (messageText) {
        NSString *format = @(messageText);
        format = ({
            format = [format stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
            format = [format stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            format = [format stringByReplacingOccurrencesOfString:@"\\\\U" withString:@"\\U"];
            format = [[@"\"" stringByAppendingString:format] stringByAppendingString:@"\""];
            format = [NSPropertyListSerialization propertyListFromData:[format dataUsingEncoding:NSUTF8StringEncoding]
                                                      mutabilityOption:NSPropertyListImmutable
                                                                format:NULL
                                                      errorDescription:NULL];
            format = [format stringByReplacingOccurrencesOfString:@"\0" withString:@""];
            [format stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
        });
        logMessage.messageText = format;
    }
    
    const char *messageID = asl_get(aslMessage, ASL_KEY_MSG_ID);
    if (messageID) {
        logMessage.messageID = [@(messageID) longLongValue];
    }
    
    return logMessage;
}

+ (NSString *)stringFormatFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    
    return [formatter stringFromDate:date];
}

@end

@interface CCDebugLogViewController ()

@property(nonatomic, weak) UITextView *logTextView;

@end

@implementation CCDebugLogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControl];
}

- (void)initNavigation
{
    self.title = @"LOG";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(dismissViewController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshLogs)];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initControl
{
    UITextView *logTextView = [[UITextView alloc] init];
    [logTextView setEditable:NO];
    logTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    logTextView.frame = self.view.bounds;
    [self.view addSubview:_logTextView = logTextView];
    
    [self refreshLogs];
}

- (void)refreshLogs
{
    __weak UITextView *weakTxt = self.logTextView;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray* arr = [self logs];
        if (arr.count > 0) {
            NSMutableAttributedString* string = [[NSMutableAttributedString alloc] init];
            for (CCDebugLogModel* model in arr) {
                NSString* date = [CCDebugLogModel stringFormatFromDate:model.date];
                NSMutableAttributedString* att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@：",date]];
                [att addAttribute:NSForegroundColorAttributeName value:[CCDebugTool manager].mainColor range:NSMakeRange(0, att.string.length)];
                
                NSMutableAttributedString* att2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n",model.messageText]];
                [att2 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, att2.string.length)];
                
                [string appendAttributedString:att];
                [string appendAttributedString:att2];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakTxt.attributedText = string;
            });
        }
    });
}

- (NSArray *)logs
{
    asl_object_t query = asl_new(ASL_TYPE_QUERY);
    char pidStr[100];
    sprintf(pidStr, "%d", [[NSProcessInfo processInfo] processIdentifier]);
    asl_set_query(query, ASL_KEY_PID, pidStr, ASL_QUERY_OP_EQUAL);
    
    //this is too slow!
    aslresponse response = asl_search(NULL, query);
    NSUInteger numberOfLogs = [CCDebugTool manager].maxLogsCount;
    NSMutableArray *logMessages = [NSMutableArray arrayWithCapacity:numberOfLogs];
    size_t count = asl_count(response);
    for (int i = 0; i < numberOfLogs; i++) {
        aslmsg msg = asl_get_index(response, count - i - 1);
        if (msg != NULL) {
            CCDebugLogModel *model = [CCDebugLogModel messageFromASLMessage:msg];
            [logMessages addObject:model];
        } else
            break;
    }
    asl_release(response);
    return logMessages;
}

@end
