//
//  WxSingleEntity.h
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

@interface CCWXSingleEntity : BaseEntity

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  公众账号ID
 *          微信分配的公众账号ID（企业号corpid即为此appId）
 */
@property(nonatomic, copy) NSString *appid;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  商户号
 *          微信支付分配的商户号
 */
@property(nonatomic, copy) NSString *mch_id;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  设备号
 *          终端设备号(门店号或收银设备ID)，注意：PC网页或公众号内支付请传"WEB"
 */
@property(nonatomic, copy) NSString *device_info;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  随机字符串
 *          随机字符串，不长于32位。推荐随机数生成算法
 */
@property(nonatomic, copy) NSString *nonce_str;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  签名
 *          签名，详见签名生成算法
 */
@property(nonatomic, copy) NSString *sign;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  商品描述
 *          商品或支付单简要描述
 */
@property(nonatomic, copy) NSString *body;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  商品详情
 *          商品名称明细列表
 */
@property(nonatomic, copy) NSString *detail;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  附加数据
 *          附加数据，在查询API和支付通知中原样返回，该字段主要用于商户携带订单的自定义数据
 */
@property(nonatomic, copy) NSString *attach;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  商户订单号
 *          商户系统内部的订单号,32个字符内、可包含字母, 其他说明见商户订单号
 */
@property(nonatomic, copy) NSString *out_trade_no;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  货币类型
 *          符合ISO 4217标准的三位字母代码，默认人民币：CNY，其他值列表详见货币类型
 */
@property(nonatomic, copy) NSString *fee_type;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  总金额
 *          订单总金额，单位为分，详见支付金额
 */
@property(nonatomic, assign) NSInteger *total_fee;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  终端IP
 *          APP和网页支付提交用户端ip，Native支付填调用微信支付API的机器IP。
 */
@property(nonatomic, copy) NSString *spbill_create_ip;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  交易起始时间
 *          订单生成时间，格式为yyyyMMddHHmmss，如2009年12月25日9点10分10秒表示为20091225091010。其他详见时间规则
 */
@property(nonatomic, copy) NSString *time_start;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  交易结束时间
 *          订单失效时间，格式为yyyyMMddHHmmss，如2009年12月27日9点10分10秒表示为20091227091010。其他详见时间规则
 *          注意：最短失效时间间隔必须大于5分钟
 */
@property(nonatomic, copy) NSString *time_expire;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  商品标记
 *          商品标记，代金券或立减优惠功能的参数，说明详见代金券或立减优惠
 */
@property(nonatomic, copy) NSString *goods_tag;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  通知地址
 *          接收微信支付异步通知回调地址
 */
@property (nonatomic, copy) NSString *notify_url;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  交易类型
 *          取值如下：JSAPI，NATIVE，APP，详细说明见参数规定
 */
@property (nonatomic, copy) NSString *trade_type;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  商品ID
 *          trade_type=NATIVE，此参数必传。此id为二维码中包含的商品ID，商户自行定义。
 */
@property (nonatomic, copy) NSString *product_id;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  指定支付方式
 *          no_credit--指定不能使用信用卡支付
 */
@property (nonatomic, copy) NSString *limit_pay;

/**
 *  @author C C, 2015-12-03
 *  
 *  @brief  用户标识
 *          trade_type=JSAPI，此参数必传，用户在商户appid下的唯一标识。
 *          openid如何获取，可参考【获取openid】。
 *          企业号请使用【企业号OAuth2.0接口】获取企业号内成员userid，再调用【企业号userid转openid接口】进行转换
 */
@property (nonatomic, copy) NSString *openid;

@end
