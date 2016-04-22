//
//  NSObject+CCProperties.h
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
#import "CCViewProtocol.h"
#import "CCViewModelProtocol.h"
#import "CCViewMangerProtocol.h"
#import "CCMediator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  ViewModelBlock
 */
typedef _Nonnull id (^ViewModelBlock)();
/**
 *  ViewMangerInfosBlock
 */
typedef void (^ViewMangerInfosBlock)(NSString *info, NSDictionary *eventDic);
/**
 *  ViewModelInfosBlock
 */
typedef void (^ViewModelInfosBlock)();


@interface NSObject (CCProperties)

/**
 *  viewModelBlock
 */
@property(nonatomic, copy, nonnull) ViewModelBlock viewModelBlock;

/**
 *  获取一个对象的所有属性
 */
- (nullable NSDictionary *)cc_allProperties;

/**
 *  viewMangerDelegate
 */
@property(nullable, nonatomic, weak) id<CCViewMangerProtocol> viewMangerDelegate;

/**
 *  ViewMangerInfosBlock
 */
@property(nonatomic, copy) ViewMangerInfosBlock viewMangerInfosBlock;

/**
 *  viewModelDelegate
 */
@property(nullable, nonatomic, weak) id<CCViewModelProtocol> viewModelDelegate;

/**
 *  ViewModelInfosBlock
 */
@property(nonatomic, copy) ViewModelInfosBlock viewModelInfosBlock;

/**
 *  mediator
 */
@property(nonatomic, strong) CCMediator *cc_mediator;

/**
 *  cc_viewMangerInfos
 */
@property(nonatomic, copy) NSDictionary *cc_viewMangerInfos;

/**
 *  cc_viewModelInfos
 */
@property(nonatomic, copy) NSDictionary *cc_viewModelInfos;

@end

NS_ASSUME_NONNULL_END