//
//  CCAutoTextView.m
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

#import "CCAutoTextView.h"

@interface CCAutoTextView () <UITextViewDelegate>

@property (nonatomic, strong) NSTimer *scrollTimer;

@end

@implementation CCAutoTextView

- (instancetype)init
{
    if (self = [super init]) {
        self.delegate = self;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
         self.delegate = self;
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if(newWindow)
    {
        [self.panGestureRecognizer addTarget:self action:@selector(gestureDidChange:)];
        [self.pinchGestureRecognizer addTarget:self action:@selector(gestureDidChange:)];
    }
    else
    {
        [self stopScrolling];
        [self.panGestureRecognizer removeTarget:self action:@selector(gestureDidChange:)];
        [self.pinchGestureRecognizer removeTarget:self action:@selector(gestureDidChange:)];
    }
}

#pragma mark - Touch methods

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    [self stopScrolling];
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (void)gestureDidChange:(UIGestureRecognizer *)gesture
{
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            [self stopScrolling];
        }
            break;
        default:
            break;
    }
}

- (BOOL)becomeFirstResponder
{
    [self stopScrolling];
    return [super becomeFirstResponder];
}

#pragma mark - Property methods

- (CGFloat)pointsPerSecond
{
    if (!_pointsPerSecond)
    {
        _pointsPerSecond = 8.0f;
    }
    return _pointsPerSecond;
}

#pragma mark - Public methods

- (void)startScrolling
{
    [self stopScrolling];

    CGFloat animationDuration = (0.5f / self.pointsPerSecond);
    _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration
                                                    target:self
                                                  selector:@selector(updateScroll)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)stopScrolling
{
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}

- (void)updateScroll
{
    CGFloat animationDuration = _scrollTimer.timeInterval;
    CGFloat pointChange = self.pointsPerSecond * animationDuration;
    CGPoint newOffset = self.contentOffset;
    newOffset.y = newOffset.y + pointChange;

    if (newOffset.y > (self.contentSize.height - self.bounds.size.height))
    {
        [self stopScrolling];
    }
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.contentOffset = newOffset;
        [UIView commitAnimations];
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self startScrolling];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startScrolling];
}

@end
