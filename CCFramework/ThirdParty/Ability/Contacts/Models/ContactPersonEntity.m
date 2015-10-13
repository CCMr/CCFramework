//
//  ContactPersonEntity.m
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

#import "ContactPersonEntity.h"

@implementation ContactPersonEntity

- (NSString *)addressString
{
    return [NSString stringWithFormat:@"%@ %@, %@ %@ %@",
            _street1,
            _city,
            _state,
            _zip,
            _country
            ];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"first = %@, nickname = %@, last = %@, birthday = %@, company = %@, phones = %@, emails : %@, urls = %@, address = (%@)",
            _firstname,
            _nickname,
            _lastname,
            _birthday,
            _company,
            _phones,
            _emails,
            _urls,
            [self addressString]
            ];
}

- (NSString *)displayName
{
    if ( self.firstname != nil && self.lastname != nil && ![self.firstname isEqualToString:@""] && ![self.lastname isEqualToString:@""] )
        return [NSString stringWithFormat:@"%@ %@", self.firstname, self.lastname];
    if ( self.firstname != nil && ![self.firstname isEqualToString:@""] )
        return [NSString stringWithFormat:@"%@", self.firstname];
    if ( self.lastname != nil && ![self.lastname isEqualToString:@""] )
        return [NSString stringWithFormat:@"%@", self.lastname];
    else if ( self.nickname != nil && ![self.nickname isEqualToString:@""] )
        return [NSString stringWithFormat:@"%@", self.nickname];
    else if ( self.company != nil && ![self.company isEqualToString:@""] )
        return [NSString stringWithFormat:@"%@", self.company];
    else if ( self.phones.count )
        return [NSString stringWithFormat:@"%@", self.phones[0]];
    else if ( self.emails.count )
        return [NSString stringWithFormat:@"%@", self.emails[0]];
    return @"No name";
}

- (NSString *)detailText
{
    if ( self.phones.count )
        return [NSString stringWithFormat:@"phone: %@", self.phones[0]];
    else if ( self.emails.count )
        return [NSString stringWithFormat:@"email: %@", self.emails[0]];
    else if ( self.company.length != 0 )
        return [NSString stringWithFormat:@"company: %@", self.company];
    else if ( self.nickname.length != 0 )
        return [NSString stringWithFormat:@"nickname: %@", self.nickname];
    return @"No details";
}

#pragma mark - 使用AddressBook

- (id)initWithRecordRef:(ABRecordRef)recordRef
{
    if (self = [super init]) {
        [self InitAttributes:recordRef];
    }
    return self;
}

/**
 *  @author CC, 2015-10-13
 *
 *  @brief  初始化属性值
 *
 *  @param recordRef <#recordRef description#>
 */
- (void)InitAttributes: (ABRecordRef)recordRef
{
    _firstname = [self stringProperty:kABPersonFirstNameProperty fromRecord:recordRef];
//    _middleName = [self stringProperty:kABPersonMiddleNameProperty fromRecord:recordRef];
    _lastname = [self stringProperty:kABPersonLastNameProperty fromRecord:recordRef];
    _nickname = [self compositeNameFromRecord:recordRef];
    _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];

    _phones = [self arrayProperty:kABPersonPhoneProperty fromRecord:recordRef];

    _phones = [self arrayOfPhonesWithLabelsFromRecord:recordRef];

    _emails = [self arrayProperty:kABPersonEmailProperty fromRecord:recordRef];

    _photo = [self imagePropertyFullSize:YES fromRecord:recordRef];

    _thumb = [self imagePropertyFullSize:NO fromRecord:recordRef];

    NSArray *array = [self arrayProperty:kABPersonAddressProperty fromRecord:recordRef];
    for (NSDictionary *dictionary in array)
    {
        _street1 = dictionary[(__bridge NSString *)kABPersonAddressStreetKey];
        _city = dictionary[(__bridge NSString *)kABPersonAddressCityKey];
        _state = dictionary[(__bridge NSString *)kABPersonAddressStateKey];
        _zip = dictionary[(__bridge NSString *)kABPersonAddressZIPKey];
        _country = dictionary[(__bridge NSString *)kABPersonAddressCountryKey];
        _countryCode = dictionary[(__bridge NSString *)kABPersonAddressCountryCodeKey];
    }
    _recordID = [NSNumber numberWithInteger:ABRecordGetRecordID(recordRef)];
    _creationDate = [self dateProperty:kABPersonCreationDateProperty fromRecord:recordRef];
    _modificationDate = [self dateProperty:kABPersonModificationDateProperty fromRecord:recordRef];
}

#pragma mark - private

- (NSString *)stringProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFTypeRef valueRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSString *)valueRef;
}

- (NSArray *)arrayProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:property fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
     {
         CFTypeRef value = ABMultiValueCopyValueAtIndex(multiValue, index);
         NSString *string = (__bridge_transfer NSString *)value;
         if (string)
         {
             [array addObject:string];
         }
     }];
    return array.copy;
}


- (NSDate *)dateProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFDateRef dateRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSDate *)dateRef;
}

- (NSArray *)arrayOfPhonesWithLabelsFromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:kABPersonPhoneProperty fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
     {
         CFTypeRef rawPhone = ABMultiValueCopyValueAtIndex(multiValue, index);
         NSString *phone = (__bridge_transfer NSString *)rawPhone;
         if (phone)
         {
             NSString *label = [self localizedLabelFromMultiValue:multiValue index:index];
             NSMutableDictionary *dic = [NSMutableDictionary dictionary];
             [dic setValue:phone forKey:@"phone"];
             [dic setValue:label forKey:@"label"];
             [array addObject:dic];
         }
     }];
    return array.copy;
}

- (UIImage *)imagePropertyFullSize:(BOOL)isFullSize fromRecord:(ABRecordRef)recordRef
{
    ABPersonImageFormat format = isFullSize ? kABPersonImageFormatOriginalSize :
    kABPersonImageFormatThumbnail;
    NSData *data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordRef, format);
    return [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
}

- (NSString *)localizedLabelFromMultiValue:(ABMultiValueRef)multiValue index:(NSUInteger)index
{
    NSString *label;
    CFTypeRef rawLabel = ABMultiValueCopyLabelAtIndex(multiValue, index);
    if (rawLabel)
    {
        CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(rawLabel);
        if (localizedLabel)
        {
            label = (__bridge_transfer NSString *)localizedLabel;
        }
        CFRelease(rawLabel);
    }
    return label;
}

- (NSString *)compositeNameFromRecord:(ABRecordRef)recordRef
{
    CFStringRef compositeNameRef = ABRecordCopyCompositeName(recordRef);
    return (__bridge_transfer NSString *)compositeNameRef;
}

- (void)enumerateMultiValueOfProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
                            withBlock:(void (^)(ABMultiValueRef multiValue, NSUInteger index))block
{
    ABMultiValueRef multiValue = ABRecordCopyValue(recordRef, property);
    NSUInteger count = (NSUInteger)ABMultiValueGetCount(multiValue);
    for (NSUInteger i = 0; i < count; i++)
    {
        block(multiValue, i);
    }
    CFRelease(multiValue);
}


@end
