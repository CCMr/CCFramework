//
//  CCDelegateProxy.h
//  CCFramework
//
//  Created by CC on 15/11/12.
//  Copyright © 2015年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCDelegateProxy : NSObject

/**
 *  @author CC, 2015-11-12
 *  
 *  @brief  创建一个委托代理能够冲'protocol'响应选择
 *
 *  @param protocol <#protocol description#>
 *
 *  @return <#return value description#>
 */
- (instancetype)initWithProtocol:(Protocol *)protocol;

@property(nonatomic, unsafe_unretained) id cc_proxiedDelegate;

@end
