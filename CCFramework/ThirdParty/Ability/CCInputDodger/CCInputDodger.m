//
//  CCInputDodger.m
//  CCFramework
//
// Copyright (c) 2016 CC ( http://www.ccskill.com )
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

#import "CCInputDodger.h"
#import "UIView+CCInputDodger.h"
#import "UIScrollView+CCInputDodger.h"

#define CHILD(childClass, object) \
((childClass *)object)


const double kCCInputViewAnimationDuration = .25f;

@interface CCInputDodger ()

/**
 *  Current first responder view
 */
@property(nonatomic, weak) UIView *firstResponderView;

/**
 *  Views can be dodged
 */
@property(nonatomic, strong) NSHashTable *dodgeViews;

/**
 *  First responder view record because the last show of input view(keyboard)
 */
@property(nonatomic, weak) UIView *lastFirstResponderViewForShowInputView;
@property(nonatomic, assign) CGRect inputViewFrame;
@property(nonatomic, assign) NSInteger inputViewAnimationCurve;

@end

@implementation CCInputDodger

+ (instancetype)dodger
{
    static id _dodger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dodger = [[[self class] alloc] init];
    });
    
    return _dodger;
}

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inputViewAnimationCurve = 7;
        //add observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter
- (NSHashTable *)dodgeViews
{
    if (!_dodgeViews) {
        _dodgeViews = [NSHashTable weakObjectsHashTable];
    }
    return _dodgeViews;
}

#pragma mark - setter
- (void)setFirstResponderView:(UIView *)firstResponderView
{
    if ([firstResponderView isKindOfClass:[UIActionSheet class]])
        return;
    
    _firstResponderView = firstResponderView;
}

#pragma mark - outcall
- (void)firstResponderViewChangeTo:(UIView *)view
{
    NSAssert(view, @"firstResponderView cannot be changed to nil");
    if ([self.firstResponderView isEqual:view])
        return;
    
    self.firstResponderView = view;
    
    if (self.lastFirstResponderViewForShowInputView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![self.lastFirstResponderViewForShowInputView isEqual:self.firstResponderView]) {
                self.lastFirstResponderViewForShowInputView = self.firstResponderView;
                [self doDodgeWithAnimated:YES];
            }
        });
    }
}


- (void)registerDodgeView:(UIView *)dodgeView
{
    if (![self isRegisteredForDodgeView:dodgeView]) {
        [self.dodgeViews addObject:dodgeView];
    }
}

- (void)unregisterDodgeView:(UIView *)dodgeView
{
    [self.dodgeViews removeObject:dodgeView];
}

- (BOOL)isRegisteredForDodgeView:(UIView *)dodgeView
{
    return [self.dodgeViews containsObject:dodgeView];
}

#pragma mark - notification
- (void)updateInputViewDetailWithKeyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    self.inputViewAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    self.inputViewFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (self.inputViewFrame.origin.y > [UIScreen mainScreen].bounds.size.height) {
        CGRect adjustFrame = self.inputViewFrame;
        adjustFrame.origin.y = [UIScreen mainScreen].bounds.size.height - adjustFrame.size.height;
        self.inputViewFrame = adjustFrame;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    BOOL animated = YES;
    if ([self.lastFirstResponderViewForShowInputView isEqual:self.firstResponderView])
        animated = NO;
    
    
    self.lastFirstResponderViewForShowInputView = self.firstResponderView;
    
    [self updateInputViewDetailWithKeyboardNotification:notification];
    [self doDodgeWithAnimated:animated];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.lastFirstResponderViewForShowInputView = nil;
    
    [self updateInputViewDetailWithKeyboardNotification:notification];
    [self doDodgeWithAnimated:YES];
}

#pragma mark - helper
/**
 *  Get the dodger view of current first responder view
 */
- (UIView *)currentDodgeView
{
    if (!self.firstResponderView) {
        return nil;
    }
    
    UIView *superView = self.firstResponderView;
    while (superView) {
        if ([self.dodgeViews containsObject:superView])
            return superView;
        
        superView = [superView superview];
    }
    return nil;
}

/**
 *  If the dodger view is child of `UIScrollView`
 *  We will not change it's frame, replace with changing `contentOffset` and `contentInset`
 */
- (void)doDodgeWithAnimated:(BOOL)animated dodgeScrollView:(UIScrollView *)dodgeView
{
    if (!dodgeView)
        return;
    
    
    void (^dodgeBlock)(UIEdgeInsets, CGPoint, BOOL) = ^(UIEdgeInsets inset, CGPoint offset, BOOL forHide) {
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:kCCInputViewAnimationDuration];
            [UIView setAnimationCurve:self.inputViewAnimationCurve];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            dodgeView.contentInset = inset;
            if (!forHide){
                [dodgeView setContentOffset:offset animated:NO];
            }
            
            [UIView commitAnimations];
        }else{
            dodgeView.contentInset = inset;
            if (!forHide)
                [dodgeView setContentOffset:offset animated:NO];
            
        }
    };
    
    
    UIEdgeInsets inset = dodgeView.originalContentInset;
    CGPoint offset = dodgeView.contentOffset;
    
    //If do dodge for display
    if (self.lastFirstResponderViewForShowInputView) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        
        //Find the position which must be display
        CGFloat shiftHeight = self.firstResponderView.firstResponderShiftHeight;
        if (shiftHeight == 0)
            shiftHeight = dodgeView.shiftHeight;
        
        
        CGRect frameInDodgeView = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:dodgeView];
        
        CGRect dodgeViewFrameInWindow = [dodgeView.superview convertRect:dodgeView.frame toView:dodgeView.window];
        CGFloat dodgeViewFrameBottomInWindow = CGRectGetMaxY(dodgeViewFrameInWindow);
        
        inset.bottom += MAX(0, dodgeViewFrameBottomInWindow - keyboardOrginY);
        
        CGFloat mustDisplayHeight = CGRectGetHeight(self.firstResponderView.frame) + shiftHeight;
        //the assert is not needed, if you use the library normally.
        //        NSAssert(CGRectGetHeight(dodgeViewFrameInWindow)>=mustDisplayHeight+inset.top, @"the height of dodgeScrollView cannot be too small or shift height cannot be too large");
        //        NSAssert(keyboardOrginY-dodgeViewFrameInWindow.origin.y>=mustDisplayHeight+inset.top, @"the y of dodgeScrollView cannot too low or shift height cannot be too large");
        
        offset.y = frameInDodgeView.origin.y - inset.top - (MIN(keyboardOrginY, dodgeViewFrameBottomInWindow) - dodgeViewFrameInWindow.origin.y - mustDisplayHeight - inset.top);
        offset.y = MIN(offset.y, dodgeView.contentSize.height - CGRectGetHeight(dodgeViewFrameInWindow) + inset.bottom);
        offset.y = MAX(offset.y, -inset.top);
        
        id nextResponder = [dodgeView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            //after pop viewcontroller,the viewcontroller's frame will be reset.
            //so we detect it, and dodge again
            if ([CHILD(UIViewController, nextResponder).transitionCoordinator isAnimated]) {
                [CHILD(UIViewController, nextResponder).transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    dodgeBlock(inset,offset,self.lastFirstResponderViewForShowInputView==nil);
                }];
                return;
            }
        }
    }
    
    dodgeBlock(inset, offset, self.lastFirstResponderViewForShowInputView == nil);
}

/**
 *  do dodge with common view, change it's frame
 */
- (void)doDodgeWithAnimated:(BOOL)animated
{
    UIView *dodgeView = [self currentDodgeView];
    if (!dodgeView)
        return;
    
    if ([dodgeView isKindOfClass:[UIScrollView class]]) {
        [self doDodgeWithAnimated:animated dodgeScrollView:CHILD(UIScrollView, dodgeView)];
        return;
    }
    
    void (^dodgeBlock)(CGFloat) = ^(CGFloat completeY) {
        CGRect frame = dodgeView.frame;
        frame.origin.y = completeY;
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:kCCInputViewAnimationDuration];
            [UIView setAnimationCurve:self.inputViewAnimationCurve];
            [UIView setAnimationBeginsFromCurrentState:YES];
            
            dodgeView.frame = frame;
            
            [UIView commitAnimations];
        }else{
            dodgeView.frame = frame;
        }
    };
    
    
    CGFloat oldY = dodgeView.originalY;
    CGFloat newY = oldY;
    if (self.lastFirstResponderViewForShowInputView) {
        CGFloat keyboardOrginY = self.inputViewFrame.origin.y;
        
        //Find the position which must be display
        CGFloat shiftHeight = self.firstResponderView.firstResponderShiftHeight;
        if (shiftHeight == 0)
            shiftHeight = dodgeView.shiftHeight;
        
        CGRect frameInWindow = [self.firstResponderView convertRect:self.firstResponderView.bounds toView:self.firstResponderView.window];
        
        CGFloat mustVisibleYForWindow = frameInWindow.origin.y + frameInWindow.size.height + shiftHeight;
        
        newY = MIN(oldY, keyboardOrginY - mustVisibleYForWindow + dodgeView.frame.origin.y);
        //ensure that the view will not move up devilishly
        newY = MAX(newY, keyboardOrginY - CGRectGetHeight(dodgeView.frame));
        //ensure that the view will not move down
        newY = MIN(newY, oldY);
        
        id nextResponder = [dodgeView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            //after pop viewcontroller,the viewcontroller's frame will be reset.
            //so we detect it, and dodge again
            if ([CHILD(UIViewController, nextResponder).transitionCoordinator isAnimated]) {
                [CHILD(UIViewController, nextResponder).transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    dodgeBlock(newY);
                }];
                return;
            }
        }
    }
    
    dodgeBlock(newY);
}


@end
