//
//  CCEmotionManager.h
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
#import "CCEmotion.h"

typedef NS_ENUM(NSInteger, CCEmotionType) {
    /** 默认表情 */
    CCEmotionTypedefault = 0,
    /** 小表情 */
    CCEmotionTypeSmall = 1,
};

@interface CCEmotionManager : NSObject

@property(nonatomic, assign) CCEmotionType emotionType;

/**
 *  @author CC, 2015-12-11
 *
 *  @brief  表情名称
 */
@property(nonatomic, copy) NSString *emotionName;

/**
 *  @author CC, 16-08-12
 *
 *  @brief 表情图片
 */
@property(nonatomic, copy) NSString *emotionIcon;

/**
 *  某一类表情的数据源
 */
@property(nonatomic, strong) NSMutableArray *emotions;

/**
 *  @author CC, 2015-12-08
 *
 *  @brief  列
 */
@property(nonatomic, assign) NSInteger section;

/**
 *  @author CC, 2015-12-08
 *
 *  @brief  行
 */
@property(nonatomic, assign) NSInteger row;

@end
