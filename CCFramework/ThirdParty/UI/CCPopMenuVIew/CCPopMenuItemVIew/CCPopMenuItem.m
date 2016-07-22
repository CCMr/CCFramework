//
//  CCPopMenuItem.m
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

#import "CCPopMenuItem.h"

@implementation CCPopMenuItem

- (instancetype)initWithImage:(UIImage *)iconName
                        title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.iconImage = iconName;
        self.title = title;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)iconName
                        title:(NSString *)title
                   BadgeValue:(NSString *)badgeValue
                 BadgeBGColor:(UIColor *)badgeBGColor
{
    self = [super init];
    if (self) {
        self.iconImage = iconName;
        self.title = title;
        self.badgeValue = badgeValue;
        self.badgeBGColor = badgeBGColor;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue
{
    return [self initWithTitle:title
                      iconName:iconName
                    BadgeValue:badgeValue
                  BadgeBGColor:[UIColor redColor]];
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue
                 BadgeBGColor:(UIColor *)badgeBGColor
{
    self = [super init];
    if (self) {
        self.iconImage = iconName;
        self.title = title;
        self.badgeValue = badgeValue;
        self.badgeBGColor = badgeBGColor;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
{
    return [self initWithTitle:title
                 TextAlignment:NSTextAlignmentLeft
                      iconName:iconName];
}

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
{
    return [self initWithTitle:title
                 TextAlignment:textAlignment
                      iconName:@""];
}

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
{
    return [self initWithTitle:title
                 TextAlignment:textAlignment
                      iconName:iconName
                     glowColor:nil];
}

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
{
    return [self initWithTitle:title
                 TextAlignment:textAlignment
                      iconName:iconName
                     glowColor:glowColor
                         index:-1];
}

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                        index:(NSInteger)index
{
    return [self initWithTitle:title
                 TextAlignment:textAlignment
                      iconName:iconName
                     glowColor:nil
                         index:index];
}

- (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index
{
    if (self = [super init]) {
        self.title = title;
        self.iconImage = [UIImage imageNamed:iconName];
        self.glowColor = glowColor;
        self.index = index;
        self.textAlignment = textAlignment;
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
{
    return [self itemWithTitle:title
                 TextAlignment:NSTextAlignmentLeft
                      iconName:iconName];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue
{
    return [self itemWithTitle:title
                      iconName:iconName
                    BadgeValue:badgeValue
                  BadgeBGColor:[UIColor redColor]];
}

+ (instancetype)itemWithTitle:(NSString *)title
                     iconName:(NSString *)iconName
                   BadgeValue:(NSString *)badgeValue
                 BadgeBGColor:(UIColor *)badgeBGColor
{
    CCPopMenuItem *item = [self itemWithTitle:title
                                TextAlignment:NSTextAlignmentLeft
                                     iconName:iconName];
    item.badgeValue = badgeValue;
    item.badgeBGColor = badgeBGColor;

    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
{
    return [self itemWithTitle:title
                 TextAlignment:textAlignment
                      iconName:@""];
}

+ (instancetype)itemWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
{
    return [self initWithTitle:title
                 TextAlignment:NSTextAlignmentLeft
                      iconName:iconName
                     glowColor:nil
                         index:-1];
}

+ (instancetype)itemWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
{
    return [self initWithTitle:title
                 TextAlignment:textAlignment
                      iconName:iconName
                     glowColor:glowColor
                         index:-1];
}

+ (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                        index:(NSInteger)index
{
    return [self initWithTitle:title
                 TextAlignment:(NSTextAlignment)textAlignment
                      iconName:iconName
                     glowColor:nil
                         index:index];
}

+ (instancetype)initWithTitle:(NSString *)title
                TextAlignment:(NSTextAlignment)textAlignment
                     iconName:(NSString *)iconName
                    glowColor:(UIColor *)glowColor
                        index:(NSInteger)index
{
    CCPopMenuItem *item = [[self alloc] initWithTitle:title
                                        TextAlignment:textAlignment
                                             iconName:iconName
                                            glowColor:glowColor
                                                index:index];
    return item;
}


@end
