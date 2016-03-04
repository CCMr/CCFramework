//
//  NumericKeypadView.m
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

#import "CCNumericKeypadView.h"
#import "Config.h"
#import "UIButton+Additions.h"
#import "UIControl+Additions.h"

@implementation CCNumericKeypadView

@synthesize containerView;

- (instancetype)init
{
    if (self = [super init]) {
        _EnterCount = 9;
        [self initControl];
    }
    return self;
}

- (id)initWithContainerView:(UIView *)ainerView
{
    if (self = [super init]) {
        _EnterCount = 9;
        containerView = ainerView;
        [self initControl];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _EnterCount = 9;
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    float h = 246, y = 30;
    self.frame = CGRectMake(0, 0, winsize.width, h);
    UIImageView *keyboardBackground = [[UIImageView alloc] initWithImage:CCResourceImage(@"KeyboardNumericBg")];
    keyboardBackground.frame = CGRectMake(0, 0, winsize.width, 246);
    [self addSubview:keyboardBackground];
    
    
    UILabel *Title = [[UILabel alloc] initWithFrame:CGRectMake(winsize.width / 2.5, 5, 200, 20)];
    Title.textColor = cc_ColorRGBA(191, 191, 191, 1);
    Title.font = [UIFont systemFontOfSize:13];
    Title.text = @"凯润特安全输入";
    [self addSubview:Title];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(Title.frame.origin.x - 30, 5, 25, 20)];
    logoImage.image = [UIImage imageNamed:@"logo"];
    [self addSubview:logoImage];
    
    
    UIView *VerticalLine1 = [[UIView alloc] initWithFrame:CGRectMake(KeyboardNumericKeyWidth, y, 1, h)];
    VerticalLine1.backgroundColor = cc_ColorRGBA(143, 143, 143, 1);
    [self addSubview:VerticalLine1];
    
    UIView *VerticalLine2 = [[UIView alloc] initWithFrame:CGRectMake(KeyboardNumericKeyWidth * 2, y, 1, h)];
    VerticalLine2.backgroundColor = cc_ColorRGBA(143, 143, 143, 1);
    [self addSubview:VerticalLine2];
    
    UIView *VerticalLine3 = [[UIView alloc] initWithFrame:CGRectMake(KeyboardNumericKeyWidth * 3, y, 1, h)];
    VerticalLine3.backgroundColor = cc_ColorRGBA(143, 143, 143, 1);
    [self addSubview:VerticalLine3];
    
    UIView *horizontalLine0 = [[UIView alloc] initWithFrame:CGRectMake(0, y, winsize.width, 1)];
    horizontalLine0.backgroundColor = cc_ColorRGBA(143, 143, 143, 1);
    [self addSubview:horizontalLine0];
    
    [self addSubview:[self addNumericKeyWithTitle:@"1" BottomTitle:@"" frame:CGRectMake(0, y + 1, KeyboardNumericKeyWidth, KeyboardNumericKeyHeight - 1)]];
    [self addSubview:[self addNumericKeyWithTitle:@"2" BottomTitle:@"" frame:CGRectMake(KeyboardNumericKeyWidth + 1, y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    [self addSubview:[self addNumericKeyWithTitle:@"3" BottomTitle:@"" frame:CGRectMake(KeyboardNumericKeyWidth * 2 + 1, y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    
    UIView *horizontalLine1 = [[UIView alloc] initWithFrame:CGRectMake(0, KeyboardNumericKeyHeight + y, winsize.width - 80, 1)];
    horizontalLine1.backgroundColor = cc_ColorRGBA(143, 143, 143, 1);
    [self addSubview:horizontalLine1];
    
    [self addSubview:[self addNumericKeyWithTitle:@"4" BottomTitle:@"" frame:CGRectMake(0, KeyboardNumericKeyHeight + y + 1, KeyboardNumericKeyWidth, KeyboardNumericKeyHeight - 1)]];
    [self addSubview:[self addNumericKeyWithTitle:@"5" BottomTitle:@"" frame:CGRectMake(KeyboardNumericKeyWidth + 1, KeyboardNumericKeyHeight + y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    [self addSubview:[self addNumericKeyWithTitle:@"6" BottomTitle:@"" frame:CGRectMake(KeyboardNumericKeyWidth * 2 + 1, KeyboardNumericKeyHeight + y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    
    UIView *horizontalLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, KeyboardNumericKeyHeight * 2 + y, winsize.width - 80, 1)];
    horizontalLine2.backgroundColor = cc_ColorRGBA(143, 143, 143, 1);
    [self addSubview:horizontalLine2];
    
    [self addSubview:[self addNumericKeyWithTitle:@"7" BottomTitle:@"" frame:CGRectMake(0, KeyboardNumericKeyHeight * 2 + y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight)]];
    [self addSubview:[self addNumericKeyWithTitle:@"8" BottomTitle:@"" frame:CGRectMake(KeyboardNumericKeyWidth + 1, KeyboardNumericKeyHeight * 2 + y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    [self addSubview:[self addNumericKeyWithTitle:@"9" BottomTitle:@"" frame:CGRectMake(KeyboardNumericKeyWidth * 2 + 1, KeyboardNumericKeyHeight * 2 + y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    
    UIView *horizontalLine3 = [[UIView alloc] initWithFrame:CGRectMake(0, KeyboardNumericKeyHeight * 3 + y, winsize.width - 80, 1)];
    horizontalLine3.backgroundColor = cc_ColorRGBA(143, 143, 143, 1);
    [self addSubview:horizontalLine3];
    
    [self addSubview:[self addNumericKeyWithTitle:@"." BottomTitle:@"" frame:CGRectMake(0, KeyboardNumericKeyHeight * 3 + y + 1, KeyboardNumericKeyWidth, KeyboardNumericKeyHeight - 1)]];
    [self addSubview:[self addNumericKeyWithTitle:@"0" BottomTitle:@"" frame:CGRectMake(KeyboardNumericKeyWidth + 1, KeyboardNumericKeyHeight * 3 + y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    [self addSubview:[self addKeyboardWithFrame:CGRectMake(KeyboardNumericKeyWidth * 2 + 1, KeyboardNumericKeyHeight * 3 + y + 1, KeyboardNumericKeyWidth - 1, KeyboardNumericKeyHeight - 1)]];
    
    [self addSubview:[self addBackspaceKeyWithFrame:CGRectMake(winsize.width - 80, y, 80, KeyboardNumericKeyHeight * 2)]];
    [self addSubview:[self addNumericKeyWithTitle:@"完成" BottomTitle:@"" frame:CGRectMake(winsize.width - 80, KeyboardNumericKeyHeight * 3 - y + 6, 80, KeyboardNumericKeyHeight * 2)]];
}

- (UIButton *)addKeyboardWithFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithImage:@""
                                   FinishedImage:nil
                             WithFinishedUnImage:CCResourceImage(@"WithFinishedUnselecte")];
    
    button.frame = frame;
    
    UIImage *image = [UIImage imageNamed:@"jp"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - image.size.width) / 2, (frame.size.height - image.size.height) / 2, image.size.width, image.size.height)];
    imgView.image = image;
    [button addSubview:imgView];
    
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        if (containerView){
            [((UITextField *)containerView) resignFirstResponder];
        }
        if ([self.delegate respondsToSelector:@selector(didConsummation)])
            [self.delegate didConsummation];
    }];
    
    [button addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(ButtonLong:)]];
    
    return button;
}


- (UIButton *)addNumericKeyWithTitle:(NSString *)title BottomTitle:(NSString *)botomTitle frame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithImage:title
                                   FinishedImage:[title isEqualToString:@"完成"] ? CCResourceImage(@"Back") : nil
                             WithFinishedUnImage:CCResourceImage(@"WithFinishedUnselecte")];
    
    button.frame = frame;
    if ([title isEqualToString:@"完成"]) {
        button.titleLabel.font = [UIFont systemFontOfSize:20];
    }
    if (![botomTitle isEqualToString:@""])
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    
    UILabel *contents = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 23, frame.size.width, 20)];
    contents.textAlignment = NSTextAlignmentCenter;
    contents.textColor = [UIColor whiteColor];
    contents.font = [UIFont systemFontOfSize:12];
    contents.text = botomTitle;
    
    [button addSubview:contents];
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        UITextField *textField = (UITextField *)containerView;
        textField.delegate = self;
        if ([title isEqualToString:@"完成"]) {
            if (containerView){
                [self NumberFormatter:textField.text];
                [((UITextField *)containerView) resignFirstResponder];
            }
            if ([self.delegate respondsToSelector:@selector(didConsummation)])
                [self.delegate didConsummation];
        }else{
            if (containerView) {
                
                BOOL IsText = YES;
                NSRange range = [textField.text rangeOfString:@"."];
                if ([title isEqualToString:@"."]) {
                    if (range.location == NSNotFound && range.length > 0)
                        IsText = NO;
                    _EnterCount = 10;
                }
                UITextRange *selectedRange = [textField selectedTextRange];
                NSInteger offset = [textField offsetFromPosition:textField.endOfDocument toPosition:selectedRange.end];
                
                int pos = (int)[textField offsetFromPosition:textField.beginningOfDocument toPosition:[textField selectedTextRange].start];
                
                if (IsText) {
                    NSMutableString *text = [[NSMutableString alloc] initWithString:textField.text];
                    [text insertString:title atIndex:pos];
                    
                    NSString *texts = [NSString stringWithString:text];
                    if (range.location != NSNotFound){
                        range = [texts rangeOfString:@"."];
                        texts = [texts substringToIndex:range.location + 3 > texts.length ? texts.length : range.location +3 ];
                    }
                    if (texts.length <= _EnterCount) {
                        textField.text = texts;
                        UITextPosition *newPos = [textField positionFromPosition:textField.endOfDocument offset:offset];
                        textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
                        if(blck)
                            blck(nil);
                    }
                }
            }
            
            if ([self.delegate respondsToSelector:@selector(didNumericKeyPressed:)])
                [self.delegate didNumericKeyPressed:button.titleLabel.text];
        }
    }];
    return button;
}


- (UIButton *)addBackspaceKeyWithFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithImage:@""
                                   FinishedImage:nil
                             WithFinishedUnImage:CCResourceImage(@"WithFinishedUnselecte")];
    button.frame = frame;
    
    UIImage *image = CCResourceImage(@"KeyboardNumericEntryKeyBackspaceGlyphTextured");
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - image.size.width) / 2, (frame.size.height - image.size.height) / 2, image.size.width, image.size.height)];
    imgView.image = image;
    [button addSubview:imgView];
    
    [button handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        if (containerView) {
            UITextField *textField = (UITextField *)containerView;
            NSInteger length = textField.text.length;
            if (length == 0) {
                textField.text = @"";
                return;
            }
            UITextRange *selectedRange = [textField selectedTextRange];
            NSInteger offset = [textField offsetFromPosition:textField.endOfDocument toPosition:selectedRange.end];
            
            NSString *substring = [NSString stringWithFormat:@"%@%@",[textField.text substringWithRange:NSMakeRange(0, length+offset - 1>=0?length+offset-1:0)],[textField.text substringFromIndex:length+offset]];
            [textField setText:substring];
            UITextPosition *newPos = [textField positionFromPosition:textField.endOfDocument offset:offset];
            textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
            
            if(blck)
                blck(nil);
        }
        
        if ([self.delegate respondsToSelector:@selector(didBackspaceKeyPressed)])
            [self.delegate didBackspaceKeyPressed];
    }];
    
    [button addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(ButtonLong:)]];
    
    return button;
}

//长按删除
- (void)ButtonLong:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (containerView) {
            [((UITextField *)containerView)setText:nil];
            if (blck)
                blck(nil);
        }
        
        if ([self.delegate respondsToSelector:@selector(didBackspaceKeyPressed)])
            [self.delegate didBackspaceKeyPressed];
    }
}

- (void)didTextFieldCompletion:(TextFieldCompletion)TextFileblck
{
    blck = TextFileblck;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        return YES;
    }
    textField.text = [self number:textField.text];
    textField.text = [self NumberFormatter:textField.text];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        return YES;
    }
    textField.text = [self number:textField.text];
    return YES;
}

- (NSString *)NumberFormatter:(NSString *)num
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setPositiveFormat:@"###,##0.00;"];
    return [nf stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
}

- (NSString *)number:(NSString *)num
{
    NSArray *numStrings = [num componentsSeparatedByString:@","];
    NSMutableString *mutableNum = [NSMutableString string];
    for (NSString *subNumString in numStrings) {
        [mutableNum appendString:subNumString];
    }
    
    return [NSNumber numberWithDouble:[mutableNum doubleValue]].stringValue;
}


@end
