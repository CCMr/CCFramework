//
//  CCLanguage.m
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

#import "CCLanguage.h"

static NSString * const CCSaveLanguageDefaultKey = @"CCSaveLanguageDefaultKey";

@interface CCLanguage()

@property (nonatomic, strong) NSDictionary *dicLocalisation;

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

static CCLanguage *_sharedlnstance = nil;
@implementation CCLanguage

+(id)sharedInstance{
    @synchronized(self){
        if (_sharedlnstance == nil) {
            _sharedlnstance = [[self alloc] init];
        }
    }
    return _sharedlnstance;
}

-(id)init{
    self =[super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
        _languagesArray = @[@"zh-Hans",@"English"];
        self.currentLanguage = @"zh-Hans";
        NSString *languageSaved = [_defaults objectForKey:CCSaveLanguageDefaultKey];
        if (languageSaved != nil && ![languageSaved isEqualToString:@"zh-Hans"]) {
            [self loadDictionaryForLanguage:languageSaved];
        }
    }
    return self;
}

-(BOOL)loadDictionaryForLanguage:(NSString *)newLanguage{
    NSURL * urlPath = [[NSBundle bundleForClass:[self class]] URLForResource:@"Localizable" withExtension:@"strings" subdirectory:nil localization:newLanguage];
    if ([[NSFileManager defaultManager] fileExistsAtPath:urlPath.path]) {
        _currentLanguage = newLanguage;
        _dicLocalisation = [[NSDictionary dictionaryWithContentsOfFile:urlPath.path] copy];
        return YES;
    }
    return NO;
}

-(BOOL)saveInUserDefaults{
    return ([_defaults objectForKey:CCSaveLanguageDefaultKey] != nil);
}

-(void)setSaveInUserDefaults:(BOOL)saveInUserDefaults{
    [_defaults removeObjectForKey:CCSaveLanguageDefaultKey];
    if (saveInUserDefaults)
    {
        [_defaults setObject:_currentLanguage forKey:CCSaveLanguageDefaultKey];
    }
    [_defaults synchronize];
}

-(NSString *)loalizedStringForKey:(NSString *)key{
    NSString *LocalizedString = NSLocalizedString(key, key);
    if (_dicLocalisation) {
        NSString *Str = [_dicLocalisation objectForKey:key];
        LocalizedString = Str;
        if (!Str)
            LocalizedString = key;
    }
    return LocalizedString;
}

-(BOOL)setLanguage:(NSString *)newLanguage{
    if(!newLanguage || [newLanguage isEqualToString:_currentLanguage] || ![_languagesArray containsObject:newLanguage])
        return NO;
    if ([newLanguage isEqualToString:@"zh-Hans"]) {
        _currentLanguage = newLanguage;
        _dicLocalisation = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotificationLanguageChanged object:nil];
        return YES;
    }else{
        BOOL isLoadingOK = [self loadDictionaryForLanguage:newLanguage];
        if (isLoadingOK) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotificationLanguageChanged object:nil];
            if ([self saveInUserDefaults]) {
                [_defaults setObject:_currentLanguage forKey:CCSaveLanguageDefaultKey];
                [_defaults synchronize];
            }
        }
        return isLoadingOK;
    }
}

-(void)setSaveLanguage:(NSString *)newLanguage{
    [self setLanguage:newLanguage];
    [self setSaveInUserDefaults:YES];
}


@end
