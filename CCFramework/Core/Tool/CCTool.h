//
//  CCTool.h
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

@interface CCTool : NSObject

/**
 *  @author CC, 2015-12-02
 *  
 *  @brief  获取音频时长
 *
 *  @param recordPath 音频名称
 */
+ (NSString *)obtainVoiceDuration:(NSString *)recordPath;

/**
 *  @author CC, 2015-12-04
 *  
 *  @brief  等比尺寸
 *
 *  @param image 图片
 *  @param size  大小
 */
+ (CGRect)neededSizeForPhoto:(UIImage *)image
                        Size:(CGSize)size;

/**
 *  @author CC, 2015-12-04
 *  
 *  @brief  等比修改图片
 *
 *  @param image 图片
 *  @param size  等比尺寸
 */
+ (UIImage *)scale:(UIImage *)image
              Size:(CGSize)size;


@end
