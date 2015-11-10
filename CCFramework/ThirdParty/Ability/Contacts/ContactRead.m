//
//  ContactRead.m
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

@import Contacts;
@import ContactsUI;
#import "ContactRead.h"
#import "ContactPersonEntity.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "config.h"

typedef void (^ContactCompletion)(NSArray *contacts, NSError *error);

@interface ContactRead ()

@property(nonatomic, strong) CNContactStore *contactStore;

@property(nonatomic, strong) ContactCompletion completion;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  读取通讯录错误
 */
@property(assign) BOOL contactsError;

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  集合对象
 */
@property(nonatomic, strong) NSArray *contacts;

#pragma mark - IOS9以下使用
@property(nonatomic, readonly) ABAddressBookRef addressBook;

@property(nonatomic, readonly) dispatch_queue_t localQueue;

@end

@implementation ContactRead

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  读取通讯录
 *
 *  @param completion 回调函数
 */
- (void)readContact:(void (^)(NSArray *contacts, NSError *error))completion {
    self.completion = completion;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        [self readAddress];
    } else
        [self readIOS9Contact];
}

- (void)readAddress {
    WEAKSELF;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        CFErrorRef *error = NULL;
        _addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (error) {
            NSLog(@"%@",
                  (__bridge_transfer NSString *)CFErrorCopyFailureReason(*error));
            return;
        }
        NSString *name =
        [NSString stringWithFormat:@"com.addressbook.%ld", (long)self.hash];
        _localQueue = dispatch_queue_create(
                                            [name cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    } else { //如果系统是6.0之前的系统，不需要获得同意，直接访问
        _addressBook = ABAddressBookCreate();
    }
    //占时不确定作用域
    NSArray *descriptors = [NSArray array];
    
    ABAddressBookRequestAccessWithCompletion(
                                             self.addressBook, ^(bool granted, CFErrorRef errorRef) {
                                                 dispatch_async(self.localQueue, ^{
                                                     NSArray *array = nil;
                                                     NSError *error = nil;
                                                     if (granted) {
                                                         CFArrayRef peopleArrayRef =
                                                         ABAddressBookCopyArrayOfAllPeople(self.addressBook);
                                                         NSUInteger contactCount =
                                                         (NSUInteger)CFArrayGetCount(peopleArrayRef);
                                                         NSMutableArray *contacts = [[NSMutableArray alloc] init];
                                                         for (NSUInteger i = 0; i < contactCount; i++) {
                                                             ABRecordRef recordRef = CFArrayGetValueAtIndex(peopleArrayRef, i);
                                                             ContactPersonEntity *contact =
                                                             [[ContactPersonEntity alloc] initWithRecordRef:recordRef];
                                                             [contacts addObject:contact];
                                                         }
                                                         [contacts sortUsingDescriptors:descriptors];
                                                         array = contacts.copy;
                                                         CFRelease(peopleArrayRef);
                                                     } else if (error) {
                                                         error = (__bridge NSError *)errorRef;
                                                     }
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         weakSelf.completion(array, error);
                                                     });
                                                 });
                                             });
}

#pragma mark - IOS9
/**
 *  @author CC, 2015-10-13
 *
 *  @brief  IOS9加载通讯录
 */
- (void)readIOS9Contact {
    if (!self.contactStore)
        self.contactStore = [[CNContactStore alloc] init];
    
    NSError *_contactError = [NSError
                              errorWithDomain:@"CCContactsErrorDomain"
                              code:1
                              userInfo:@{
                                         NSLocalizedDescriptionKey : @"Not authorized to access Contacts."
                                         }];
    WEAKSELF;
    switch (
            [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts]) {
        case CNAuthorizationStatusDenied:
        case CNAuthorizationStatusRestricted: //读取联系人错误
        {
            //跳转系统设置app获取通讯录权限  [[UIApplication sharedApplication]
            // openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            self.completion(nil, _contactError);
            break;
        }
        case CNAuthorizationStatusNotDetermined: {
            [self.contactStore
             requestAccessForEntityType:CNEntityTypeContacts
             completionHandler:^(BOOL granted, NSError *error) {
                 if (!granted) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         weakSelf.completion(nil, _contactError);
                     });
                 } else
                     [weakSelf readContact:weakSelf.completion];
             }];
            break;
        }
            
        case CNAuthorizationStatusAuthorized: {
            NSMutableArray *_contactsTemp = [NSMutableArray new];
            CNContactFetchRequest *_contactRequest =
            [[CNContactFetchRequest alloc] initWithKeysToFetch:[self contactKeys]];
            [self.contactStore
             enumerateContactsWithFetchRequest:_contactRequest
             error:nil
             usingBlock:^(CNContact *contact, BOOL *stop) {
                 [_contactsTemp addObject:contact];
             }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.completion([self analyzeContact:_contactsTemp], nil);
            });
            break;
        }
    }
}

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  分析联系人
 *
 *  @param contactAry 连接系人对象集合
 *
 *  @return 返回解析之后的联系人对象集合
 */
- (NSMutableArray *)analyzeContact:(NSArray *)contactAry {
    __block NSMutableArray *array = [NSMutableArray array];
    [contactAry enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CNContact *contact = obj;
        ContactPersonEntity *entity = [[ContactPersonEntity alloc] init];
        
        entity.photo = [UIImage imageWithData:contact.imageData];
        entity.thumb = [UIImage imageWithData:contact.thumbnailImageData];
        entity.firstname = contact.givenName;
        entity.lastname = contact.familyName;
        entity.nickname = contact.nickname;
        entity.company = contact.organizationName;
        entity.birthday =
        contact.birthday != nil
        ? [[[NSCalendar alloc]
            initWithCalendarIdentifier:NSCalendarIdentifierGregorian]
           dateFromComponents:contact.birthday]
        : [NSDate date];
        
        if (contact.phoneNumbers.count) {
            NSMutableArray *tempPhones = [NSMutableArray new];
            for (CNLabeledValue *contactPhone in contact.phoneNumbers) {
                CNPhoneNumber *phoneNumber = contactPhone.value;
                [tempPhones addObject:phoneNumber.stringValue];
            }
            entity.phones = tempPhones;
        }
        
        if (contact.emailAddresses.count) {
            NSMutableArray *tempEmails = [NSMutableArray new];
            for (CNLabeledValue *contactEmail in contact.emailAddresses)
                [tempEmails addObject:contactEmail.value];
            entity.emails = tempEmails;
        }
        
        if (contact.postalAddresses.count) {
            CNLabeledValue *contactAddress = contact.postalAddresses[0];
            CNPostalAddress *address = contactAddress.value;
            entity.street1 = address.street;
            entity.city = address.city;
            entity.state = address.state;
            entity.zip = address.postalCode;
            entity.country = address.country;
        }
        
        if (contact.urlAddresses.count) {
            NSMutableArray *tempUrls = [NSMutableArray new];
            for (CNLabeledValue *contactUrl in contact.urlAddresses)
                [tempUrls addObject:contactUrl.value];
            entity.urls = tempUrls;
        }
        [array addObject:entity];
    }];
    
    return array;
}

/**
 *  @author CC, 2015-10-10
 *
 *  @brief  通讯录Key
 *
 *  @return 返回通讯录Key集合
 */
- (NSArray *)contactKeys {
    return @[
             CNContactNamePrefixKey,
             CNContactGivenNameKey,
             CNContactMiddleNameKey,
             CNContactFamilyNameKey,
             CNContactPreviousFamilyNameKey,
             CNContactNameSuffixKey,
             CNContactNicknameKey,
             CNContactPhoneticGivenNameKey,
             CNContactPhoneticMiddleNameKey,
             CNContactPhoneticFamilyNameKey,
             CNContactOrganizationNameKey,
             CNContactDepartmentNameKey,
             CNContactJobTitleKey,
             CNContactBirthdayKey,
             CNContactNonGregorianBirthdayKey,
             CNContactNoteKey,
             CNContactImageDataKey,
             CNContactThumbnailImageDataKey,
             CNContactImageDataAvailableKey,
             CNContactTypeKey,
             CNContactPhoneNumbersKey,
             CNContactEmailAddressesKey,
             CNContactPostalAddressesKey,
             CNContactDatesKey,
             CNContactUrlAddressesKey,
             CNContactRelationsKey,
             CNContactSocialProfilesKey,
             CNContactInstantMessageAddressesKey
             ];
}


-(void)dealloc
{
    if (_addressBook)
        CFRelease(_addressBook);
    
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_localQueue);
#endif
}

@end
