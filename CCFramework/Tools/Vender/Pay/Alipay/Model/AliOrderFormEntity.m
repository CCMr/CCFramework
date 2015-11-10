//
//  AliOrderFormEntity.m
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

#import "AliOrderFormEntity.h"

@implementation AliOrderFormEntity

- (NSString *)description {
    NSMutableString * discription = [NSMutableString string];
    [discription appendFormat:@"partner=\"%@\"", self.partner ?: @""];
    [discription appendFormat:@"&seller_id=\"%@\"", self.seller ?: @""];
    [discription appendFormat:@"&out_trade_no=\"%@\"", self.tradeNO ?: @""];
    [discription appendFormat:@"&subject=\"%@\"", self.productName ?: @""];
    [discription appendFormat:@"&body=\"%@\"", self.productDescription ?: @""];
    [discription appendFormat:@"&total_fee=\"%@\"", self.amount ?: @""];
    [discription appendFormat:@"&notify_url=\"%@\"", self.notifyURL ?: @""];
    
    [discription appendFormat:@"&service=\"%@\"", self.serviceName ?: @"mobile.securitypay.pay"];
    [discription appendFormat:@"&payment_type=\"%@\"", self.paymentType ?: @"1"];
    [discription appendFormat:@"&_input_charset=\"%@\"", self.inputCharset ?: @"utf-8"];
    
    //下面的这些参数，如果没有必要（value为空），则无需添加
    [discription appendFormat:@"&it_b_pay=\"%@\"", self.itBPay ?: @"30m"];
    [discription appendFormat:@"&show_url=\"%@\"", self.showUrl ?: @"m.alipay.com"];
    if (self.returnUrl)
        [discription appendFormat:@"&return_url=\"%@\"", self.returnUrl ?: @""];
    if (self.rsaDate)
        [discription appendFormat:@"&sign_date=\"%@\"",self.rsaDate ?: @""];
    if (self.appID)
        [discription appendFormat:@"&app_id=\"%@\"",self.appID ?: @""];
    
    for (NSString * key in [self.extraParams allKeys]) {
        [discription appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
    }
    return discription;
}


@end
