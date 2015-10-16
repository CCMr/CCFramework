//
//  CCUtilityButtonView.m
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

#import "CCUtilityButtonView.h"
#import "CCUtilityButtonTapGestureRecognizer.h"

@interface CCUtilityButtonView()

@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSMutableArray *buttonBackgroundColors;

@end

@implementation CCUtilityButtonView

#pragma mark - CCUtilityButonView initializers

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(CCTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector
{
    self = [self initWithFrame:CGRectZero utilityButtons:utilityButtons parentCell:parentCell utilityButtonSelector:utilityButtonSelector];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(CCTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:0.0]; // constant will be adjusted dynamically in -setUtilityButtons:.
        self.widthConstraint.priority = UILayoutPriorityDefaultHigh;
        [self addConstraint:self.widthConstraint];
        
        _parentCell = parentCell;
        self.utilityButtonSelector = utilityButtonSelector;
        self.utilityButtons = utilityButtons;
    }
    
    return self;
}

#pragma mark Populating utility buttons

- (void)setUtilityButtons:(NSArray *)utilityButtons
{
    // if no width specified, use the default width
    [self setUtilityButtons:utilityButtons WithButtonWidth:kUtilityButtonWidthDefault];
}

- (void)setUtilityButtons:(NSArray *)utilityButtons WithButtonWidth:(CGFloat)width
{
    for (UIButton *button in _utilityButtons)
    {
        [button removeFromSuperview];
    }
    
    _utilityButtons = [utilityButtons copy];
    
    if (utilityButtons.count)
    {
        NSUInteger utilityButtonsCounter = 0;
        UIView *precedingView = nil;
        
        for (UIButton *button in _utilityButtons)
        {
            [self addSubview:button];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            
            if (!precedingView)
            {
                // First button; pin it to the left edge.
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[button]"
                                                                             options:0L
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(button)]];
            }
            else
            {
                // Subsequent button; pin it to the right edge of the preceding one, with equal width.
                [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[precedingView][button(==precedingView)]"
                                                                             options:0L
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(precedingView, button)]];
            }
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                         options:0L
                                                                         metrics:nil
                                                                           views:NSDictionaryOfVariableBindings(button)]];
            
            
            CCUtilityButtonTapGestureRecognizer *utilityButtonTapGestureRecognizer = [[CCUtilityButtonTapGestureRecognizer alloc] initWithTarget:_parentCell action:_utilityButtonSelector];
            utilityButtonTapGestureRecognizer.buttonIndex = utilityButtonsCounter;
            [button addGestureRecognizer:utilityButtonTapGestureRecognizer];
            
            utilityButtonsCounter++;
            precedingView = button;
        }
        
        // Pin the last button to the right edge.
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[precedingView]|"
                                                                     options:0L
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(precedingView)]];
    }
    
    self.widthConstraint.constant = (width * utilityButtons.count);
    
    [self setNeedsLayout];
    
    return;
}

#pragma mark -

- (void)pushBackgroundColors
{
    self.buttonBackgroundColors = [[NSMutableArray alloc] init];
    
    for (UIButton *button in self.utilityButtons)
    {
        [self.buttonBackgroundColors addObject:button.backgroundColor];
    }
}

- (void)popBackgroundColors
{
    NSEnumerator *e = self.utilityButtons.objectEnumerator;
    
    for (UIColor *color in self.buttonBackgroundColors)
    {
        UIButton *button = [e nextObject];
        button.backgroundColor = color;
    }
    
    self.buttonBackgroundColors = nil;
}

@end

