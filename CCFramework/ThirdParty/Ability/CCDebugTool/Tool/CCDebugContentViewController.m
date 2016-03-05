//
//  CCDebugContentViewController.m
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

#import "CCDebugContentViewController.h"

@interface CCDebugContentViewController ()

@property(nonatomic, weak) UITextView *contentTextView;

@end

@implementation CCDebugContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControl];
}

- (void)initNavigation
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(copyAction:)];
}

- (void)initControl
{
    UITextView *contentViewText = [[UITextView alloc] initWithFrame:self.view.bounds];
    [contentViewText setEditable:NO];
    contentViewText.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    contentViewText.font = [UIFont systemFontOfSize:13];
    contentViewText.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentViewText.text = self.content;
    [self.view addSubview:contentViewText];
    
    NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:13],
                                 NSParagraphStyleAttributeName : style};
    CGRect r = [self.content boundingRectWithSize:CGSizeMake(self.view.bounds.size.width, MAXFLOAT) options:option attributes:attributes context:nil];
    contentViewText.contentSize = CGSizeMake(self.view.bounds.size.width, r.size.height);
    
    self.contentTextView = contentViewText;
}

- (void)copyAction:(UIBarButtonItem *)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [self.content copy];
    
    self.contentTextView.text = [NSString stringWithFormat:@"%@\n\n%@", @"复制成功！", self.content];
    
    __weak typeof(self.contentTextView) weakTxt = self.contentTextView;
    __weak typeof(self) wSelf = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakTxt.text = wSelf.content;
    });
}


@end
