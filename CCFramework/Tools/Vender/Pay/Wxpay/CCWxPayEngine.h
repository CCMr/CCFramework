//
//  CCWxPayEngine.h
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

@interface CCWxPayEngine : NSObject


/*  @author C C, 2015-12-03
 *
 *  @brief  单例模式
 *
 *  @return 返回当前对象
 */
+ (instancetype _Nullable)sharedlnstance;

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  基础设置
 *
 *  @param appid           公众账号ID (微信开发者ID)
 *  @param appSecret       appSecret (微信分配)
 *  @param partnerid       商户号
 *  @param partnerKey      商户API密钥
 *  @param withDescription 应用附加信息，长度不超过1024字节
 */
- (void)setWxPay:(NSString *_Nullable)appid
       AppSecret:(NSString *_Nullable)appSecret
       Partnerid:(NSString *_Nullable)partnerid
      PartnerKey:(NSString *_Nullable)partnerKey
 withDescription:(NSString *_Nullable)withDescription;


/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  设置获取服务器端支付数据地址（商户自定义）
 *          默认值：http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php
 *  @param url 自定义服务器地址
 */
- (void)setPayDataAddress:(NSString *_Nullable)url;

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  统一提交订单
 *
 *  @param sendData 订单参数
 *  @param block    完成回调函数
 */
- (void)Unifiedorder:(NSDictionary *_Nullable)sendData
            Complete:(void (^_Nullable)(NSDictionary *_Nullable requestDic, NSError *_Nullable error))block;

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  支付订单
 *
 *  @param appid     由用户微信号和AppID组成的唯一标识
 *  @param prepayid  商家向财付通申请的商家id
 *  @param prepayId  预支付订单
 *  @param package   商家根据财付通文档填写的数据和签名
 *  @param noncestr  随机串
 *  @param timestamp 时间戳
 *  @param sign      签名
 */
- (void)payOrderForm:(NSString *_Nullable)appid
           PartnerId:(NSString *_Nullable)partnerId
            PrepayId:(NSString *_Nullable)prepayId
             Package:(NSString *_Nullable)package
            Noncestr:(NSString *_Nullable)noncestr
           Timestamp:(NSString *_Nullable)timestamp
                Sign:(NSString *_Nullable)sign
            Complete:(void (^_Nullable)(NSError *_Nullable error))block;

/**
 *  @author C C, 2015-12-06
 *  
 *  @brief  设置回调
 *
 *  @param url url description
 */
-(BOOL)handleOpenURL:(NSURL *_Nullable)url;

@end
