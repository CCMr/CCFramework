//
//  CCPopMenuItem.h
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
#import <UIKit/UIKit.h>

#define kCCMenuTableViewWidth 122
#define kCCMenuTableViewSapcing 7

#define kCCMenuItemViewHeight 36
#define kCCMenuItemViewImageSapcing 15
#define kCCSeparatorLineImageViewHeight 0.5

@interface CCPopMenuItem : NSObject

@property(nonatomic, assign) NSTextAlignment textAlignment;

@property(nonatomic, strong) UIImage *iconImage;

@property(nonatomic, copy) NSString *title;

@property(nonatomic, strong) UIColor *glowColor;

@property(nonatomic, assign) NSInteger index;

@property(nonatomic, copy) NSString *badgeValue;

@property(nonatomic, strong) UIColor *badgeBGColor;

- (instancetype)initWithImage:(UIImage *)iconName
                        title:(NSString *)title;

#pragma mark - 初始话 init 使用于CCPopMenuView

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue
                 BadgeBGColor:(UIColor *)badgeBGColor NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);


+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue
                 BadgeBGColor:(UIColor *)badgeBGColor NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName NS_AVAILABLE_IOS(2_0);

+ (instancetype)itemWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor NS_AVAILABLE_IOS(2_0);

+ (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

+ (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index NS_AVAILABLE_IOS(2_0);

@end
