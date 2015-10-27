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
 *  @author C C, 2015-10-27
 *
 *  @brief  多参数调用
 *
 *  @param selector 函数名
 *
 *  @return 返回函数值
 */
- (id)performSelectors:(SEL)selector withObject:(id)aObject, ...
{
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:selector];
    
    id anObject = nil;
    if (methodSignature){
        
        NSInvocation* invo = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invo setTarget:self];
        [invo setSelector:selector];
        [invo setArgument:&aObject atIndex:2];
        
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
        
        [invo invoke];
        
        if (methodSignature.methodReturnLength)
            [invo getReturnValue:&anObject];
    }
    
    return anObject;
}

@end
