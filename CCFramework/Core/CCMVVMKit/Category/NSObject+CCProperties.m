//
//  NSObject+CCProperties.m
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

#import "NSObject+CCProperties.h"
#import <objc/runtime.h>

@implementation NSObject (CCProperties)

- (id<CCViewModelProtocol>)viewModelDelegate
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewModelDelegate:(id<CCViewModelProtocol>)viewModelDelegate
{
    objc_setAssociatedObject(self, @selector(viewModelDelegate), viewModelDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<CCViewMangerProtocol>)viewMangerDelegate
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setViewMangerDelegate:(id<CCViewMangerProtocol>)viewMangerDelegate
{
    objc_setAssociatedObject(self, @selector(viewMangerDelegate), viewMangerDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (ViewMangerInfosBlock)viewMangerInfosBlock
{
    return objc_getAssociatedObject(self, @selector(viewMangerInfosBlock));
}

- (void)setViewMangerInfosBlock:(ViewMangerInfosBlock)viewMangerInfosBlock
{
    objc_setAssociatedObject(self, @selector(viewMangerInfosBlock), viewMangerInfosBlock, OBJC_ASSOCIATION_COPY);
}

- (ViewModelInfosBlock)viewModelInfosBlock
{
    return objc_getAssociatedObject(self, @selector(viewModelInfosBlock));
}

- (void)setViewModelInfosBlock:(ViewModelInfosBlock)viewModelInfosBlock
{
    objc_setAssociatedObject(self, @selector(viewModelInfosBlock), viewModelInfosBlock, OBJC_ASSOCIATION_COPY);
}

- (ViewModelBlock)viewModelBlock
{
    return objc_getAssociatedObject(self, @selector(viewModelBlock));
}

- (void)setViewModelBlock:(ViewModelBlock)viewModelBlock
{
    objc_setAssociatedObject(self, @selector(viewModelBlock), viewModelBlock, OBJC_ASSOCIATION_COPY);
}

/**
 *  mediator
 */
- (void)setCc_mediator:(CCMediator *)cc_mediator
{
    objc_setAssociatedObject(self, @selector(cc_mediator), cc_mediator, OBJC_ASSOCIATION_RETAIN);
}
- (CCMediator *)cc_mediator
{
    return objc_getAssociatedObject(self, @selector(cc_mediator));
}

/**
 *  cc_viewMangerInfos
 */
- (void)setCc_viewMangerInfos:(NSDictionary *)cc_viewMangerInfos
{
    objc_setAssociatedObject(self, @selector(cc_viewMangerInfos), cc_viewMangerInfos, OBJC_ASSOCIATION_COPY);
}
- (NSDictionary *)cc_viewMangerInfos
{
    return objc_getAssociatedObject(self, @selector(cc_viewMangerInfos));
}

/**
 *  cc_viewModelInfos
 */
- (void)setCc_viewModelInfos:(NSDictionary *)cc_viewModelInfos
{
    objc_setAssociatedObject(self, @selector(cc_viewModelInfos), cc_viewModelInfos, OBJC_ASSOCIATION_COPY);
}
- (NSDictionary *)cc_viewModelInfos
{
    return objc_getAssociatedObject(self, @selector(cc_viewModelInfos));
}

- (nullable NSDictionary *)cc_allProperties
{
    unsigned int count = 0;
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableDictionary *resultDict = [@{} mutableCopy];
    
    for (NSUInteger i = 0; i < count; i++) {
        
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        id propertyValue = [self valueForKey:name];
        
        if (propertyValue) {
            resultDict[name] = propertyValue;
        } else {
            resultDict[name] = @"字典的key对应的value不能为nil";
        }
    }
    
    free(properties);
    
    return resultDict;
}

@end
