//
//  UITableViewCell+Additions.m
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

#import "UITableViewCell+Additions.h"

@implementation UITableViewCell (Additions)
/**
 *  @brief  加载同类名的nib
 *
 *  @return nib
 */
+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (UINib *)nibWithIdentifier:(NSString *)identifier
{
    return [UINib nibWithNibName:identifier bundle:nil];
}

+ (void)registerTable:(UITableView *)tableView
        nibIdentifier:(NSString *)identifier
{
    UINib *nib = [self nibWithIdentifier:identifier];
    if (nib)
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
    else
        [tableView registerClass:NSClassFromString(identifier) forCellReuseIdentifier:identifier];
}

- (void)configure:(UITableViewCell *)tableViewCell
        customObj:(id)obj
        indexPath:(NSIndexPath *)indexPath
{
    // Rewrite this func in SubClass !
}

- (void)cc_cellWillDisplayWithModel:(id)cModel
                          indexPath:(NSIndexPath *)cIndexPath
{
    // Rewrite this func in SubClass !
}

+ (CGFloat)obtainCellHeightWithCustomObj:(id)obj
                               indexPath:(NSIndexPath *)indexPath
{
    // Rewrite this func in SubClass if necessary
    if (!obj) {
        return 0.0f; // if obj is null .
    }
    return 44.0f; // default cell height
}


- (UIScrollView *)cc_scrollView
{
    id sv = self.contentView.superview;
    while (![sv isKindOfClass:[UIScrollView class]] && sv != self) {
        sv = [sv superview];
    }
    
    return sv == self ? nil : sv;
}

- (void)setCc_delaysContentTouches:(BOOL)delaysContentTouches
{
    [self willChangeValueForKey:@"ts_delaysContentTouches"];
    
    [[self cc_scrollView] setDelaysContentTouches:delaysContentTouches];
    
    [self didChangeValueForKey:@"ts_delaysContentTouches"];
}

- (BOOL)cc_delaysContentTouches
{
    return [[self cc_scrollView] delaysContentTouches];
}

@end
