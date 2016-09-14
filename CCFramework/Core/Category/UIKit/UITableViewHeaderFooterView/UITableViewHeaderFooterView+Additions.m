//
//  UITableViewHeaderFooterView+Additions.m
//  CCFramework
//
//  Created by CC on 16/9/8.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "UITableViewHeaderFooterView+Additions.h"
#import <objc/runtime.h>

@implementation UITableViewHeaderFooterView (Additions)

static inline void AutomaticWritingSwizzleSelector(Class class, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AutomaticWritingSwizzleSelector([self class], @selector(layoutSubviews), @selector(cc_layoutSubviews));
    });
}

- (void)cc_layoutSubviews
{
    [self cc_layoutSubviews];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];

    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([NSStringFromClass([obj class]) isEqualToString:@"_UITableViewHeaderFooterViewBackground"]){
            if (self.backgroundViewColor || self.backgroundImage) {
                UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:obj.bounds];
                backgroundImageView.backgroundColor = [UIColor clearColor];
                if (self.backgroundImage)
                    backgroundImageView.image = self.backgroundImage;

                if (self.backgroundViewColor)
                    backgroundImageView.backgroundColor = self.backgroundViewColor;

                [obj addSubview:backgroundImageView];
            }
        }
    }];
}

#pragma mark :. getset
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    objc_setAssociatedObject(self, @selector(backgroundImage), backgroundImage, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage *)backgroundImage
{
    return objc_getAssociatedObject(self, @selector(backgroundImage));
}

- (void)setBackgroundViewColor:(UIColor *)backgroundViewColor
{
    objc_setAssociatedObject(self, @selector(backgroundViewColor), backgroundViewColor, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor *)backgroundViewColor
{
    return objc_getAssociatedObject(self, @selector(backgroundViewColor));
}

- (void)setCc_dataSources:(id)cc_dataSources
{
    objc_setAssociatedObject(self, @selector(cc_dataSources), cc_dataSources, OBJC_ASSOCIATION_RETAIN);
}

- (id)cc_dataSources
{
    return objc_getAssociatedObject(self, @selector(cc_dataSources));
}

- (void)setCc_Section:(NSInteger)cc_Section
{
    objc_setAssociatedObject(self, @selector(cc_indexPath), @(cc_Section), OBJC_ASSOCIATION_RETAIN);
}

- (NSInteger)cc_Section
{
    return objc_getAssociatedObject(self, @selector(cc_Section));
}

- (void)cc_headerFooterWillDisplayWithModel:(id)cModel
                                    section:(NSInteger)section
{
    // Rewrite this func in SubClass !
}

@end
