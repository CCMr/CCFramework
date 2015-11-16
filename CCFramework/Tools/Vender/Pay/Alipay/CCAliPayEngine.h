//
//  CCAliPayEngine.h
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

#import <Foundation/Foundation.h>

@interface CCAliPayEngine : NSObject

+ (id _Nullable)sharedlnstance;

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  设置链接秘钥
 *
 *  @param appScheme  回调APP名称
 *  @param partnerKey 作身份者ID
 *  @param sellerKey  支付宝收款账号,手机号码或邮箱格式。
 *  @param privateKey 商家私有秘钥
 */
- (void)setAliPaySchema:(NSString * _Nullable)appScheme
             PartnerKey:(NSString * _Nullable)partnerKey
              SellerKey:(NSString * _Nullable)sellerKey
             PrivateKey:(NSString * _Nullable)privateKey;

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  支付订单
 *
 *  @param tradeNO            订单号
 *  @param productName        标题
 *  @param productDescription 描述
 *  @param amount             价格
 *  @param notifyURL          回调URL
 */
- (void)payOrderForm:(NSString * _Nullable)tradeNO
         ProductName:(NSString * _Nullable)productName
  ProductDescription:(NSString * _Nullable)productDescription
              Amount:(NSString * _Nullable)amount
           notifyURL:(NSString * _Nullable)notifyURL
            Callback:(nullable void (^)(NSInteger resultStatus,
                                        NSString * _Nullable result, NSString * _Nullable memo,
                                        NSError * _Nullable error))block;

/**
 *  处理钱包或者独立快捷app支付跳回商户app携带的支付结果Url
 *
 *  @param resultUrl 支付结果url，传入后由SDK解析，统一在上面的pay方法的callback中回调
 *  @param completionBlock 跳钱包支付结果回调，保证跳转钱包支付过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
 */
-(void)processOrderWithPaymentResult:(NSURL * _Nullable)url
                     standbyCallback:(nullable void (^)(NSInteger resultStatus,
                                                        NSString * _Nullable result, NSString * _Nullable memo,
                                                        NSError * _Nullable error))block;
/**
 *  处理授权信息Url
 *
 *  @param resultUrl 钱包返回的授权结果url
 *  @param completionBlock 跳授权结果回调，保证跳转钱包授权过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
 */
-(void)processAuthResult:(NSURL * _Nullable)url
         standbyCallback:(nullable void (^)(NSInteger resultStatus,
                                            NSString * _Nullable result, NSString * _Nullable memo,
                                            NSError * _Nullable error))block;

@end
