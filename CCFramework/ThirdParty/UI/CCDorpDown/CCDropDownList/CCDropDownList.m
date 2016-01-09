//
//  CCDropDownList.m
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

#import "CCDropDownList.h"
#import "CCDropDownListMenuItemView.h"

@implementation CCDropDownListItem

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.image = image;
        self.title = title;
    }
    return self;
}

@end

#pragma mark -_- CCDropDownList

@interface CCDropDownList () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) UIView *menuContainerView;

@property(nonatomic, strong) UITableView *menuTableView;
@property(nonatomic, strong) NSArray *menus;

@property(nonatomic, weak) UIView *currentSuperView;
@property(nonatomic, assign) CGPoint targetPoint;

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, assign) CGFloat fromTheHeight;

/**
 *  @author CC, 2015-11-04
 *  
 *  @brief  显示父类视图
 */
@property(nonatomic, strong) UIView *viewSender;

/**
 *  @author CC, 2015-11-04
 *  
 *  @brief  动画方向
 */
@property(nonatomic, assign) DorpDownListType animationDirection;

@end

@implementation CCDropDownList

- (void)showMenuOnView:(UIView *)view
               atPoint:(CGPoint)point
{
    self.currentSuperView = view;
    self.targetPoint = point;
    [self showMenu];
}

#pragma mark - animation

- (void)showMenu
{
    if (![self.currentSuperView.subviews containsObject:self]) {
        self.alpha = 0.0;
        
        if ([self.currentSuperView isKindOfClass:[UIWindow class]]) {
            [self layoutSubviews];
        }
        [self.currentSuperView addSubview:self];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 1.0;
            
            if (self.animationDirection == DorpDownListTypeDown) {
                self.menuContainerView.frame = CGRectMake(self.viewSender.frame.origin.x, self.viewSender.frame.origin.y + self.viewSender.frame.size.height, self.viewSender.frame.size.width, self.fromTheHeight);
            }else if (self.animationDirection == DorpDownListTypeUP){
                self.menuContainerView.frame = CGRectMake(self.viewSender.frame.origin.x, self.viewSender.frame.origin.y - self.fromTheHeight, self.viewSender.frame.size.width, self.fromTheHeight);
            }
            self.menuTableView.frame = CGRectMake(0, 0, self.viewSender.frame.size.width, self.fromTheHeight);
        } completion:^(BOOL finished){
            
        }];
    } else {
        [self dissMissPopMenuAnimatedOnMenuSelected:NO];
    }
}

- (void)dissMissPopMenuAnimatedOnMenuSelected:(BOOL)selected
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
        
        if (self.animationDirection == DorpDownListTypeDown) {
            self.menuContainerView.frame = CGRectMake(self.viewSender.frame.origin.x, self.viewSender.frame.origin.y + self.viewSender.frame.size.height, self.viewSender.frame.size.width, 0);
        }else if (self.animationDirection == DorpDownListTypeUP){
            self.menuContainerView.frame = CGRectMake(self.viewSender.frame.origin.x, self.viewSender.frame.origin.y, self.viewSender.frame.size.width, 0);
        }
        self.menuTableView.frame = CGRectMake(0, 0, self.viewSender.frame.size.width,0);
        
    } completion:^(BOOL finished) {
        if (selected) {
            if (self.dropDownMenuDidDismissCompled) {
                self.dropDownMenuDidDismissCompled(self.indexPath.row, self.menus[self.indexPath.row]);
            }
        }
        [super removeFromSuperview];
    }];
}

#pragma mark - Propertys

- (UIView *)menuContainerView
{
    if (!_menuContainerView) {
        
        CGRect frame = CGRectMake(self.viewSender.frame.origin.x, self.viewSender.frame.origin.y, self.viewSender.frame.size.width, 0);
        if (self.animationDirection == DorpDownListTypeDown)
            frame = CGRectMake(self.viewSender.frame.origin.x, self.viewSender.frame.origin.y + self.viewSender.frame.size.height, self.viewSender.frame.size.width, 0);
        
        _menuContainerView = [[UIView alloc] initWithFrame:frame];
        _menuContainerView.backgroundColor = [UIColor whiteColor];
        _menuContainerView.layer.cornerRadius = 5;
        _menuContainerView.layer.masksToBounds = YES;
        _menuContainerView.userInteractionEnabled = YES;
        
        [_menuContainerView addSubview:self.menuTableView];
    }
    return _menuContainerView;
}

- (UITableView *)menuTableView
{
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.viewSender.frame.size.width, 0) style:UITableViewStylePlain];
        _menuTableView.backgroundColor = [UIColor clearColor];
        _menuTableView.separatorColor = [UIColor clearColor];
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        _menuTableView.rowHeight = self.menuItemViewHeight;
        _menuTableView.scrollEnabled = NO;
    }
    return _menuTableView;
}

/**
 *  @author CC, 2015-10-16
 *
 *  @brief  设置菜单文字颜色
 *
 *  @param menuItemTextColor 颜色值
 */
- (void)setMenuItemTextColor:(UIColor *)menuItemTextColor
{
    _menuItemTextColor = menuItemTextColor;
    [self.menuTableView reloadData];
}

/**
 *  @author CC, 2015-10-16
 *
 *  @brief  设置菜单栏背景颜色
 *
 *  @param menuBackgroundColor 颜色值
 */
- (void)setMenuBackgroundColor:(UIColor *)menuBackgroundColor
{
    _menuContainerView.backgroundColor = menuBackgroundColor;
}

/**
 *  @author CC, 2015-11-04
 *  
 *  @brief  行高
 *
 *  @param menuItemViewHeight 高度
 */
- (void)setMenuItemViewHeight:(CGFloat)menuItemViewHeight
{
    _menuItemViewHeight = menuItemViewHeight;
    [self.menuTableView reloadData];
}

- (void)setup
{
    self.menuItemViewHeight = 40;
    self.menuItemTextColor = [UIColor blackColor];
    CGFloat height = self.menus.count * self.menuItemViewHeight;
    
    self.fromTheHeight = height < 160 ?: height;
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    [self addSubview:self.menuContainerView];
}

- (id)initWithMenus:(NSArray *)menus
{
    if (self = [super init]) {
        self.menus = [[NSMutableArray alloc] initWithArray:menus];
        [self setup];
    }
    return self;
}

- (instancetype)initDropDownListWithMenus:(UIView *)dropDownView
                                withMenus:(NSArray *)menus
                       animationDirection:(DorpDownListType)direction
{
    if (self = [super init]) {
        self.viewSender = dropDownView;
        self.menus = menus;
        _animationDirection = direction;
        [self setup];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint localPoint = [touch locationInView:self];
    if (CGRectContainsPoint(_menuContainerView.frame, localPoint)) {
        [self hitTest:localPoint withEvent:event];
    } else {
        [self dissMissPopMenuAnimatedOnMenuSelected:NO];
    }
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cellIdentifer";
    CCDropDownListMenuItemView *dropDownMenuItemView = (CCDropDownListMenuItemView *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!dropDownMenuItemView) {
        dropDownMenuItemView = [[CCDropDownListMenuItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    
    if (indexPath.row < self.menus.count) {
        [dropDownMenuItemView setupDorpDownMenuItem:self.menus[indexPath.row] atIndexPath:indexPath isBottom:(indexPath.row == self.menus.count - 1)];
    }
    
    dropDownMenuItemView.textLabel.textColor = self.menuItemTextColor;
    
    return dropDownMenuItemView;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.indexPath = indexPath;
    [self dissMissPopMenuAnimatedOnMenuSelected:YES];
    if (self.dropDownMenuDidSelectedCompled) {
        self.dropDownMenuDidSelectedCompled(indexPath.row, self.menus[indexPath.row]);
    }
}



@end
