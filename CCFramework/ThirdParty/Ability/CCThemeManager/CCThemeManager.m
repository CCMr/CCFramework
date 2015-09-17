//
//  CCThemeManager.m
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

#import "CCThemeManager.h"
#import "Config.h"

typedef enum {
    CCThemeStatusWillChange = 0, // todo
    CCThemeStatusDidChange,
} CCThemeStatus;


static CCThemeManager *_sharedlnstance = nil;

@implementation CCThemeManager

//单列模式
+(id)sharedlnstance
{
    @synchronized(self){
        if (_sharedlnstance == nil)
            _sharedlnstance = [[self alloc] init];
    }
    return _sharedlnstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        _themeArray = @[@"Blue",@"Black"];//APP主题名
        NSString *themes = [userDefaults objectForKey:@"setingTheme"];
        if (themes)
        {
            self.currentTheme = themes;
            [userDefaults setObject:self.currentTheme forKey:@"setingTheme"];
        }
        else
        {
            self.currentTheme = @"Blue";
            [userDefaults setObject:self.currentTheme forKey:@"setingTheme"];
        }
    }
    return self;
}

-(void)setTheme:(NSString *)theme
{
    if (!theme || [theme isEqualToString:_currentTheme] || ![_themeArray containsObject:theme])
        return;
    
    self.currentTheme = theme;
    [userDefaults setObject:theme forKey:@"setingTheme"];
    [[NSNotificationCenter defaultCenter] postNotificationName:CCThemeDidChangeNotification object:@(CCThemeStatusDidChange)];
}

-(NSString *)theme
{
    return [userDefaults objectForKey:@"setingTheme"];
}

-(UIImage *)imageWithImageName:(NSString *)imageName
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"theme" ofType:@"bundle"]];
    NSString *imagePath = [bundle pathForResource:imageName ofType:@"png" inDirectory:[self theme]];
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end
