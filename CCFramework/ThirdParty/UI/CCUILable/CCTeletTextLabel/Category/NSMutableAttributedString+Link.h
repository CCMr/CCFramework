//
//  NSMutableAttributedString+Link.h
//  CCFramework
//
//  Created by CC on 16/7/19.
//  Copyright © 2016年 CC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableAttributedString (Link)

- (NSArray *)analysisLinkColor:(UIColor *)linkColor
                      linkFont:(UIFont *)linkFont;

- (NSArray *)analysisLinkRegexps:(NSArray *)allRegexps
                         Regexps:(NSArray *)regexps
                           Links:(NSArray *)links
                       linkColor:(UIColor *)linkColor
                        linkFont:(UIFont *)linkFont;

@end
