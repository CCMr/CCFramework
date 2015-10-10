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


@end
