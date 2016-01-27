//
//  CCBannerFooter.m
//  CCFramework
//
//  Created by CC on 16/1/27.
//  Copyright © 2016年 CC. All rights reserved.
//

#import "CCBannerFooter.h"
#import "config.h"

#define kCCArrowSide 15.f

@implementation CCBannerFooter

@synthesize idleTitle = _idleTitle;
@synthesize triggerTitle = _triggerTitle;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.arrowView];
        [self addSubview:self.label];
        
        self.arrowView.image = CCResourceImage(@"banner_arrow");
        self.state = CCBannerFooterStateIdle;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat arrowX = self.bounds.size.width / 2 - kCCArrowSide - 2;
    CGFloat arrowY = self.bounds.size.height / 2 - kCCArrowSide / 2;
    CGFloat arrowW = kCCArrowSide;
    CGFloat arrowH = kCCArrowSide;
    self.arrowView.frame = CGRectMake(arrowX, arrowY, arrowW, arrowH);
    
    CGFloat labelX = self.bounds.size.width / 2 + 2;
    CGFloat labelY = 0;
    CGFloat labelW = kCCArrowSide;
    CGFloat labelH = self.bounds.size.height;
    self.label.frame = CGRectMake(labelX, labelY, labelW, labelH);
}

#pragma mark - setters & getters

- (void)setState:(CCBannerFooterState)state
{
    _state = state;
    
    switch (state) {
        case CCBannerFooterStateIdle: {
            self.label.text = self.idleTitle;
            [UIView animateWithDuration:0.3 animations:^{
                self.arrowView.transform = CGAffineTransformMakeRotation(0);
            }];
            
        } break;
        case CCBannerFooterStateTrigger: {
            self.label.text = self.triggerTitle;
            [UIView animateWithDuration:0.3 animations:^{
                self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        } break;
            
        default:
            break;
    }
}

- (UIImageView *)arrowView
{
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
    }
    return _arrowView;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:13];
        _label.textColor = [UIColor darkGrayColor];
        _label.numberOfLines = 0;
    }
    return _label;
}

- (void)setIdleTitle:(NSString *)idleTitle
{
    _idleTitle = idleTitle;
    
    if (self.state == CCBannerFooterStateIdle) {
        self.label.text = idleTitle;
    }
}

- (NSString *)idleTitle
{
    if (!_idleTitle)
        _idleTitle = @"拖动查看详情"; // default
    return _idleTitle;
}

- (void)setTriggerTitle:(NSString *)triggerTitle
{
    _triggerTitle = triggerTitle;
    
    if (self.state == CCBannerFooterStateTrigger)
        self.label.text = triggerTitle;
}

- (NSString *)triggerTitle
{
    if (!_triggerTitle)
        _triggerTitle = @"释放查看详情"; // default
    return _triggerTitle;
}

@end
