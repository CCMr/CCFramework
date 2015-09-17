//
//  CCWaterflowView.m
//  WaterfallsFlow
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

#import "CCWaterfallsFlow.h"

#define CCWaterflowViewDefaultNumberOfClunms 3
#define CCWaterflowViewDefaultCellH 100
#define CCWaterflowViewDefaultMargin 10

@interface CCWaterfallsFlow()

@property (strong,nonatomic) NSMutableArray *CellFrames;

@property (strong,nonatomic) NSMutableDictionary *displayingCells;

@property (strong,nonatomic) NSMutableSet *reusableCells;

@end

@implementation CCWaterfallsFlow

-(NSMutableArray *)CellFrames{
    if (!_CellFrames) {
        _CellFrames = [NSMutableArray array];
    }
    return _CellFrames;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(NSMutableDictionary *)displayingCells{
    if (!_displayingCells) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

-(NSMutableSet *)reusableCells{
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

-(CGFloat)cellWidth{
    int numverOfColumns = (int)[self numberOfColumns];
    CGFloat leftM = [self marginForType:CCWaterflowViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:CCWaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:CCWaterflowViewMarginTypeColumn];
    return (self.frame.size.width - leftM - rightM - (numverOfColumns - 1) * columnM) / numverOfColumns;
}

-(void)reloadData{
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.CellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    int numberOfCells = (int)[self.dataSource numberOfCellsInWaterflowView:self];
    
    int numberOfColumns = (int)[self numberOfColumns];
    
    CGFloat leftM = [self marginForType:CCWaterflowViewMarginTypeLeft];
//    CGFloat rightM = [self marginForType:CCWaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:CCWaterflowViewMarginTypeColumn];
    CGFloat topM = [self marginForType:CCWaterflowViewMarginTypeTop];
    CGFloat rowM = [self marginForType:CCWaterflowViewMarginTypeRow];
    CGFloat bottomM = [self marginForType:CCWaterflowViewMarginTypeBootm];
    
    //    CGFloat cellW = (self.frame.size.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
    CGFloat cellW = [self cellWidth];
    
    CGFloat maxYofColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxYofColumns[i] = 0.0;
    }
    
    for (int i = 0; i < numberOfCells; i++) {
        CGFloat cellH = [self heightAtIndex:i];
        NSUInteger cellAtColumn = 0;
        CGFloat maxYOfCellAtColumn = maxYofColumns[cellAtColumn];
        for (int j = 0; j < numberOfColumns; j++) {
            if (maxYofColumns[j] < maxYOfCellAtColumn) {
                cellAtColumn = j;
                maxYOfCellAtColumn = maxYofColumns[j];
            }
        }
        
        CGFloat cellX = leftM + cellAtColumn * (cellW + columnM);
        CGFloat cellY = 0;
        if (maxYOfCellAtColumn == 0.0) {
            cellY = topM;
        }else{
            cellY = maxYOfCellAtColumn + rowM;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.CellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        maxYofColumns[cellAtColumn] = CGRectGetMaxY(cellFrame);
    }
    
    CGFloat contentH = maxYofColumns[0];
    for (int i = 1; i < numberOfColumns; i++) {
        if (maxYofColumns[i] > contentH) {
            contentH = maxYofColumns[i];
        }
    }
    
    contentH += bottomM;
    self.contentSize = CGSizeMake(0, contentH);
    [self layoutSubviews];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSUInteger numberOfCells = self.CellFrames.count;
    for (int i = 0; i < numberOfCells; i++) {
        CGRect cellFrame = [self.CellFrames[i] CGRectValue];
        UITableViewCell *Cell = self.displayingCells[@(i)];
        Cell.userInteractionEnabled = YES;
        if ([self isInScreen:cellFrame]) {
            if (!Cell) {
                Cell = [self.dataSource waterflowView:self cellAtIndex:i];
                Cell.frame = cellFrame;
                if (!Cell.gestureRecognizers || Cell.gestureRecognizers.count > 0)
                    [Cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)]];
                [self addSubview:Cell];
                self.displayingCells[@(i)] = Cell;
            }
        }else{
            if (Cell) {
                [Cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                [self.reusableCells addObject:Cell];
            }
        }
    }
}

-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    __block UITableViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(UITableViewCell *cell, BOOL *stop) {
        if ([cell.reuseIdentifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

-(BOOL)isInScreen:(CGRect)frame{
    float max = CGRectGetMaxY(frame);
    return (max > self.contentOffset.y);
}

-(CGFloat)marginForType:(CCWaterflowViewMarginType)type{
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.wdelegate waterflowView:self marginForType:type];
    }else{
        return CCWaterflowViewDefaultMargin;
    }
}

-(NSUInteger)numberOfColumns{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSource numberOfColumnsInWaterflowView:self];
    }else{
        return CCWaterflowViewDefaultNumberOfClunms;
    }
}

-(CGFloat)heightAtIndex:(NSUInteger)index{
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.wdelegate waterflowView:self heightAtIndex:index];
    }else{
        return CCWaterflowViewDefaultCellH;
    }
}

-(void)cellTapped:(UITapGestureRecognizer *)tapRecognizer{
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)])
        return;
    
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, UITableViewCell *cell, BOOL *stop) {
        CGPoint point = [tapRecognizer locationInView:self];
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectIndex)
        [self.wdelegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)])
        return;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, UITableViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectIndex)
        [self.wdelegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
}
@end
