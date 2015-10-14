//
//  ContactPersonEntity.h
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

#import <CCFramework/CCFramework.h>
#import <AddressBook/AddressBook.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactPersonEntity : BaseEntity

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  显示名称
 */
@property (nonatomic, copy) NSString * displayName;
/**
 *  @author CC, 2015-10-10
 *
 *  @brief  详细文本
 */
@property (nonatomic, copy) NSString * detailText;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  名字
 */
@property (nonatomic, copy) NSString * firstname;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  昵称
 */
@property (nonatomic, copy) NSString * nickname;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  姓
 */
@property (nonatomic, copy) NSString * lastname;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  街道1
 */
@property (nonatomic, copy) NSString * street1;
/**
 *  @author CC, 2015-10-10
 *
 *  @brief  街道2
 */
@property (nonatomic, copy) NSString * street2;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  城市
 */
@property (nonatomic, copy) NSString * city;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  状态
 */
@property (nonatomic, copy) NSString * state;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  邮编
 */
@property (nonnull, copy, nonatomic) NSString * zip;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  国家
 */
@property (nonatomic, copy) NSString * country;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  国家编号
 */
@property (nonatomic, copy) NSString *countryCode;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  公司
 */
@property (nonatomic, copy) NSString * company;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  网址
 */
@property (nonatomic, copy) NSArray * urls;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  生日
 */
@property (nonatomic, copy) NSDate * birthday;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  地址
 */
@property (nonatomic, copy) NSArray * address;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  手机
 */
@property (nonatomic, copy) NSArray * phones;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  电子邮件
 */
@property (nonatomic, copy) NSArray * emails;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  照片
 */
@property (nonatomic, copy) UIImage * photo;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  头像
 */
@property (nonatomic, copy) UIImage * thumb;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  记录ID
 */
@property (nonatomic, readonly) NSNumber *recordID;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  创建日期
 */
@property (nonatomic, readonly) NSDate *creationDate;

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  修改日期
 */
@property (nonatomic, readonly) NSDate *modificationDate;


- (id)initWithRecordRef:(ABRecordRef)recordRef;

- (NSString *)addressString;

@end

NS_ASSUME_NONNULL_END
