//
//  NSObject+Additions.m
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

#import "NSObject+Additions.h"

@implementation NSObject (Additions)

/**
 *  @author C C, 2015-11-12
 *
 *  @brief  用于初始化
 *
 *  @param methodName 初始化函数名
 *
 *  @return 返回初始化独享
 */
+ (id)InitDefaultMethod:(NSString *)methodName
{
    SEL methodSEL = NSSelectorFromString(methodName);
    NSObject *valueObj = nil;
    if ([self respondsToSelector:methodSEL]) {
        NSMethodSignature *methodSignature = [self methodSignatureForSelector:methodSEL];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self];
        [invocation setSelector:methodSEL];
        [invocation invoke];
        [invocation getReturnValue:&valueObj];
    }
    return valueObj;
}

/**
 *  @author C C, 2015-10-27
 *
 *  @brief  多参数调用
 *
 *  @param selector 函数名
 *
 *  @return 返回函数值
 */
- (id)performSelectors:(NSString *)methodName withObject:(id)aObject, ...
{
    SEL methodSEL = NSSelectorFromString(methodName);
    
    //声明返回值变量
    id anObject = nil;
    if ([self respondsToSelector:methodSEL]) {
        //方法签名类，需要被调用消息所属的类self ,被调用的消息invokeMethod:
        NSMethodSignature *methodSignature = [self methodSignatureForSelector:methodSEL];
        
        //根据方法签名创建一个NSInvocation
        NSInvocation *invo = [NSInvocation invocationWithMethodSignature:methodSignature];
        if (methodSignature) {
            //设置调用者也就是AsynInvoked的实例对象，在这里我用self替代
            [invo setTarget:self];
            //设置被调用的消息
            [invo setSelector:methodSEL];
            //如果此消息有参数需要传入，那么就需要按照如下方法进行参数设置，需要注意的是，atIndex的下标必须从2开始。原因为：0 1 两个参数已经被target 和selector占用
            [invo setArgument:&aObject atIndex:2];
            //retain 所有参数，防止参数被释放dealloc
            [invo retainArguments];
            
            va_list arguments;
            id eachObject;
            if (aObject) {
                va_start(arguments, aObject);
                
                NSInteger index = 3;
                while ((eachObject = va_arg(arguments, id))) {
                    [invo setArgument:&eachObject atIndex:index];
                    index++;
                }
                va_end(arguments);
            }
        }
        //消息调用
        [invo invoke];
        
        //获得返回值类型
        const char *returnType = methodSignature.methodReturnType;
        
        //如果没有返回值，也就是消息声明为void，那么returnValue=nil
        if (!strcmp(returnType, @encode(void))) {
            anObject = nil;
        }
        //如果返回值为对象，那么为变量赋值
        else if (!strcmp(returnType, @encode(id))) {
            [invo getReturnValue:&anObject];
        } else {
            //如果返回值为普通类型NSInteger  BOOL
            //返回值长度
            NSUInteger length = [methodSignature methodReturnLength];
            //根据长度申请内存
            void *buffer = (void *)malloc(length);
            //为变量赋值
            [invo getReturnValue:buffer];
            //以下代码为参考:具体地址我忘记了，等我找到后补上，(很对不起原作者)
            if (!strcmp(returnType, @encode(BOOL))) {
                anObject = [NSNumber numberWithBool:*((BOOL *)buffer)];
            } else if (!strcmp(returnType, @encode(NSInteger))) {
                anObject = [NSNumber numberWithInteger:*((NSInteger *)buffer)];
            }
            anObject = [NSValue valueWithBytes:buffer objCType:returnType];
        }
    }
    return anObject;
}

@end
