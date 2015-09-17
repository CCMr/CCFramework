//
//  CCSideMenu.h
//  CCSideMenu
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
#import <QuartzCore/QuartzCore.h>
#import "CCBackgroundView.h"
#import "CCSideMenuCell.h"
#import "CCSideMenuItem.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface CCSideMenu : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (strong, readwrite, nonatomic) NSDictionary *items;
@property (assign, readwrite, nonatomic) CGFloat verticalOffset;
@property (assign, readwrite, nonatomic) CGFloat horizontalOffset;
@property (assign, readwrite, nonatomic) CGFloat itemHeight;
@property (strong, readwrite, nonatomic) UIFont *font;
@property (strong, readwrite, nonatomic) UIColor *textColor;
@property (strong, readwrite, nonatomic) UIColor *highlightedTextColor;
@property (strong, readwrite, nonatomic) UIImage *backgroundImage;
@property (assign, readwrite, nonatomic) BOOL hideStatusBarArea;
@property (assign, readwrite, nonatomic) BOOL isShowing;
@property (nonatomic, retain) UIView *containerView;
@property (assign, readwrite, nonatomic) BOOL isSide;

- (id)initWithItems:(NSDictionary *)items;

- (void)show;
- (void)hide;
- (void)setRootViewController:(UIViewController *)viewController;

@end
