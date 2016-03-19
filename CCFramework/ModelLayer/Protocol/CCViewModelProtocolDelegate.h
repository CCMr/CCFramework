//
//  CCViewModelProtocolDelegate.h
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

#ifndef CCViewModelProtocolDelegate_h
#define CCViewModelProtocolDelegate_h

@protocol CCViewModelProtocolDelegate <NSObject>

@optional

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 返回指定indexPath的item
 *
 *  @param indexPath 下标
 */
- (instancetype)cc_viewModelWithIndexPath:(NSIndexPath *)indexPath;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 每组中显示多少行 (用于tableView)
 *
 *  @param section 分组下标
 */
- (NSUInteger)cc_viewModelWithNumberOfRowsInSection:(NSUInteger)section;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 每组中显示多少个 (用于collectionView)
 *
 *  @param section 分组下标
 */
- (NSUInteger)cc_viewModelWithNumberOfItemsInSection:(NSUInteger)section;

/**
 *  @author CC, 16-03-09
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 *
 *  @param successHandler 回调函数
 */
- (void)cc_viewModelWithGetDataSuccessHandler:(void (^)(NSArray *array))successHandler;
- (void)cc_viewModelWithGetData:(NSDictionary *)parameters SuccessHandler:(void (^)(NSArray *))successHandler;

- (void)cc_viewModelWithDataSuccessHandler:(void (^)())successHandler;
- (void)cc_viewModelWithData:(NSDictionary *)parameters SuccessHandler:(void (^)())successHandler;

@end

#endif /* CCViewModelProtocolDelegate_h */
