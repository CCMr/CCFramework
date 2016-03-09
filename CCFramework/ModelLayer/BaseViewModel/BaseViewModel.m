//
//  BaseViewModel.m
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

#import "BaseViewModel.h"
#import "CCMessagePhotoImageView.h"
#import "CCMessageBubbleHelper.h"

@implementation BaseViewModel

#pragma mark - Public 函数

/**
 *  @author CC, 15-08-20
 *
 *  @brief  传入交互的Block块
 *
 *  @param returnBlock   完成响应回调
 *  @param errorBlock    错误响应函数
 *  @param faiilureBlock 超时或者请求失败响应函数
 *
 *  @since <#1.0#>
 */
- (void)responseWithBlock:(Completion)returnBlock
           WithErrorBlock:(ErrorCodeBlock)errorBlock
         WithFailureBlock:(FailureBlock)failureBlock
{
    self.returnBlock = [returnBlock copy];
    self.returnBlock = [returnBlock copy];
    self.errorBlock = [errorBlock copy];
    self.failureBlock = [failureBlock copy];
}

/**
 *  @author CC, 15-08-20
 *
 *  @brief  获取数据
 *
 *  @since 1.0
 */
- (void)fetchDataSource
{
}

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 分析图片
 *
 *  @param sendMessage 消息体
 */
- (SETextView *)analysisTeletext:(CCMessage *)sendMessage
{
    SETextView *displayTextView = [[SETextView alloc] initWithFrame:CGRectZero];
    displayTextView.textColor = [UIColor colorWithWhite:0.143 alpha:1.000];
    displayTextView.backgroundColor = [UIColor clearColor];
    displayTextView.selectable = NO;
    displayTextView.lineSpacing = 10;
    displayTextView.font = [UIFont systemFontOfSize:16.0f];
    displayTextView.showsEditingMenuAutomatically = NO;
    displayTextView.highlighted = NO;
    
    NSString *text = [[sendMessage text] stringByReplacingOccurrencesOfString:sendMessage.teletextReplaceStr withString:@"\uFFFC"];
    
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\uFFFC" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (int i = 0; i < resultArray.count; i++) {
        
        NSTextCheckingResult *match = [resultArray objectAtIndex:i];
        
        NSString *path = @"";
        if (sendMessage.teletextPath.count && i < sendMessage.teletextPath.count)
            path = [[sendMessage.teletextPath objectAtIndex:i] objectForKey:@"path"];
        
        CGSize size = CGSizeMake(20, 20);
        UIImage *Images = [UIImage imageWithContentsOfFile:path];
        if (Images)
            size = CGSizeMake(Images.size.width < 100 ? Images.size.width : 100, Images.size.height < 100 ? Images.size.height : 100);
        else if ([path rangeOfString:@"http://"].location != NSNotFound) { //网络加载图片时
            size = CGSizeMake(100, 100);
        }
        
        CCMessagePhotoImageView *messagePhotoImageView = [[CCMessagePhotoImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        messagePhotoImageView.imageFilePath = path;
        
        [displayTextView addObject:messagePhotoImageView size:size replaceRange:[match range]];
    }
    
    displayTextView.attributedText = [[CCMessageBubbleHelper sharedMessageBubbleHelper] bubbleAttributtedStringWithText:text];
    
    return displayTextView;
}


- (NSMutableArray *)cc_dataArray
{
    if (!_cc_dataArray) {
        _cc_dataArray = [NSMutableArray array];
    }
    return _cc_dataArray;
}

-(void)cc_viewModelWithGetDataSuccessHandler:(dispatch_block_t)successHandler
{
    
}

@end
