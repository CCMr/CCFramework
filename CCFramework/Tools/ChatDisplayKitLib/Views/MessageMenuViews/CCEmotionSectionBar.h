//
//  CCEmotionSectionBar.h
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
#import "CCEmotionManager.h"

@protocol CCEmotionSectionBarDelegate <NSObject>

/**
 *  点击某一类gif表情的回调方法
 *
 *  @param emotionManager 被点击的管理表情Model对象
 *  @param section        被点击的位置
 */
- (void)didSelecteEmotionManager:(CCEmotionManager *)emotionManager
                       atSection:(NSInteger)section;

@end

@interface CCEmotionSectionBar : UIView

@property(nonatomic, weak) id<CCEmotionSectionBarDelegate> delegate;

/**
 *  数据源
 */
@property(nonatomic, strong) NSArray *emotionManagers;

- (instancetype)initWithFrame:(CGRect)frame
       showEmotionStoreButton:(BOOL)isShowEmotionStoreButtoned;

/**
 *  根据数据源刷新UI布局和数据
 */
- (void)reloadData;

@end
