//
//  ZhiBoClassViewController.m
//  dafengche
//
//  Created by 赛新科技 on 2017/5/20.
//  Copyright © 2017年 ZhiYiForMac. All rights reserved.
//

#import "ZhiBoClassViewController.h"
#import "SYG.h"
#import "MyHttpRequest.h"
#import "TKProgressHUD+Add.h"
#import "ZhiBoClassCell.h"
#import "BigWindCar.h"
#import "AppDelegate.h"
#import "rootViewController.h"

#import "DLViewController.h"
#import "ClassAndLivePayViewController.h"


//GenSee
#import "GenSeeLiveViewController.h"
#import "GenSeePlayBackViewController.h"

//。CC 直播
//#import "CCSDK/CCLiveUtil.h"
//#import "CCSDK/RequestData.h"
//#import "CCSDK/RequestDataPlayBack.h"
//#import "CCHHPlayViewController.h"
//#import "CCHHPlayBackViewController.h"

//#import "PlayForPCVC.h"
//#import "PlayBackVC.h"
//#import "InformationShowView.h"
//#import "Masonry.h"


//#import <QuartzCore/QuartzCore.h>
//#import "QRCodeReaderViewController.h"
//#import "QRCodeReader.h"
//#import "QRCodeReaderDelegate.h"


//CC直播
#import "CCSDK/CCLiveUtil.h"
#import "CCSDK/RequestData.h"
#import "CCSDK/RequestDataPlayBack.h"
//#import "CCHHPlayViewController.h"
//#import "CCHHPlayBackViewController.h"

#import "InformationShowView.h"
#import "Masonry.h"


#import <QuartzCore/QuartzCore.h>
#import "CCPlayerController.h"
#import "CCPlayBackController.h"


@interface ZhiBoClassViewController ()<UITableViewDataSource,UITableViewDelegate,RequestDataDelegate,RequestDataPlayBackDelegate,UIScrollViewDelegate,VodDownLoadDelegate>
{
    BOOL islivePlay;
    NSInteger _indexPathRow;
}
@property (strong ,nonatomic)UIImageView *imageView;

@property (strong ,nonatomic)NSArray *dataArray;
@property (strong ,nonatomic)NSDictionary *liveInfo;
@property (strong ,nonatomic)NSString *ID;
@property (strong ,nonatomic)NSString *HDtitle;
@property (strong ,nonatomic)NSString *HDnickName;
@property (strong ,nonatomic)NSString *HDwatchPassword;
@property (strong ,nonatomic)NSString *HDroomNumber;
@property (strong ,nonatomic)NSString *typeStr;

@property (assign ,nonatomic)BOOL isBuyZhiBo;
@property (strong ,nonatomic) VodDownLoader *voddownloader;
@property (strong ,nonatomic)NSDictionary *playLiveBackDic;
@property (strong ,nonatomic)GenSeePlayBackViewController *genseePlayBackVc;


@property (assign, nonatomic) NSInteger                 liveType;
@property (strong ,nonatomic) NSDictionary *CCDict;

//CC
@property (strong ,nonatomic)PlayParameter  *playParameter;
@property (strong ,nonatomic)RequestData    *requestData;

@property (strong ,nonatomic)NSDictionary *VHDict;

//小班课
//@property (strong ,nonatomic)CC_LoadingView  *loadingView;
//@property (assign, nonatomic) CCRole role;//角色
//@property (assign, nonatomic) BOOL isLandSpace;//是否横屏
//@property (strong ,nonatomic)NSDictionary  *classRoomDict;//小班课的字典
@property (strong ,nonatomic)UIAlertView   *alter;

@property (strong ,nonatomic)NSDictionary  *dataSource;



@end

@implementation ZhiBoClassViewController

-(instancetype)initWithNumID:(NSString *)ID{
    
    self = [super init];
    if (self) {
        _ID = ID;
    }
    return self;
}

-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, MainScreenWidth,_tabelHeight)];
        _imageView.image = [UIImage imageNamed:@"云课堂_空数据"];
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app = [AppDelegate delegate];
    rootViewController * nv = (rootViewController *)app.window.rootViewController;
    [nv isHiddenCustomTabBarByBoolean:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self netWorkLiveGetInfo];
}

-(void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *app = [AppDelegate delegate];
    rootViewController * nv = (rootViewController *)app.window.rootViewController;
    [nv isHiddenCustomTabBarByBoolean:NO];
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self interFace];
    [self addTableView];
    [self netWorkLiveGetInfo];
}

- (void)interFace {
    self.view.backgroundColor = [UIColor whiteColor];
    _isBuyZhiBo = NO;
}


- (void)addTableView {
    
    _tableView = [[STTableView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, _tabelHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    [self.view addSubview:_tableView];
    
    //iOS 11 适配
    if (currentIOS >= 11.0) {
        Passport *ps = [[Passport alloc] init];
        [ps adapterOfIOS11With:_tableView];
    }
}

#pragma mark ---- UITableVieDataSoruce

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellID = @"LiveDetailOneCell";
    //自定义cell类
    ZhiBoClassCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    //自定义cell类
    if (cell == nil) {
        cell = [[ZhiBoClassCell alloc] initWithReuseIdentifier:CellID];
    }
    [cell.numberButton setTitle:[NSString stringWithFormat:@"%ld",indexPath.row + 1] forState:UIControlStateNormal];
    NSDictionary *dict = _dataArray[indexPath.row];
    [cell dataWithDict:dict WithLiveInfo:_liveInfo];
    //吧滚动的范围传到主页去
    CGFloat tableHight = _dataArray.count * _tableView.rowHeight;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    _indexPathRow = indexPath.row;
    if ([[[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"note"] isEqualToString:@"已结束"]) {
        [TKProgressHUD showError:@"该课时已结束" toView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    // 这里应该判断是否已经登录
    if (UserOathToken == nil) {
        //没有登录的情况下
        DLViewController *DLVC = [[DLViewController alloc] init];
        UINavigationController *Nav = [[UINavigationController alloc] initWithRootViewController:DLVC];
        [self.navigationController presentViewController:Nav animated:YES completion:nil];
        return;
    }else{
        if (_isBuyZhiBo == YES) {
            NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            _HDnickName = [defaults objectForKey:@"uname"];
            //参数
            _HDtitle = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"subject"];
            NSString *ID = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"live_id"];
            NSString *secitonID = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"section_id"];
            [self netWorkLiveGetCatalogWithSection:secitonID WithID:ID];
        } else {//提示课时解锁
            
            NSDictionary *cellDict = [_dataArray objectAtIndex:indexPath.row];
            if ([[_liveInfo stringValueForKey:@"price"] floatValue] == 0) {//免费的（但是还是需要添加订单）
                if ([[cellDict stringValueForKey:@"is_buy"] integerValue] == 1) {//已经解锁
                    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                    _HDnickName = [defaults objectForKey:@"uname"];
                    //参数
                    _HDtitle = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"subject"];
                    NSString *ID = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"live_id"];
                    NSString *secitonID = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"section_id"];
                    [self netWorkLiveGetCatalogWithSection:secitonID WithID:ID];
                } else {//没有解锁
                    [TKProgressHUD showError:@"请先解锁本直播才能观看" toView:[UIApplication sharedApplication].keyWindow];
                    return;
                }
            } else {
                if ([[cellDict stringValueForKey:@"is_buy"] integerValue] == 1) {//已经解锁
                    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
                    _HDnickName = [defaults objectForKey:@"uname"];
                    //参数
                    _HDtitle = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"subject"];
                    NSString *ID = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"live_id"];
                    NSString *secitonID = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"section_id"];
                    [self netWorkLiveGetCatalogWithSection:secitonID WithID:ID];
                } else {//没有解锁
                    if ([[cellDict stringValueForKey:@"course_hour_price"] floatValue] == 0) {
                        [TKProgressHUD showError:@"请先解锁本直播才能观看" toView:[UIApplication sharedApplication].keyWindow];
                        return;
                    } else {
                        [self gotoBuyLive];
                    }
                }
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.cellTabelCanScroll) {
        scrollView.contentOffset = CGPointZero;
    }
    if (scrollView.contentOffset.y <= 0) {
        self.cellTabelCanScroll = NO;
        scrollView.contentOffset = CGPointZero;
        self.vc.canScroll = YES;
    }
}

#pragma MARK --- 事件处理
- (void)gotoBuyLive {
    ClassAndLivePayViewController *payVc = [[ClassAndLivePayViewController alloc] init];
    payVc.dict = _liveInfo;
    payVc.cellDict = [_dataArray objectAtIndex:_indexPathRow];
    payVc.cid = _ID;
    payVc.typeStr = @"2";
    [self.navigationController pushViewController:payVc animated:YES];
}

#pragma mark --- 网络请求

- (void)netWorkLiveGetInfo {
    
    NSString *endUrlStr = YunKeTang_Live_live_getInfo;
    NSString *allUrlStr = [YunKeTang_Api_Tool YunKeTang_GetFullUrl:endUrlStr];
    
    NSMutableDictionary *mutabDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabDict setObject:_ID forKey:@"live_id"];
    
    NSString *oath_token_Str = nil;
    if (UserOathToken) {
        oath_token_Str = [NSString stringWithFormat:@"%@:%@",UserOathToken,UserOathTokenSecret];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:allUrlStr]];
    [request setHTTPMethod:NetWay];
    NSString *encryptStr = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetEncryptStr:mutabDict];
    [request setValue:encryptStr forHTTPHeaderField:HeaderKey];
    [request setValue:oath_token_Str forHTTPHeaderField:OAUTH_TOKEN];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *dict = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr_Before:responseObject];
        if ([[dict stringValueForKey:@"code"] integerValue] == 1) {
            if ([[dict dictionaryValueForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                dict = [dict dictionaryValueForKey:@"data"];
            } else {
                dict = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr:responseObject];
            }
            if ([dict isEqual:[NSArray array]]) {
                return ;
            }
            _liveInfo = dict;
            _dataArray = [dict arrayValueForKey:@"sections"];
            if ([[dict stringValueForKey:@"is_buy"] integerValue] == 1) {
                _isBuyZhiBo = YES;
            } else {
                _isBuyZhiBo = NO;
            }
            if (_dataArray.count == 0) {
                self.imageView.hidden = NO;
            } else {
                self.imageView.hidden = YES;
            }
            [_tableView reloadData];
        } else {
            return ;
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    }];
    [op start];
}


//直播详情
- (void)netWorkLiveGetCatalogWithSection:(NSString *)secitonID WithID:(NSString *)ID {
    
    NSString *endUrlStr = YunKeTang_Live_live_getCatalog;
    NSString *allUrlStr = [YunKeTang_Api_Tool YunKeTang_GetFullUrl:endUrlStr];
    
    NSMutableDictionary *mutabDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabDict setObject:ID forKey:@"live_id"];
    [mutabDict setValue:secitonID forKey:@"section_id"];
    
    NSString *oath_token_Str = nil;
    if (UserOathToken) {
        oath_token_Str = [NSString stringWithFormat:@"%@:%@",UserOathToken,UserOathTokenSecret];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:allUrlStr]];
    [request setHTTPMethod:NetWay];
    NSString *encryptStr = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetEncryptStr:mutabDict];
    [request setValue:encryptStr forHTTPHeaderField:HeaderKey];
    [request setValue:oath_token_Str forHTTPHeaderField:OAUTH_TOKEN];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *dict = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr_Before:responseObject];
        if ([[dict stringValueForKey:@"code"] integerValue] == 1) {
            dict = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr:responseObject];
            if ([[dict stringValueForKey:@"type"] integerValue] == 1) {//gensee
                dict = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr:responseObject];
                _typeStr = [dict stringValueForKey:@"type"];
                if ([[dict stringValueForKey:@"type"] integerValue] == 1) {//gensee
                    BOOL isPlayBack = NO;
                    if ([dict[@"body"][@"is_live"] integerValue] == 1) {//直播
                        isPlayBack = NO;
                    } else if ([dict[@"body"][@"is_live"] integerValue] == 0){//回放
                        isPlayBack = YES;
                    }
                    if (isPlayBack == NO) {
                        NSDictionary *bodyDict = [dict dictionaryValueForKey:@"body"];
                        NSString *title = _HDtitle;
                        NSString *name = [bodyDict stringValueForKey:@"account"];
                        NSString *pwd = [bodyDict stringValueForKey:@"pwd"];
                        NSString *number = [bodyDict stringValueForKey:@"number"];
                        GenSeeLiveViewController *vc = [[GenSeeLiveViewController alloc] init];
                        [vc initwithTitle:title nickName:name watchPassword:pwd roomNumber:number];
                        vc.account = name;
                        vc.domain = [bodyDict stringValueForKey:@"domain"];
                        vc.typeStr = _typeStr;
                        [self.navigationController pushViewController:vc animated:YES];
                    } else if (isPlayBack == YES) {
                        NSDictionary *livePlaybackDict = dict[@"body"];
                        
                        NSString *string = dict[@"live_url"];
                        NSRange startRange = [string rangeOfString:@"https://"];
                        NSRange endRange = [string rangeOfString:@"/training"];
                        NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
                        NSString *result = [string substringWithRange:range];
                        NSLog(@"%@",result);
                        
                        NSString *playBackLiveUrl = [livePlaybackDict stringValueForKey:@"livePlayback"];
                        NSArray *arrayOne = [playBackLiveUrl componentsSeparatedByString:@"?"];
                        NSString *strOne = arrayOne[0];
                        NSArray *arrayTwo = [strOne componentsSeparatedByString:@"/"];
                        NSString *lastNumber = arrayTwo[arrayTwo.count - 1];
                        
                        NSString *tokenStrOne = arrayOne[1];
                        NSArray  *arrayTokenOne = [tokenStrOne componentsSeparatedByString:@"="];
                        NSString *lastToken = arrayTokenOne[arrayTokenOne.count - 1];
                        if (!_voddownloader) {
                            _voddownloader = [[VodDownLoader alloc] initWithDelegate:self];
                        }
                        [_voddownloader addItem:result number:lastNumber loginName:@"用户1" vodPassword:lastToken loginPassword:livePlaybackDict[@"number"] downFlag:0 serType:@"training" oldVersion:NO kToken:nil customUserID:0];
                    }
                } else {
                    [TKProgressHUD showError:@"不支持直播类型" toView: [UIApplication sharedApplication].keyWindow];
                    return ;
                }
            } else if ([[dict stringValueForKey:@"type"] integerValue] == 4) {//CC
                if ([dict[@"body"][@"is_live"] integerValue] == 1) {//直播
                    [self useCCLive:dict[@"body"]];
                } else if ([dict[@"body"][@"is_live"] integerValue] == 0){//回放
                    _CCDict = dict[@"body"];
                    [self CCPlayBack];
                }
            } else if ([[dict stringValueForKey:@"type"] integerValue] == 9) {//新展示
                BOOL isPlayBack = NO;
                if ([dict[@"body"][@"is_live"] integerValue] == 1) {//直播
                    isPlayBack = NO;
                } else if ([dict[@"body"][@"is_live"] integerValue] == 0){//回放
                    isPlayBack = YES;
                }
                if (isPlayBack == NO) {
                    NSDictionary *bodyDict = [dict dictionaryValueForKey:@"body"];
                    NSString *title = _HDtitle;
                    NSString *name = [bodyDict stringValueForKey:@"account"];
                    NSString *pwd = [bodyDict stringValueForKey:@"pwd"];
                    NSString *number = [bodyDict stringValueForKey:@"number"];
                    GenSeeLiveViewController *vc = [[GenSeeLiveViewController alloc] init];
                    [vc initwithTitle:title nickName:name watchPassword:pwd roomNumber:number];
                    vc.account = name;
                    vc.domain = [bodyDict stringValueForKey:@"domain"];
                    [self.navigationController pushViewController:vc animated:YES];
                } else if (isPlayBack == YES) {
                    NSDictionary *livePlaybackDict = dict[@"body"];
                    
                    NSString *string = livePlaybackDict[@"domain"];
                    NSRange startRange = [string rangeOfString:@"https://"];
                    NSRange endRange = [string rangeOfString:@"/webcast"];
                    NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
                    NSString *result = [string substringWithRange:range];
                    NSLog(@"%@",result);
                    
                    NSString *playBackLiveUrl = [livePlaybackDict stringValueForKey:@"livePlayback"];
                    NSArray *arrayOne = [playBackLiveUrl componentsSeparatedByString:@"?"];
                    NSString *strOne = arrayOne[0];
                    NSArray *arrayTwo = [strOne componentsSeparatedByString:@"-"];
                    NSString *lastNumber = arrayTwo[arrayTwo.count - 1];
                    
//                    VodParam *item = [[VodParam alloc] init];
//                    item.number = [livePlaybackDict stringValueForKey:@"number"];
//                    item.loginName = [livePlaybackDict stringValueForKey:@"account"];
//                    item.vodPassword = [livePlaybackDict stringValueForKey:@"join_pwd"];
//                    item.loginPassword = [livePlaybackDict stringValueForKey:@"pwd"];
//                    item.vodID = lastNumber;
//                    item.serviceType = @"webcast";
//                    [_voddownloader addItem:item];
                    if (!_voddownloader) {
                        _voddownloader = [[VodDownLoader alloc] initWithDelegate:self];
                    }
                    [_voddownloader addItem:result
                                     number:[livePlaybackDict stringValueForKey:@"number"]
                                  loginName:[livePlaybackDict stringValueForKey:@"account"]
                                vodPassword:[livePlaybackDict stringValueForKey:@"join_pwd"]
                              loginPassword:[livePlaybackDict stringValueForKey:@"pwd"]
                                      vodid:lastNumber
                                   downFlag:0
                                    serType:@"webcast"
                                 oldVersion:NO
                                     kToken:nil
                               customUserID:0];
                    
                }
            } else {
                [TKProgressHUD showError:@"不支持直播类型" toView: [UIApplication sharedApplication].keyWindow];
                return ;
            }
        } else {
            [TKProgressHUD showError:[dict stringValueForKey:@"msg"] toView:[UIApplication sharedApplication].keyWindow];
            return ;
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    }];
    [op start];
}

#pragma mark --- GenSee
- (void)onAddItemResult:(RESULT_TYPE)resultType voditem:(downItem *)item
{
    islivePlay = YES;
    NSLog(@"状态resultType----%d",resultType);
    
    
    if (resultType == RESULT_SUCCESS) {
        if (islivePlay) {
            if (!_genseePlayBackVc) {
                _genseePlayBackVc = [[GenSeePlayBackViewController alloc] init];
            }
            [_genseePlayBackVc setItem:item];
            [_genseePlayBackVc setIsLivePlay:YES];
            _genseePlayBackVc.typeStr = _typeStr;
            [self.navigationController pushViewController:_genseePlayBackVc animated:YES];
        } else {
            
        }
    }else if (resultType == RESULT_ROOM_NUMBER_UNEXIST){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"点播间不存在" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
    }else if (resultType == RESULT_FAILED_NET_REQUIRED){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"网络请求失败" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
    }else if (resultType == RESULT_FAIL_LOGIN){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"用户名或密码错误" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
    }else if (resultType == RESULT_NOT_EXSITE){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"该点播的编号的点播不存在" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
    }else if (resultType == RESULT_INVALID_ADDRESS){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"无效地址" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
    }else if (resultType == RESULT_UNSURPORT_MOBILE){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"不支持移动设备" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
    }else if (resultType == RESULT_FAIL_TOKEN){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"口令错误" ,@"") delegate:nil cancelButtonTitle:NSLocalizedString(@"知道了",@"") otherButtonTitles:nil, nil];
        [alertView show];
    }
    [TKProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark --- CC

- (void)useCCLive:(NSDictionary *)dict {//CC 直播
    NSLog(@"----%@",dict);
    _CCDict = dict;
    NSString *strUserId = [dict stringValueForKey:@"userid"];
    NSString *strRoomId = [dict stringValueForKey:@"roomid"];
    NSString *strViewName = [dict stringValueForKey:@"account"];
    NSString *strToken = [dict stringValueForKey:@"join_pwd"];
    
    BOOL haveEmpty = false;
    
    
    if (strUserId == nil || strUserId.length == 0) {
        haveEmpty = true;
    }
    if (strRoomId == nil || strRoomId.length == 0) {
        haveEmpty = true;
    }
    if (strViewName == nil || strViewName.length == 0) {
        haveEmpty = true;
    }
    if (strToken == nil || strToken.length == 0) {
        haveEmpty = true;
    }
    
    if (haveEmpty == false) {
    }
    
    if (haveEmpty == false) {
        
        UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
        returnButtonItem.title = @"返回";
        self.navigationItem.backBarButtonItem = returnButtonItem;
        
        if (self.liveType == 0) {
            //            RequestData *requestData = [[RequestData alloc] initOnlyLoginWithUserId:strUserId RoomId:strRoomId ViewerName:strViewName ViewerToken:strToken security:YES];
            //            requestData.delegate = self;
            
        } else if(self.liveType == 1) {
            //            RequestDataPlayBack *requestDataPlayBack = [[RequestDataPlayBack alloc] initOnlyLoginWithUserId:strUserId RoomId:strRoomId Liveid:strLevelId Viewername:strViewName Viewertoken:strToken security:YES];
            //            requestDataPlayBack.delegate = self;
        }
        
        PlayParameter *parameter = [[PlayParameter alloc] init];
        parameter.userId = strUserId;
        parameter.roomId = strRoomId;
        parameter.viewerName = strViewName;
        parameter.token = strToken;
        parameter.security = YES;
        parameter.viewerCustomua = @"viewercustomua";
        _requestData = [[RequestData alloc] initLoginWithParameter:parameter];
        _requestData.delegate = self;
        
    }
}

#pragma mark --- CC 直播代理方法

#pragma mark - CCPushDelegate
//@optional
/**
 *    @brief    请求成功
 */
-(void)loginSucceedPlay {
    NSLog(@"%@",_CCDict);
    
    NSString *strUserId = [_CCDict stringValueForKey:@"userid"];
    NSString *strRoomId = [_CCDict stringValueForKey:@"roomid"];
    NSString *strViewName = _HDnickName;
    NSString *strToken = [_CCDict stringValueForKey:@"join_pwd"];
    CCPlayerController *vc = [[CCPlayerController alloc]initWithRoomName:strViewName userId:strUserId roomId:strRoomId viewerName:strViewName token:strToken];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)loginFailed:(NSError *)error reason:(NSString *)reason {
    NSString *message = nil;
    if (reason == nil) {
        message = [error localizedDescription];
    } else {
        message = reason;
    }
    
    [TKProgressHUD showError:message toView:self.view];
}

#pragma mark -- CC 回放
- (void)CCPlayBack {
    NSLog(@"%@",_CCDict);
    PlayParameter *parameter = [[PlayParameter alloc] init];
    parameter.userId = [_CCDict stringValueForKey:@"userid"];
    parameter.roomId = [_CCDict stringValueForKey:@"roomid"];
    parameter.liveId = [_CCDict stringValueForKey:@"livePlayback"];
    
    
    parameter.viewerName = _HDnickName;
    parameter.token = [_CCDict stringValueForKey:@"join_pwd"];
    parameter.security = YES;
    
    NSLog(@"%@",parameter.viewerName);
    NSLog(@"%@",parameter.userId);
    NSLog(@"%@",parameter.roomId);
    NSLog(@"%@",parameter.liveId);
    NSLog(@"%@",parameter.token);
    
    RequestDataPlayBack *requestDataPlayBack = [[RequestDataPlayBack alloc] initLoginWithParameter:parameter];
    requestDataPlayBack.delegate = self;
}

#pragma mark -- CC回放的代理方法
//@optional
/**
 *    @brief    请求成功
 */
-(void)loginSucceedPlayBack {
    
    NSString *userID = [_CCDict stringValueForKey:@"userid"];
    NSString *roomID = [_CCDict stringValueForKey:@"roomid"];
    NSString *liveID = [_CCDict stringValueForKey:@"livePlayback"];
    NSString *name = _HDnickName;
    NSString *token = [_CCDict stringValueForKey:@"join_pwd"];
    CCPlayBackController *vc = [[CCPlayBackController alloc]initWithUserId:userID roomId:roomID liveId:liveID recordId:@"" viewerName:name token:token];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}



#pragma mark --- 微吼直播

- (void)VHPlayer {
    
}

#pragma mark --- CC  小班课

//移除警告框
- (void)removeAlert:(NSTimer*)theTimer//弹出框
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
    promptAlert =NULL;
}





@end
