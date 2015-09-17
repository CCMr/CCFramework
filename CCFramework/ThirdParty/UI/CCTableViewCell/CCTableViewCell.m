//
//  BaseTableViewCell.m
//  BaseTableViewCell
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

#import "CCTableViewCell.h"
#import <UIKit/UIKit.h>
#import "Config.h"
#import "UIControl+BUIControl.h"
#import "UIButton+BUIButton.h"

#define kMinimumVelocity  self.contentView.frame.size.width*1.5
#define kMinimumPan       60.0
#define kBOUNCE_DISTANCE  7.0

#define kUtilityButtonsWidthMax 260
#define kUtilityButtonWidthDefault 60

typedef enum {
    CCFeedCellDirectionNone=0,
    CCFeedCellDirectionRight,
    CCFeedCellDirectionLeft,
} CCFeedCellDirection;

@interface CCTableViewCell ()

@property (nonatomic,retain) UIView *bottomRightView;
@property (nonatomic,retain) UIView *bottomLeftView;
@property (nonatomic,retain) UIView *line;
//flag
@property (nonatomic,retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic,assign) CGFloat initialHorizontalCenter;
@property (nonatomic,assign) CGFloat initialTouchPositionX;

@property (nonatomic,assign) CCFeedCellDirection lastDirection;
@property (nonatomic,assign) CGFloat originalCenter;

@property (nonatomic, assign) BOOL hasRegisterKVO;

@end

@implementation CCTableViewCell

@synthesize LeftMenuButton,RightMenuButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

/**
 *  从xib初始化的方法
 *
 */
- (instancetype)initWithNib
{
    NSString *nibName = NSStringFromClass([self class]);
    self = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil].lastObject;
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_line];
        _originalCenter = ceil(winsize.width / 2);
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
        _panGesture.delegate = self;
        [self addGestureRecognizer:_panGesture];
        
        [self registerForKVO];
    }
    return self;
}


-(id)initWithMenu:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_line];
        _originalCenter = ceil(winsize.width / 2);
        
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
        _panGesture.delegate = self;
        [self addGestureRecognizer:_panGesture];
        
        [self registerForKVO];
    }
    return self;
}

//设置Cell数据
-(void)setDatas:(NSObject *)objDatas{
    
}

-(void)SetDatas:(NSArray *)objDatas{
    
}

-(void)setDatas:(NSObject *)objDatas RowAtIndexPath:(NSIndexPath *)indexPath{
    
}

//设置Cell数据 并且有回调方法
-(void)setDatas:(NSObject *)objDatas didSelectedBlock:(didSelectedCell)seletedBlock{
    self.didSelected = seletedBlock;
}

-(void)SetDatas:(NSArray *)objDatas didSelectedBlock:(didSelectedCell)seletedBlock{
    self.didSelected = seletedBlock;
}

- (void)awakeFromNib{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}

- (void)panGestureHandle:(UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _initialTouchPositionX = [recognizer locationInView:self].x;
        _initialHorizontalCenter = self.contentView.center.x;
        if(_currentStatus == CCFeedStatusNormal){
            [self layoutBottomView];
        }
    }else if (recognizer.state == UIGestureRecognizerStateChanged) { //status change
        CGFloat panAmount = _initialTouchPositionX - [recognizer locationInView:self].x;
        CGFloat newCenterPosition = _initialHorizontalCenter - panAmount;
        CGFloat centerX = self.contentView.center.x;
        
        if(centerX >_originalCenter && _currentStatus != CCFeedStatusLeftExpanding){
            _currentStatus = CCFeedStatusLeftExpanding;
            [self togglePanelWithFlag];
        }else if(centerX < _originalCenter && _currentStatus != CCFeedStatusRightExpanding){
            _currentStatus = CCFeedStatusRightExpanding;
            [self togglePanelWithFlag];
        }
        
        if (panAmount > 0){ //RigthMenu
            if (!RightMenuButton){
                if (!self.revealing)
                    return;
            }
            _lastDirection = CCFeedCellDirectionLeft;
        }else{ //LeftMenu
            if (!LeftMenuButton){
                if (!self.revealing)
                    return;
            }
            _lastDirection = CCFeedCellDirectionRight;
        }
        
        if (newCenterPosition > self.bounds.size.width + _originalCenter)
            newCenterPosition = self.bounds.size.width + _originalCenter;
        else if (newCenterPosition < -_originalCenter)
            newCenterPosition = -_originalCenter;
        
        CGPoint center = self.contentView.center;
        center.x = newCenterPosition;
        self.contentView.layer.position = center;
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
        CGPoint translation = [recognizer translationInView:self];
        CGFloat velocityX = [recognizer velocityInView:self].x;
        
        if (_initialTouchPositionX - velocityX > 0){ //RigthMenu
            if (!RightMenuButton){
                if (!self.revealing)
                    return;
            }
        }else{ //LeftMenu
            if (!LeftMenuButton){
                if (!self.revealing)
                    return;
            }
        }
        
        //判断是否push view
        BOOL isNeedPush = (fabs(velocityX) > kMinimumVelocity);
        
        isNeedPush |= ((_lastDirection == CCFeedCellDirectionLeft && translation.x < -kMinimumPan) || (_lastDirection== CCFeedCellDirectionRight && translation.x > kMinimumPan));
        
        if (velocityX > 0 && _lastDirection == CCFeedCellDirectionLeft)
            isNeedPush = NO;
        else if (velocityX < 0 && _lastDirection == CCFeedCellDirectionRight)
            isNeedPush = NO;
        
        if (isNeedPush && !self.revealing) {
            if(_lastDirection == CCFeedCellDirectionRight){
                _currentStatus = CCFeedStatusLeftExpanding;
                [self togglePanelWithFlag];
            }else{
                _currentStatus = CCFeedStatusRightExpanding;
                [self togglePanelWithFlag];
            }
            
            [self _slideOutContentViewInDirection:_lastDirection];
            [self _setRevealing:YES];
        }else if (self.revealing && translation.x != 0) {
            CCFeedCellDirection direct = _currentStatus == CCFeedStatusRightExpanding ? CCFeedCellDirectionLeft : CCFeedCellDirectionRight;
            [self _slideInContentViewFromDirection:direct];
            [self _setRevealing:NO];
        }else if (translation.x != 0) {
            // Figure out which side we've dragged on.
            CCFeedCellDirection finalDir = CCFeedCellDirectionRight;
            if (translation.x < 0)
                finalDir = CCFeedCellDirectionLeft;
            [self _slideInContentViewFromDirection:finalDir];
            [self _setRevealing:NO];
        }
    }
}

#pragma mark -
#pragma mark revealing setter
- (void)setRevealing:(BOOL)revealing{
    if (_revealing == revealing)
        return;
    [self _setRevealing:revealing];
    
    if (self.revealing)
        [self _slideOutContentViewInDirection:_lastDirection];
    else
        [self _slideInContentViewFromDirection:_lastDirection];
}

- (void)_setRevealing:(BOOL)revealing{
    _revealing = revealing;
    if (self.revealing && [self.delegate respondsToSelector:@selector(CellDidReveal:)])
        [self.delegate CellDidReveal:self];
}

- (void)_slideInContentViewFromDirection:(int)direction{
    CGFloat bounceDistance = 0;
    if (self.contentView.center.x == _originalCenter)
        return;
    
    switch (direction) {
        case CCFeedCellDirectionRight:
            bounceDistance = kBOUNCE_DISTANCE;
            break;
        case CCFeedCellDirectionLeft:
            bounceDistance = -kBOUNCE_DISTANCE;
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
        self.contentView.center = CGPointMake(_originalCenter, self.contentView.center.y);
    } completion:^(BOOL f) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.contentView.frame = CGRectOffset(self.contentView.frame, bounceDistance, 0);
        }completion:^(BOOL f) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.contentView.frame = CGRectOffset(self.contentView.frame, -bounceDistance, 0);
            } completion:^(BOOL f){
            }];
        }];
    }];
}

- (void)_slideOutContentViewInDirection:(int)direction{
    CGFloat newCenterX = 0;
    CGFloat bounceDistance;
    switch (direction) {
        case CCFeedCellDirectionLeft:{
            newCenterX = -([self buttonsWidth:RightMenuButton] - self.contentView.frame.size.width / 2);
            bounceDistance = -kBOUNCE_DISTANCE;
            _currentStatus = CCFeedStatusLeftExpanded;
        }
            break;
        case CCFeedCellDirectionRight:{
            newCenterX = self.contentView.frame.size.width / 2 + [self buttonsWidth:LeftMenuButton];
            bounceDistance = kBOUNCE_DISTANCE;
            _currentStatus = CCFeedStatusRightExpanded;
        }
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.center = CGPointMake(newCenterX, self.contentView.center.y);
    } completion:^(BOOL f) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.contentView.frame = CGRectOffset(self.contentView.frame, -bounceDistance, 0);
        } completion:^(BOOL f) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.contentView.frame = CGRectOffset(self.contentView.frame, bounceDistance, 0);
            }completion:NULL];
        }];
    }];
}

- (void)togglePanelWithFlag{
    switch (_currentStatus) {
        case CCFeedStatusLeftExpanding:
            _bottomRightView.alpha = 0.0f;
            _bottomLeftView.alpha = 1.0f;
            break;
        case CCFeedStatusRightExpanding:
            _bottomRightView.alpha = 1.0f;
            _bottomLeftView.alpha = 0.0f;
            break;
        case CCFeedStatusNormal:
            [_bottomRightView removeFromSuperview];
            self.bottomRightView = nil;
            [_bottomLeftView removeFromSuperview];
            self.bottomLeftView = nil;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == _panGesture) {
        UIScrollView *superview = (UIScrollView *)self.superview;
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:superview];
        // Make it scrolling horizontally
        return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : /* DISABLES CODE */ (NO) && (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
    }
    return YES;
}

- (void)dealloc
{
    [self unregisterFromKVO];
}

#pragma mark - KVO
- (void)registerForKVO {
    _hasRegisterKVO = YES;
    for (NSString *keyPath in [self observableKeypaths])
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterFromKVO {
    if(_hasRegisterKVO){
        for (NSString *keyPath in [self observableKeypaths])
            [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"RightMenuButton", @"LeftMenuButton", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread])
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    else
        [self updateUIForKeypath:keyPath];
}

- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"RightMenuButton"] || [keyPath isEqualToString:@"LeftMenuButton"]){
        [self layoutBottomView];
        if (RightMenuButton)
            [self populateBttons:_bottomRightView ButtonArray:RightMenuButton];
        if(LeftMenuButton)
            [self populateBttons:_bottomLeftView ButtonArray:LeftMenuButton];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - 菜单UI
-(void)layoutBottomView{
    if(!self.bottomRightView){
        _bottomRightView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self insertSubview:_bottomRightView atIndex:0];
    }
    
    if(!self.bottomLeftView){
        _bottomLeftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self insertSubview:_bottomLeftView atIndex:0];
    }
}

#pragma mark - MeunButton
//计算宽度
-(CGFloat)calculateButtonWidth:(NSMutableArray *)utilityArray{
    CGFloat buttonWidth = kUtilityButtonWidthDefault;
    if (buttonWidth * utilityArray.count > kUtilityButtonsWidthMax) {
        CGFloat buffer = (buttonWidth * utilityArray.count) - kUtilityButtonsWidthMax;
        buttonWidth -= (buffer / utilityArray.count);
    }
    return buttonWidth;
}

-(CGFloat)buttonsWidth:(NSMutableArray *)utilityArray{
    return (utilityArray.count * [self calculateButtonWidth:utilityArray]);
}

//调整按钮位置初始化事件
-(void)populateBttons:(UIView *)MenuView ButtonArray:(NSMutableArray *)utilityArray{
    NSUInteger buttonCounter = 0;
    CGFloat buttonW = [self calculateButtonWidth:utilityArray];
    for (UIButton *btn in utilityArray) {
        CGFloat utilityButtonXCord = 0;
        if (buttonCounter >= 1)
            utilityButtonXCord = buttonW * buttonCounter;
        
        if ([utilityArray isEqual:RightMenuButton])
            utilityButtonXCord = self.bounds.size.width - (buttonCounter + 1) * buttonW;
        
        [btn setFrame:CGRectMake(utilityButtonXCord, 0, buttonW, CGRectGetHeight(self.bounds))];
        [btn setTag:buttonCounter];
        
        __weak typeof (self)weakSelf = self;
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            if ([weakSelf.delegate respondsToSelector:@selector(didCellMenu:MenuIndex:RowAtIndexPath:)])
                [weakSelf.delegate didCellMenu:self MenuIndex:btn.tag RowAtIndexPath:(NSIndexPath *)btn.carryObjects];
        }];
        [MenuView addSubview: btn];
        buttonCounter++;
    }
}


-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    CGFloat RightShift;
    CGRect frame = _bottomLeftView.frame;
    frame.size.height = size.height;
    frame.size.width = size.width;
    _bottomLeftView.frame = frame;
    
    frame = _bottomRightView.frame;
    RightShift = size.width - frame.size.width;
    frame.size.height = size.height;
    frame.size.width = size.width;
    _bottomRightView.frame = frame;
    
    for (UIView * v in _bottomLeftView.subviews) {
        frame = v.frame;
        frame.size.height = size.height;
        v.frame = frame;
    }
    
    for (UIView *v in _bottomRightView.subviews) {
        frame = v.frame;
        frame.origin.x += RightShift;
        frame.size.height = size.height;
        v.frame = frame;
    }
    
    if (_beLine) {
        _line.frame = CGRectMake(10, self.frame.size.height, winsize.width-20, .5);
    }
}
@end

#pragma mark - NSMuTableArray CellButton
@implementation NSMutableArray (CellButtons)

+(id)addCellButtonArray:(id)fistObject, ...{
    NSMutableArray *array = [NSMutableArray array];
    id eachObject;
    va_list argumentList;
    if (fistObject) {
        va_start(argumentList, fistObject);
        while ((eachObject = va_arg(argumentList, id))) {
            [array addObject:eachObject];
            va_end(argumentList);
        }
    }
    return array;
}

-(void)addCellButton:(UIColor *)color Title:(NSString *)title RowAtIndexPath:(NSIndexPath *)indexPath{
    UIButton *btn = [UIButton buttonWithTitle:title];
    btn.backgroundColor = color;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btn setCarryObjects:indexPath];
    [self addObject:btn];
}

-(void)addCellButton:(UIColor *)color Icon:(NSString *)icon RowAtIndexPath:(NSIndexPath *)indexPath{
    UIButton *btn = [UIButton buttonWith];
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn.imageView setContentMode:UIViewContentModeScaleAspectFill];
    btn.backgroundColor = color;
    [btn setCarryObjects:indexPath];
    [self addObject:btn];
}

@end
