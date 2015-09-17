//
//  NumericKeypadView.h
//  CC
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
#define KeyboardNumericKeyWidth (winsize.width - 80) / 3
#define KeyboardNumericKeyHeight 54

typedef void (^TextFieldCompletion)(NSObject *obj);

@protocol CCNumericKeypadViewDelegate <NSObject>

- (void)didNumericKeyPressed:(NSString *)Numeric;
- (void)didBackspaceKeyPressed;
- (void)didConsummation;

@end

@interface CCNumericKeypadView : UIView<UITextFieldDelegate>{
    TextFieldCompletion blck;
}

-(id)initWithContainerView:(UIView *)ainerView;

@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, assign) int EnterCount;

@property (nonatomic, assign) id<CCNumericKeypadViewDelegate> delegate;

-(void)didTextFieldCompletion:(TextFieldCompletion)TextFileblck;

@end
