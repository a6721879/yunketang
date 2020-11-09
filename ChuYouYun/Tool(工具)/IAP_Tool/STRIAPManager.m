//
//  STRIAPManager.m
//  YunKeTang
//
//  Created by IOS on 2018/12/10.
//  Copyright © 2018年 ZhiYiForMac. All rights reserved.
//

#import "STRIAPManager.h"
#import <StoreKit/StoreKit.h>
#import "NSData+Base64.h"
#import "BigWindCar.h"
#import "SYG.h"


static bool hasAddObersver = NO;

@interface STRIAPManager()<SKPaymentTransactionObserver,SKProductsRequestDelegate>{
    NSString           *_purchID;
    IAPCompletionHandle _handle;
    
    NSString           *priceStr;
    NSString           *receipt_data_str;
}

@property (nonatomic, copy)NSString *logs;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation STRIAPManager

#pragma mark - ♻️life cycle
+ (instancetype)shareSIAPManager{
    
    static STRIAPManager *IAPManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        IAPManager = [[STRIAPManager alloc] init];
    });
    return IAPManager;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        // 购买监听写在程序入口,程序挂起时移除监听,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
        
        if (!hasAddObersver) {
            hasAddObersver = YES;
            // 监听购买结果
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        }
    }
    [UIPasteboard generalPasteboard].string = @"";
    self.logs = @"日志：\n";
    self.dateFormatter = [[NSDateFormatter alloc]init];
    self.dateFormatter.dateFormat = @"mm:ss";
    return self;
}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


#pragma mark - 🚪public
- (void)startPurchWithID:(NSString *)purchID completeHandle:(IAPCompletionHandle)handle{
    [self addLog:[NSString stringWithFormat:@"startPurchWithID %@", purchID]];
    if (purchID) {
        if ([SKPaymentQueue canMakePayments]) {
            // 开始购买服务
            _purchID = purchID;
            _handle = handle;
            NSSet *nsset = [NSSet setWithArray:@[purchID]];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
            request.delegate = self;
            [request start];
        }else{
            [self addLog:@"不可使用IAP"];
            [self handleActionWithType:SIAPPurchNotArrow data:nil];
        }
    } else {
        [self addLog:@"startPurchWithID 为空"];
    }
}

- (void)addLog: (NSString*)log {
    if (!self.isTest) {
        return;
    }
    NSString *dateStr = [self.dateFormatter stringFromDate:[[NSDate alloc]init]];
    self.logs = [NSString stringWithFormat:@"%@\n%@:%@", self.logs, dateStr,  log];
    [UIPasteboard generalPasteboard].string = self.logs;
}

#pragma mark - 🔒private
- (void)handleActionWithType:(SIAPPurchType)type data:(NSData *)data{
    [self addLog:[NSString stringWithFormat:@"handleActionWithType %d", type]];
    switch (type) {
        case SIAPPurchSuccess:
            NSLog(@"购买成功");
            if (receipt_data_str == nil) {
                [self addLog:[NSString stringWithFormat:@"handleActionWithType %d 没有支付凭证", type]];
                if (self.controlLoadingBlock) {
                    self.controlLoadingBlock(NO, @"未能获取到支付凭据");
                }
            } else {
                [self addLog:[NSString stringWithFormat:@"handleActionWithType %d 开始网络验证", type]];
                [self netWorkApplePayResults:receipt_data_str];
            }
            break;
        case SIAPPurchFailed:
            NSLog(@"购买失败");
            if (self.controlLoadingBlock) {
                self.controlLoadingBlock(NO, @"购买失败");
            }
            break;
        case SIAPPurchCancle:
            NSLog(@"用户取消购买");
            if (self.controlLoadingBlock) {
                self.controlLoadingBlock(NO, @"用户取消购买");
            }
            break;
        case SIAPPurchVerFailed:
            NSLog(@"订单校验失败");
            if (self.controlLoadingBlock) {
                self.controlLoadingBlock(NO, @"订单校验失败");
            }
            break;
        case SIAPPurchVerSuccess:
            NSLog(@"订单校验成功");
            if (self.controlLoadingBlock) {
                self.controlLoadingBlock(YES, @"订单校验成功");
            }
            break;
        case SIAPPurchNotArrow:
            NSLog(@"不允许程序内付费");
            if (self.controlLoadingBlock) {
                self.controlLoadingBlock(NO, @"不允许程序内付费");
            }
            break;
        default:
            break;
    }
    if(_handle){
        _handle(type,data);
    }
}


#pragma mark - 🍐delegate
// 交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    [self addLog:@"completeTransaction"];
    [self verifyPurchaseWithPaymentTransaction:transaction];
}

// 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction{
    [self addLog:@"failedTransaction"];
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [self handleActionWithType:SIAPPurchFailed data:nil];
    }else{
        [self handleActionWithType:SIAPPurchCancle data:nil];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)verifyPurchaseWithPaymentTransaction:(SKPaymentTransaction *)transaction {
    [self addLog:@"verifyPurchaseWithPaymentTransaction"];

    //交易验证
    NSURL *recepitURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:recepitURL];
    
    if(!receipt){
        [self addLog:@"verifyPurchaseWithPaymentTransaction 交易凭证为空验证失败"];
        // 交易凭证为空验证失败
        [self handleActionWithType:SIAPPurchVerFailed data:nil];
        return;
    }
    receipt_data_str = [receipt base64EncodedString];
    [self addLog:@"verifyPurchaseWithPaymentTransaction 开始椒盐支付凭证"];

    // 购买成功将交易凭证发送给服务端进行再次校验
    [self handleActionWithType:SIAPPurchSuccess data:receipt];
    // 验证成功与否都注销交易,否则会出现虚假凭证信息一直验证不通过,每次进程序都得输入苹果账号
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *product = response.products;
    if([product count] <= 0){
        [self addLog:@"didReceiveResponse 没有商品"];
        NSLog(@"--------------没有商品------------------");
        return;
    }
    
    SKProduct *selectedProduct = nil;
    for(SKProduct *pro in product){
        if([pro.productIdentifier isEqualToString:_purchID]){
            selectedProduct = pro;
            break;
        }
    }
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    NSLog(@"%@",[selectedProduct description]);
    NSLog(@"%@",[selectedProduct localizedTitle]);
    NSLog(@"%@",[selectedProduct localizedDescription]);
    NSLog(@"%@",[selectedProduct price]);
    NSLog(@"%@",[selectedProduct productIdentifier]);
    NSLog(@"发送购买请求");
    priceStr = [NSString stringWithFormat:@"%@",[selectedProduct price]];
    [self addLog:[NSString stringWithFormat:@"didReceiveResponse 开始支付 %@", response.invalidProductIdentifiers]];

    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:selectedProduct];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [self addLog:[NSString stringWithFormat:@"didFailWithError %@", error.localizedDescription]];
    NSLog(@"------------------错误-----------------:%@", error);
    if (self.controlLoadingBlock) {
        self.controlLoadingBlock(NO, error.description);
    }
}

- (void)requestDidFinish:(SKRequest *)request{
    [self addLog:@"requestDidFinish"];
    NSLog(@"------------反馈信息结束-----------------");
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    [self addLog:@"updatedTransactions bg"];
    if (![SKPaymentQueue canMakePayments]) {
        if (self.controlLoadingBlock) {
            self.controlLoadingBlock(NO, @"不可进行苹果内购");
        }
        [self addLog:@"updatedTransactions 不可进行苹果内购"];
        return;
    }

    for (SKPaymentTransaction *tran in transactions) {
        [self addLog:[NSString stringWithFormat:@"updatedTransactions %ld", (long)tran.transactionState]];

        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self addLog:@"updatedTransactions SKPaymentTransactionStatePurchased"];

                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                [self addLog:@"updatedTransactions SKPaymentTransactionStatePurchasing"];
                NSLog(@"商品添加进列表11");
                break;
            case SKPaymentTransactionStateRestored:
                [self addLog:@"updatedTransactions SKPaymentTransactionStateRestored"];
                NSLog(@"已经购买过商品");
                // 消耗型不支持恢复购买
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                if (self.controlLoadingBlock) {
                   self.controlLoadingBlock(NO, @"已经购买过商品");
                }
                break;
            case SKPaymentTransactionStateFailed:
                [self addLog:@"updatedTransactions SKPaymentTransactionStateFailed"];

                [self failedTransaction:tran];

                if (tran.error.code == 0) {
                    if (self.controlLoadingBlock) {
                        self.controlLoadingBlock(NO, tran.error.userInfo[@"NSLocalizedDescription"]);
                    }
                } else {
                    if (self.controlLoadingBlock) {
                       self.controlLoadingBlock(NO, @"支付已取消");
                    }
                }
                break;
            default:
                [self addLog:[NSString stringWithFormat:@"updatedTransactions default %ld", (long)tran.transactionState]];

                break;
        }
    }
}



#pragma mark  ----

- (void)netWorkApplePayResults:(NSString *)str {
    [self addLog:@"netWorkApplePayResults"];
    if (str == nil || str.length == 0) {
        [self addLog:@"netWorkApplePayResults 支付凭证为空"];
        if (self.controlLoadingBlock) {
            self.controlLoadingBlock(NO, @"支付凭证为空");
        }
        return;
    }
    NSString *endUrlStr = YunKeTang_User_user_verifyIPhoneScore;
    NSString *allUrlStr = [YunKeTang_Api_Tool YunKeTang_GetFullUrl:endUrlStr];
    
    NSMutableDictionary *mutabDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabDict setObject:str forKey:@"receipt_data"];
    
    NSString *oath_token_Str = nil;
    if (UserOathToken) {
        oath_token_Str = [NSString stringWithFormat:@"%@:%@",UserOathToken,UserOathTokenSecret];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:allUrlStr]];
    [request setHTTPMethod:NetWay];
    NSString *encryptStr = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetEncryptStr:mutabDict];
    [request setValue:encryptStr forHTTPHeaderField:HeaderKey];
    [request setValue:oath_token_Str forHTTPHeaderField:OAUTH_TOKEN];
    [self addLog:@"netWorkApplePayResults initWithRequest"];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBalanceData" object:nil];
        NSDictionary *dict = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr:responseObject];
        NSInteger errorCode = [dict[@"error_code"] integerValue];
        if (!errorCode) {
            if (self.controlLoadingBlock) {
                self.controlLoadingBlock(YES, @"支付成功");
            }
        } else {
            if (self.controlLoadingBlock) {
                self.controlLoadingBlock(NO, @"支付失败");
            }
        }
        NSLog(@"%@",dict);
        [self addLog:[NSString stringWithFormat:@"netWorkApplePayResults setCompletionBlockWithSuccess %@", dict]];

    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        [self addLog:[NSString stringWithFormat:@"netWorkApplePayResults failure %@", error.debugDescription]];

        if (self.controlLoadingBlock) {
            self.controlLoadingBlock(NO, @"支付凭证验证失败");
        }
    }];
    [op start];
}


@end
