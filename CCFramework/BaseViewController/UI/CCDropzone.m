//
//  CCDropzone.m
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

#import "CCDropzone.h"
#import "CCDropzoneViewController.h"
#import "Config.h"

static CCDropzone *_sharedlnstance = nil;

@implementation CCDropzone{
    CCDropzoneViewController *viewController;
}

//单列模式
+(id)sharedlnstance{
    @synchronized(self){
        if (_sharedlnstance == nil) {
            _sharedlnstance = [[self alloc] init];
        }
    }
    return _sharedlnstance;
}

-(id)init{
    if (self = [super init]) {
        CCDropzoneWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, winsize.width, winsize.height)];
        CCDropzoneWindow.backgroundColor = [UIColor redColor];
        CCDropzoneWindow.windowLevel = [UIApplication sharedApplication].keyWindow.windowLevel;
        CCDropzoneWindow.clipsToBounds = NO;
        [CCDropzoneWindow makeKeyAndVisible];
        CCDropzoneWindow.hidden = YES;
        
        viewController = [[CCDropzoneViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, winsize.width, winsize.height);
        viewController.view.backgroundColor = [UIColor clearColor];
        CCDropzoneWindow.rootViewController = viewController;

    }
    return self;
}

-(void)Show{
    CCDropzoneWindow.frame = CGRectMake(0, 64,winsize.width, winsize.height);
    CCDropzoneWindow.hidden = NO;
}

-(void)Close{
    CCDropzoneWindow.hidden = YES;
}

@end
