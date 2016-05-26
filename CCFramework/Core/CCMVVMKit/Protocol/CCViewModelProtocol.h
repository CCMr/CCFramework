//
//  CCViewModelProtocol.h
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

/**
 *  将自己的信息返回给ViewManger的block
 */
typedef void (^ViewMangerInfosBlock)(NSString *info, NSDictionary *eventDic);

/**
 *  @author CC, 16-04-20
 *  
 *  @brief  将自己事件处理通过block方式交互ViewManger
 */
typedef void (^ViewModelEventsBlock)(NSString *info, NSDictionary *eventDic);

@protocol CCViewModelProtocol <NSObject>

@optional

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 中介者传值
 */
- (void)cc_notice;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 返回指定viewModel的所引用的控制器
 *
 *  @param viewController 控制器
 */
- (void)cc_viewModelWithViewController:(UIViewController *)viewController;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 传递模型给view
 *
 *  @param modelBlock 数据模型
 */
- (void)cc_viewModelWithModelBlcok:(void (^)(id model))modelBlock;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 处理ViewMangerInfosBlock
 *
 *  @param infos 传递值
 */
- (ViewMangerInfosBlock)cc_viewModelWithViewMangerBlockOfInfos:(NSDictionary *)infos;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 将viewModel中的信息通过代理传递给ViewManger
 *
 *  @param viewModel viewModel自己
 *  @param infos     描述信息
 */
- (void)cc_viewModel:(id)viewModel withInfos:(NSDictionary *)infos;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 将ViewModel事件传递到viewManger
 *
 *  @param info     描述信息
 *  @param eventDic 传递参数
 */
- (void)cc_viewModelEvent:(NSString *)info
                withEvent:(NSDictionary *)eventDic;

/**
 *  @author CC, 16-05-06
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 */
- (void)cc_viewModelWithGetDataSuccessHandler;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 *
 *  @param successHandler 回调函数
 *                        一般用于请求返回数据
 */
- (void)cc_viewModelWithGetDataSuccessHandler:(void (^)(NSArray *array))successHandler;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 *
 *  @param parameters 传递参数
 */
- (void)cc_viewModelWithGetData:(NSDictionary *)parameters;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 *
 *  @param parameters     传递参数
 *  @param successHandler 回调函数
 *                        一般用于请求返回数据
 */
- (void)cc_viewModelWithGetData:(NSDictionary *)parameters
                 SuccessHandler:(void (^)(NSArray *ary))successHandler;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 *
 *  @param successHandler 回调函数
 *                        一般用于请求返回结果告知
 */
- (void)cc_viewModelWithDataSuccessHandler:(void (^)(BOOL isSuccess, NSString *info))successHandler;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 *
 *  @param parameters 传递参数
 */
- (void)cc_viewModelWithData:(NSDictionary *)parameters;

/**
 *  @author CC, 16-04-20
 *  
 *  @brief 视图模型获取数据成功处理
 *         用来判断是否加载成功,方便外部根据不同需求处理 (外部使用)
 *
 *  @param parameters     传递参数
 *  @param successHandler 回调函数
 *                        一般用于请求返回结果告知
 */
- (void)cc_viewModelWithData:(NSDictionary *)parameters 
              SuccessHandler:(void (^)(BOOL isSuccess, NSString *info))successHandler;

/**
 *  @author CC, 16-04-29
 *  
 *  @brief ViewModel传递事件到ViewController
 */
- (void)cc_viewModleWithEventHandle:(ViewModelEventsBlock)eventHandle;

/**
 *  @author CC, 16-05-25
 *  
 *  @brief  获取model数据
 *
 *  @param info      描述信息
 *  @param obtainDic 传递参数
 */
-(id)cc_viewModelObtainData:(NSString *)info 
                 withObtain:(NSDictionary *)obtainDic;

@end
