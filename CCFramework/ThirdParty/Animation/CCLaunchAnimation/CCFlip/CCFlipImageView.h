//
//  CCFlipImageView.h
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

#import <UIKit/UIKit.h>

extern const NSTimeInterval CCFlipImageViewDefaultFlipDuration;

typedef void(^CCFlipImageViewCompletionBlock)(BOOL finished);

typedef NS_ENUM(NSInteger, CCFlipImageViewFlipDirection) {
    CCFlipImageViewFlipDirectionDown,
    CCFlipImageViewFlipDirectionUp
};

@interface CCFlipImageView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CCFlipImageViewFlipDirection flipDirection;
@property (nonatomic, assign) NSUInteger zDistance;

- (id)initWithImage:(UIImage*)image;

- (void)setImageAnimated:(UIImage*)image;

- (void)setImageAnimated:(UIImage*)image
              completion:(CCFlipImageViewCompletionBlock)completion;

- (void)setImageAnimated:(UIImage*)image
                duration:(CGFloat)duration
              completion:(CCFlipImageViewCompletionBlock)completion;

@end
