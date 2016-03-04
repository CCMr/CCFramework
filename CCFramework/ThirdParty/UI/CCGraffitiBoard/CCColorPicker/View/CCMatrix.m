//
//  CCMatrix.m
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

#import "CCMatrix.h"
#import "UIView+Frame.h"

@implementation CCMatrix

- (void) setRows:(NSUInteger)inRows
{
    _rows = inRows;
    [self setNeedsLayout];
}

- (void) setColumns:(NSUInteger)inColumns
{
    _columns = inColumns;
    [self setNeedsLayout];
}

- (void) setCellViews:(NSArray *)inCellViews
{
    // remove old cells
    for (UIView *cell in _cellViews) {
        [cell removeFromSuperview];
    }
    
    // release old and retain new
    _cellViews = inCellViews;
    
    // add the new cells to the view
    for (UIView *cell in _cellViews) {
        [self addSubview:cell];
    }
    
    [self setNeedsLayout];
}

- (void) layoutSubviews
{
    UIView *canonicalCell = [_cellViews lastObject];
    CGSize cellSize = canonicalCell.frame.size;
    
    float halfCellWidth = cellSize.width / 2.0f;
    float halfCellHeight = cellSize.height / 2.0f;
    
    float xOffset = (CGRectGetWidth(self.bounds) - (_columns * cellSize.width)) / (_columns + 1);
    xOffset += halfCellWidth;
    float yOffset = (CGRectGetHeight(self.bounds) - (_rows * cellSize.height)) / (_rows + 1);
    yOffset += halfCellHeight;
    
    float xSpacing = xOffset + halfCellWidth;
    float ySpacing = yOffset + halfCellHeight;
    
    NSEnumerator *oe = [_cellViews objectEnumerator];
    
    for (int y = 0; y < _rows; y++) {
        for (int x = 0; x < _columns; x++) {
            UIView *cell = [oe nextObject];
            cell.sharpCenter = CGPointMake(xOffset + x * xSpacing, yOffset + y * ySpacing);
        }
    }
}


@end
