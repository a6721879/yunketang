//
//  MyAnswerViewController.m
//  dafengche
//
//  Created by 赛新科技 on 2017/7/13.
//  Copyright © 2017年 ZhiYiForMac. All rights reserved.
//

#import "MyAnswerViewController.h"
#import "SYG.h"
#import "rootViewController.h"
#import "AppDelegate.h"
#import "BigWindCar.h"
#import "MJRefresh.h"
#import "ZhiyiHTTPRequest.h"
#import "MYWDTableViewCell.h"
#import "Good_QuesAndAnsTableViewCell.h"
#import "Good_QuesAndAnsDetailViewController.h"

@interface MyAnswerViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong ,nonatomic) STTableView *tableView;

@property (strong ,nonatomic)NSMutableArray *dataArray;

@property (assign ,nonatomic)NSInteger number;

@property (strong ,nonatomic)UIImageView *imageView;

@end

@implementation MyAnswerViewController

-(void)viewWillAppear:(BOOL)animated
{
    AppDelegate *app = [AppDelegate delegate];
    rootViewController * nv = (rootViewController *)app.window.rootViewController;
    [nv isHiddenCustomTabBarByBoolean:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
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
    [self addNav];
    [self addTableView];
    [self netWorkUserLineVideoGetMyAnswerList];
    
}
- (void)interFace {
    
    self.view.backgroundColor = [UIColor whiteColor];
    _number = 1;
}

- (void)addNav {
    
    UIView *SYGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, 64)];
    SYGView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:SYGView];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"通用返回"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
    [SYGView addSubview:backButton];
    
    //添加中间的文字
    UILabel *WZLabel = [[UILabel  alloc] initWithFrame:CGRectMake(50, 25,MainScreenWidth - 100, 30)];
    WZLabel.text = @"退款申请";
    [WZLabel setTextColor:BasidColor];
    WZLabel.textAlignment = NSTextAlignmentCenter;
    WZLabel.font = [UIFont systemFontOfSize:20];
    [SYGView addSubview:WZLabel];
    
    //添加线
    UILabel *lineLab = [[UILabel  alloc] initWithFrame:CGRectMake(0, 63,MainScreenWidth, 1)];
    lineLab.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
    [SYGView addSubview:lineLab];
    
    
}

- (void)backPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- UITableView

- (void)addTableView {
    
    _tableView = [[STTableView alloc] initWithFrame:CGRectMake(0, 98, MainScreenWidth, MainScreenHeight - 98 + 36) style:UITableViewStyleGrouped];
    if (iPhoneX) {
        _tableView.frame = CGRectMake(0, 98, MainScreenWidth, MainScreenHeight - 88 - 34 + 36);
    }
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView addHeaderWithTarget:self action:@selector(headerRerefreshings)];
    [_tableView headerBeginRefreshing];
    [_tableView addFooterWithTarget:self action:@selector(footerRefreshing)];
    
    //iOS 11 适配
    if (currentIOS >= 11.0) {
        Passport *ps = [[Passport alloc] init];
        [ps adapterOfIOS11With:_tableView];
    }
}


#pragma mark --- 刷新

- (void)headerRerefreshings
{
//    [self netWorkWithNumber:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        [_tableView headerEndRefreshing];
    });
}

- (void)footerRefreshing
{
    _number++;
//    [self netWorkWithNumber:_number];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        [_tableView footerEndRefreshing];
    });
}


#pragma mark --- UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.05;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height + 0 * WideEachUnit;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *CellIdentifier = @"culture";
//    //自定义cell类
//    MYWDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[MYWDTableViewCell alloc] initWithReuseIdentifier:CellIdentifier];
//    }
//    cell.titleLabel.text = _dataArray[indexPath.row][@"wd_description"];
//    cell.timeLabel.text =  _dataArray[indexPath.row][@"ctime"];
//    cell.personLabel.text = [NSString stringWithFormat:@"%@人回答",_dataArray[indexPath.row][@"wd_comment_count"]];
//
//    return cell;
    
    static NSString * cellStr = @"WDTableViewCell";
    Good_QuesAndAnsTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    
    if (cell == nil) {
        cell = [[Good_QuesAndAnsTableViewCell alloc] initWithReuseIdentifier:cellStr];
    }
    NSDictionary *dict = [_dataArray objectAtIndex:indexPath.row];
    [cell dataWithDict:dict];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Good_QuesAndAnsDetailViewController *vc = [[Good_QuesAndAnsDetailViewController alloc] init];
    vc.dict = [_dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ----网络请求

- (void)netWorkMYQ {//我的问题
    
    ZhiyiHTTPRequest *manager = [ZhiyiHTTPRequest manager];
    NSMutableDictionary *dic =  [[NSMutableDictionary alloc]initWithCapacity:0];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"oauthToken"] forKey:@"oauth_token"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"oauthTokenSecret"] forKey:@"oauth_token_secret"];
    
    [manager MYQestion:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"^^^^^%@",responseObject);
        _dataArray = responseObject[@"data"];
        
        if (_dataArray.count == 0) {//没有内容的时候
            //添加空白处理
            
            if (_imageView.subviews == nil) {//说明是没有的
                _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight - 98)];
                _imageView.image = [UIImage imageNamed:@"云课堂_空数据"];
            } else {//已经存在了
                _imageView.image = [UIImage imageNamed:@"云课堂_空数据"];
            }
            
            [_tableView addSubview:_imageView];
            _imageView.hidden = NO;
            
        } else {
            _imageView.hidden = YES;
            self.tableView.alpha = 1.0;
            _imageView.hidden = YES;
            
            [self.tableView reloadData];
        }
        [_tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog ( @"operation1: %@" , operation. responseString);
        [self.tableView reloadData];
    }];
}


#pragma mark --- 网络请求
- (void)netWorkUserLineVideoGetMyAnswerList {
    
    NSString *endUrlStr = YunKeTang_User_wenda_getMyQuestionList;
    NSString *allUrlStr = [YunKeTang_Api_Tool YunKeTang_GetFullUrl:endUrlStr];
    
    NSMutableDictionary *mutabDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabDict setObject:@"10" forKey:@"count"];
    
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
            if ([[dict arrayValueForKey:@"data"] isKindOfClass:[NSArray class]]) {
                _dataArray = (NSMutableArray *) [dict arrayValueForKey:@"data"];
            } else {
                 _dataArray = (NSMutableArray *) [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr:responseObject];
            }
        }
        if (_dataArray.count == 0) {
            //添加空白处理
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, MainScreenWidth, MainScreenHeight - 64 - 48)];
            imageView.image = [UIImage imageNamed:@"云课堂_空数据"];
            [self.view addSubview:imageView];
        }
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
    }];
    [op start];
}





@end
