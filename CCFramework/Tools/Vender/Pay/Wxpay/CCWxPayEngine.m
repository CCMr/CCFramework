//
//  CCWxPayEngine.m
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

#import "CCWxPayEngine.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "CCXML.h"
#import "NSString+BNSString.h"


//支付结果回调页面
#define NOTIFY_URL @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"

//统一提交订单地址
#define UnifiedorderURL @"https://api.mch.weixin.qq.com/pay/unifiedorder"

@interface CCWxPayEngine ()

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  微信分配的公众账号ID
 */
@property(nonatomic, copy) NSString *appid;

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  微信分配的appSecret
 */
@property(nonatomic, copy) NSString *appSecret;

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  商户号
 */
@property(nonatomic, copy) NSString *partnerid;

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  商户API密钥
 */
@property(nonatomic, copy) NSString *partnerKey;

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  获取服务器端支付数据地址（商户自定义）
 */
@property(nonatomic, copy) NSString *payDataAddress;

@end

@implementation CCWxPayEngine

/*  @author C C, 2015-12-03
 *
 *  @brief  单例模式
 *
 *  @return 返回当前对象
 */
+ (id)sharedlnstance
{
    static id _sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

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
       AppSecret:(NSString *)appSecret
       Partnerid:(NSString *_Nullable)partnerid
      PartnerKey:(NSString *)partnerKey
 withDescription:(NSString *)withDescription
{
    _appid = appid;
    _appSecret = appSecret;
    _partnerid = partnerid;
    _partnerKey = partnerKey;
    
    _payDataAddress = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php";
    
    [WXApi registerApp:appid
       withDescription:withDescription];
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  设置获取服务器端支付数据地址（商户自定义）
 *
 *  @param url 自定义服务器地址
 */
- (void)setPayDataAddress:(NSString *)url
{
    _payDataAddress = url;
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  统一提交订单
 *
 *  @param sendData 订单参数
 *  @param block    完成回调函数
 */
- (void)Unifiedorder:(NSDictionary *)sendData
            Complete:(void (^)(NSDictionary *requestDic, NSError *error))block
{
    __block NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];
    
    //清空未设置参数值
    [sendData enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if (obj && ![obj isEqualToString:@""])
            [packageParams setObject:obj forKey:key];
    }];
    
    [packageParams setObject:_appid forKey:@"appid"];
    [packageParams setObject:_partnerid forKey:@"mch_id"];
    
    if (![packageParams objectForKey:@"notify_url"])
        [packageParams setObject:_payDataAddress forKey:@"notify_url"];
    
    //获取prepayId（预支付交易会话标识）
    NSString *prePayid = [self sendPrepay:packageParams];
    if (prePayid) {
        //获取到prepayid后进行第二次签名
        //设置支付参数
        time_t now;
        time(&now);
        
        NSString *time_stamp = [NSString stringWithFormat:@"%ld", now];
        NSString *nonce_str = [time_stamp MD532];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        NSString *package = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject:_appid forKey:@"appid"];
        [signParams setObject:_partnerid forKey:@"partnerid"];
        [signParams setObject:prePayid forKey:@"prepayid"];
        [signParams setObject:package forKey:@"package"];
        [signParams setObject:nonce_str forKey:@"noncestr"];
        [signParams setObject:time_stamp forKey:@"timestamp"];
        //生成签名
        NSString *sign = [self createMd5Sign:signParams];
        //添加签名
        [signParams setObject:sign forKey:@"sign"];
        if (block)
            block(signParams, nil);
        
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"获取prepayid失败！" code:-1 userInfo:nil];
        if (block)
            block(nil, error);
    }
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  支付订单
 *
 *  @param prepayid  预支付交易会话ID
 *  @param package   扩展字段
 *  @param noncestr  随机字符串
 *  @param timestamp 时间戳
 *  @param sign      签名
 */
- (void)payOrderForm:(NSString *)prepayid
             Package:(NSString *)package
            Noncestr:(NSString *)noncestr
           Timestamp:(NSString *)timestamp
                Sign:(NSString *)sign
{
    PayReq *payReq = [[PayReq alloc] init];
    payReq.partnerId = prepayid;
    payReq.prepayId = package;
    payReq.prepayId = noncestr;
    payReq.prepayId = timestamp;
    payReq.prepayId = sign;
    
    [WXApi sendReq:payReq];
}

#pragma mark :. 生成预支付订单
/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  提交预支付订单
 *
 *  @param prePayParams 订单参数
 *
 *  @return 返回结果集
 */
- (NSString *)sendPrepay:(NSDictionary *)prePayParams
{
    NSString *prepayid = nil;
    
    //获取提交支付
    NSString *send = [self createPackage:prePayParams];
    
    //发送请求post xml数据
    NSData *res = [self sendPrePayHTTP:UnifiedorderURL
                                method:@"POST"
                              SendData:send];
    
    CCXML *xml = [[CCXML alloc] init];
    //开始解析
    [xml startParse:res];
    
    NSMutableDictionary *resParams = [xml changeDictionary];
    
    //判断返回
    NSString *return_code = [resParams objectForKey:@"return_code"];
    NSString *result_code = [resParams objectForKey:@"result_code"];
    if ([return_code isEqualToString:@"SUCCESS"]) {
        //生成返回数据的签名
        NSString *sign = [self createMd5Sign:resParams];
        NSString *send_sign = [resParams objectForKey:@"sign"];
        
        //验证签名正确性
        if ([sign isEqualToString:send_sign]) { //获取预支付交易标示成功！
            if ([result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid = [resParams objectForKey:@"prepay_id"];
                //                return_code = 0;
            }
        } else { //服务器返回签名验证错误！！！
            //            last_errcode = 1;
        }
    } else { //接口返回错误！！！
        //        last_errcode = 2;
    }
    
    return prepayid;
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  发送预支付订单
 *
 *  @param requestURLString 请求地址
 *  @param method           请求类型
 *  @param sendData         发送数据
 *
 *  @return 返回请求结果
 */
- (NSData *)sendPrePayHTTP:(NSString *)requestURLString
                    method:(NSString *)method
                  SendData:(NSString *)sendData
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestURLString]
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:5];
    //设置提交方式
    [request setHTTPMethod:method];
    //设置数据类型
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    //设置编码
    [request setValue:@"UTF-8" forHTTPHeaderField:@"charset"];
    //如果是POST
    [request setHTTPBody:[sendData dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error;
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil
                                                         error:&error];
    return response;
}

#pragma mark :. 生成签名
/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  生成package带参数的签名包
 *
 *  @param dict 请求参数
 *
 *  @return 返回签名
 */
- (NSString *)createPackage:(NSDictionary *)dict
{
    //生成package签名
    NSString *sign = [self createMd5Sign:dict];
    
    __block NSMutableString *reqPars = [NSMutableString string];
    //生成xml的package
    [reqPars appendString:@"<xml>\n"];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", key, obj, key];
    }];
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];
    
    return [NSString stringWithString:reqPars];
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  生成package签名
 *
 *  @param dict 请求参数
 *
 *  @return 返回签名
 */
- (NSString *)createMd5Sign:(NSDictionary *)dict
{
    NSMutableString *contentString = [NSMutableString string];
    //按字母顺序排序
    NSArray *sortedArray = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (![[dict objectForKey:categoryId] isEqualToString:@""] && ![categoryId isEqualToString:@"sign"] && ![categoryId isEqualToString:@"key"])
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", _partnerKey];
    //得到MD5 sign签名
    NSString *md5Sign = [contentString MD532];
    
    return md5Sign;
}

@end
