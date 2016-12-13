//
//  CCPathButton.h
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

@import UIKit;
@import QuartzCore;
@import AudioToolbox;

@interface CCPathModel : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) UIImage *image;

-(instancetype)initWithTitle:(NSString *)title 
                       Image:(UIImage *)image;

@end

typedef NS_ENUM(NSUInteger, kCCPathButtonBloomDirection) {
    
    kCCPathButtonBloomDirectionTop = 1,
    kCCPathButtonBloomDirectionTopLeft = 2,
    kCCPathButtonBloomDirectionLeft = 3,
    kCCPathButtonBloomDirectionBottomLeft = 4,
    kCCPathButtonBloomDirectionBottom = 5,
    kCCPathButtonBloomDirectionBottomRight = 6,
    kCCPathButtonBloomDirectionRight = 7,
    kCCPathButtonBloomDirectionTopRight = 8,
    
};

@protocol CCPathButtonDelegate <NSObject>

- (void)didClickItemButtonAtIndex:(NSUInteger)itemButtonIndex;

@optional

- (void)willPresentCCPathButtonItems:(UIButton *)CCPathButton;
- (void)didPresentCCPathButtonItems:(UIButton *)CCPathButton;

- (void)willDismissCCPathButtonItems:(UIButton *)CCPathButton;
- (void)didDismissCCPathButtonItems:(UIButton *)CCPathButton;

@end

@interface CCPathButton : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<CCPathButtonDelegate> delegate;

@property (assign, nonatomic) NSTimeInterval basicDuration;
@property (assign, nonatomic) BOOL allowSubItemRotation;

@property (assign, nonatomic) CGFloat bloomRadius;
@property (assign, nonatomic) CGFloat bloomAngel;
@property (assign, nonatomic) CGPoint ccButtonCenter;

@property (assign, nonatomic) BOOL allowSounds;

@property (copy, nonatomic) NSString *bloomSoundPath;
@property (copy, nonatomic) NSString *foldSoundPath;
@property (copy, nonatomic) NSString *itemSoundPath;

@property (assign, nonatomic) BOOL allowCenterButtonRotation;

@property (strong, nonatomic) UIColor *bottomViewColor;

@property (assign, nonatomic) kCCPathButtonBloomDirection bloomDirection;

- (instancetype)initWithCenterImage:(UIImage *)centerImage
                   highlightedImage:(UIImage *)centerHighlightedImage;

- (instancetype)initWithButtonFrame:(CGRect)centerButtonFrame
                        centerImage:(UIImage *)centerImage
                   highlightedImage:(UIImage *)centerHighlightedImage;

- (void)addPathItems:(NSArray *)pathItems;

@end
