//
//  FriendGroup.h
//  CCFramework
//
//  Created by kairunyun on 15/3/6.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FriendGroup : NSObject

@property (nonatomic, copy) NSString *Title;

@property (nonatomic, copy) NSString *Content;

@property (nonatomic, copy) UIColor *ContentColor;

@property (nonatomic, copy) NSString *RightContent;

@property (nonatomic, copy) NSString *IsImageType;

@property (nonatomic, copy) NSString *ImageAddress;

@property (nonatomic, copy) NSString *ImageAddressDeputy;

@property (nonatomic, strong) NSArray *friends;

@property (nonatomic, strong) NSArray *ImageArray;

@property (nonatomic, strong) NSString *itemname;//

@property (nonatomic, strong) NSString *itemdynamic;//关联单据内容

@property (nonatomic, assign) NSInteger itemdisplaytype;//配置UI类型

@property (nonatomic, assign) BOOL IsEditor;//是否可以编辑

@property (nonatomic, assign) BOOL rightImage;

@property (nonatomic, assign) BOOL leftImage;

@property (nonatomic, assign) BOOL IsWiden;

@property (nonatomic, assign) BOOL IsContent;

@property (nonatomic, assign) BOOL isflow;

@property (nonatomic, assign) BOOL required;

@property (nonatomic, assign, getter = isOpened) BOOL opened;

@property (nonatomic, assign) BOOL isannex;

+ (instancetype)friendGroupWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
