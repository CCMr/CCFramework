//
//  CCAliPayEngine.m
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

#import "CCAliPayEngine.h"
#import "AliOrderFormEntity.h"
#import "DataSigner.h"
#import "NSObject+Additions.h"

typedef void (^ResponseCallback)(NSInteger resultStatus, NSString *result,
                                 NSString *memo, NSError *error);

@interface CCAliPayEngine ()

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  回调APP名称
 */
@property(nonatomic, copy) NSString *appScheme;

/**
 *  @author C C, 2015-10-18
 *
 *  @brief  合作身份者ID,以 2088 开头由 16 位纯数字组成的字符串
 */
@property(nonatomic, copy) NSString *partnerKey;
/**
 *  @author C C, 2015-10-18
 *
 *  @brief  支付宝收款账号,手机号码或邮箱格式。
 */
@property(nonatomic, copy) NSString *sellerKey;
/**
 *  @author C C, 2015-10-18
 *
 *  @brief  商户方的私钥,pkcs8 格式。
 */
@property(nonatomic, copy) NSString *privateKey;
/**
 *  @author C C, 2015-10-18
 *
 *  @brief  回调函数
 */
@property(nonatomic, strong) ResponseCallback responseCallback;

@end

@implementation CCAliPayEngine

/*  @author C C, 2015-10-18
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
 *  @author C C, 2015-10-18
 *
 *  @brief  设置链接秘钥
 *
 *  @param appScheme  回调APP名称
 *  @param partnerKey 作身份者ID
 *  @param sellerKey  支付宝收款账号,手机号码或邮箱格式。
 *  @param privateKey 商家私有秘钥
 */
- (void)setAliPaySchema:(NSString *)appScheme
             PartnerKey:(NSString *)partnerKey
              SellerKey:(NSString *)sellerKey
             PrivateKey:(NSString *)privateKey
{
    _appScheme = appScheme;
    _partnerKey = partnerKey;
    _sellerKey = sellerKey;
    _privateKey = privateKey;
}

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
- (void)payOrderForm:(NSString *)tradeNO
         ProductName:(NSString *)productName
  ProductDescription:(NSString *)productDescription
              Amount:(NSString *)amount
           notifyURL:(NSString *)notifyURL
            Callback:(nullable void (^)(NSInteger resultStatus,
                                        NSString *result, NSString *memo,
                                        NSError *error))block
{
    _responseCallback = [block copy];
    
    if (_partnerKey.length == 0 || _sellerKey.length == 0 ||
        _privateKey.length == 0 || _appScheme.length == 0) {
        NSString *errMessage;
        if (_partnerKey.length == 0 || _sellerKey.length == 0)
            errMessage = @"partner或seller参数为空";
        
        if (_privateKey.length == 0 || _appScheme.length == 0)
            errMessage = @"privateKey或appScheme参数为空";
        
        NSError *err = [NSError errorWithDomain:errMessage code:-1 userInfo:nil];
        block(-1, nil, nil, err);
    }
    
    AliOrderFormEntity *entity = [[AliOrderFormEntity alloc] init];
    entity.partner = _partnerKey;
    entity.seller = _sellerKey;
    entity.productName = productName;
    entity.tradeNO = tradeNO;
    entity.productDescription = productDescription;
    entity.amount = amount;
    entity.notifyURL = notifyURL;
    
    NSString *orderSpec = [entity description];
    id<DataSigner> signer = CreateRSADataSigner(_privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    if (signedString) {
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", orderSpec, signedString, @"RSA"];
        
        if (NSClassFromString(@"AlipaySDK")) {
            Class Alipay = NSClassFromString(@"AlipaySDK");
            id AlipaySDK = [Alipay InitDefaultMethod:@"defaultService"];
            
            typeof(self) __weak weakSelf = self;
            void(^CompletionBlock)(NSDictionary *resultDic) = ^(NSDictionary *resultDic) {
                weakSelf.responseCallback([[resultDic objectForKey:@"resultStatus"] integerValue],[resultDic objectForKey:@"result"],[resultDic objectForKey:@"memo"], nil);
            };
            [AlipaySDK performSelectors:@"payOrder:fromScheme:callback:" withObject:orderString, _appScheme, CompletionBlock,nil];
        }else{
            NSLog(@"请在工程中导入AlipaySDK.framework文件");
        }
    }
}

@end
