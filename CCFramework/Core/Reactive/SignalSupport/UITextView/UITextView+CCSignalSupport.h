//
//  UITextView+CCSignalSupport.h
//  CCFramework
//
//  Created by CC on 15/11/12.
//  Copyright © 2015年 CC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCDelegateProxy;

@interface UITextView (CCSignalSupport)
/**
 *  @author CC, 2015-11-12
 *  
 *  @brief  委托代理，它会在任何这一类的方法用于被设置为接收器的代表。
 */
@property (nonatomic, strong, readonly) CCDelegateProxy *cc_delegateProxy;



@end
