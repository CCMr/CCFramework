//
//  UISearchBar+Additions.h
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

@interface UISearchBar (Additions)

@property(copy, nonatomic) BOOL (^completionShouldBeginEditingBlock)(UISearchBar *searchbar);
@property(copy, nonatomic) void (^completionTextDidBeginEditingBlock)(UISearchBar *searchBar);
@property(copy, nonatomic) BOOL (^completionShouldEndEditingBlock)(UISearchBar *searchBar);
@property(copy, nonatomic) void (^completionTextDidEndEditingBlock)(UISearchBar *searchBar);
@property(copy, nonatomic) void (^completionTextDidChangeBlock)(UISearchBar *searchBar, NSString *searchText);
@property(copy, nonatomic) BOOL (^completionShouldChangeTextInRangeBlock)(UISearchBar *searchBar, NSRange range, NSString *replacementText);
@property(copy, nonatomic) void (^completionSearchButtonClickedBlock)(UISearchBar *searchBar);
@property(copy, nonatomic) void (^completionBookmarkButtonClickedBlock)(UISearchBar *searchBar);
@property(copy, nonatomic) void (^completionCancelButtonClickedBlock)(UISearchBar *searchBar);
@property(copy, nonatomic) void (^completionResultsListButtonClickedBlock)(UISearchBar *searchBar);
@property(copy, nonatomic) void (^completionSelectedScopeButtonIndexDidChangeBlock)(UISearchBar *searchBar, NSInteger selectedScope);

- (void)setCompletionShouldBeginEditingBlock:(BOOL (^)(UISearchBar *searchBar))searchBarShouldBeginEditingBlock;
- (void)setCompletionTextDidBeginEditingBlock:(void (^)(UISearchBar *searchBar))searchBarTextDidBeginEditingBlock;
- (void)setCompletionShouldEndEditingBlock:(BOOL (^)(UISearchBar *searchBar))searchBarShouldEndEditingBlock;
- (void)setCompletionTextDidEndEditingBlock:(void (^)(UISearchBar *searchBar))searchBarTextDidEndEditingBlock;
- (void)setCompletionTextDidChangeBlock:(void (^)(UISearchBar *searchBar, NSString *text))searchBarTextDidChangeBlock;
- (void)setCompletionShouldChangeTextInRangeBlock:(BOOL (^)(UISearchBar *searchBar, NSRange range, NSString *text))searchBarShouldChangeTextInRangeBlock;
- (void)setCompletionSearchButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarSearchButtonClickedBlock;
- (void)setCompletionBookmarkButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarBookmarkButtonClickedBlock;
- (void)setCompletionCancelButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarCancelButtonClickedBlock;
- (void)setCompletionResultsListButtonClickedBlock:(void (^)(UISearchBar *searchBar))searchBarResultsListButtonClickedBlock;
- (void)setCompletionSelectedScopeButtonIndexDidChangeBlock:(void (^)(UISearchBar *searchBar, NSInteger index))searchBarSelectedScopeButtonIndexDidChangeBlock;



/**
 *  @author CC, 2015-11-06
 *  
 *  @brief  设置取消按钮标题
 *
 *  @param title 标题
 */
- (void)setCancelTitle:(NSString *)title;

/**
 *  @author CC, 2015-11-06
 *  
 *  @brief  设置取消按钮文字与颜色
 *
 *  @param title 标题
 *  @param color 颜色
 */
- (void)setCancelTitleWithColor:(NSString *)title
                          Color:(UIColor *)color;

/**
 *  @author CC, 16-02-18
 *  
 *  @brief 设置输入框背景颜色
 *
 *  @param backgroundColor 颜色
 */
- (void)setSearchTextFieldBackgroundColor:(UIColor *)backgroundColor;

@end
