//
//  BaseTableViewCell.h
//  HomeImprovement
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

@class CCTableViewCell;

typedef enum {
    CCFeedStatusNormal = 0,
    CCFeedStatusLeftExpanded,
    CCFeedStatusLeftExpanding,
    CCFeedStatusRightExpanded,
    CCFeedStatusRightExpanding,
} CCFeedStatus;

typedef void (^didSelectedCell)(NSObject *requestData,BOOL IsError);

//委托
@protocol CCTableViewCellDelegate <NSObject>
@optional
- (void)didShowBaseCellImage:(NSMutableDictionary *) ImageDic;

- (void)didCellMenu:(CCTableViewCell *)Cell MenuIndex:(NSInteger)index RowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  @author CC, 2015-06-19 08:06:24
 *
 *  @brief  隐藏菜单
 *
 *  @param cell <#cell description#>
 *
 *  @since 1.0
 */
-(void)CellDidReveal:(CCTableViewCell *)cell;

@end

@interface CCTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>

-(id)initWithMenu:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
/**
 *  从nib初始化  edit by lpx
 */
- (instancetype)initWithNib;


@property (nonatomic, weak) id<CCTableViewCellDelegate> delegate;
@property (nonatomic, copy) didSelectedCell didSelected;
@property (nonatomic, retain) NSMutableArray *LeftMenuButton; // Container on the left Dialogue (where to put your UI elements)
@property (nonatomic, retain) NSMutableArray *RightMenuButton; // Container on the right dialogue (where to put your UI elements)
@property (nonatomic, assign) CCFeedStatus currentStatus;
@property (nonatomic, assign) BOOL revealing;
@property (nonatomic, assign) BOOL beLine;
//设置Cell数据
-(void)setDatas:(NSObject *) objDatas;
-(void)SetDatas:(NSArray *) ArDatas;
-(void)setDatas:(NSObject *)objDatas RowAtIndexPath:(NSIndexPath *)indexPath;
-(void)setDatas:(NSObject *) objDatas didSelectedBlock:(didSelectedCell)seletedBlock;
-(void)SetDatas:(NSArray *) ArDatas didSelectedBlock:(didSelectedCell)seletedBlock;

@end

#pragma mark - Cell添加按钮
@interface NSMutableArray (CellButtons)

+(id)addCellButtonArray:(id)fistObject,...;

-(void)addCellButton:(UIColor *)color Title:(NSString *)title RowAtIndexPath:(NSIndexPath *)indexPath;
-(void)addCellButton:(UIColor *)color Icon:(NSString *)icon RowAtIndexPath:(NSIndexPath *)indexPath;

@end
