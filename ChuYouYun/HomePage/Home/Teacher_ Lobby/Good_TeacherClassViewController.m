//
//  Good_TeacherClassViewController.m
//  dafengche
//
//  Created by 赛新科技 on 2017/11/17.
//  Copyright © 2017年 ZhiYiForMac. All rights reserved.
//

#import "Good_TeacherClassViewController.h"
#import "BigWindCar.h"
#import "SYG.h"

@interface Good_TeacherClassViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong ,nonatomic)UIView      *tabView;//放表格的视图
@property (strong, nonatomic) STTableView *oneTableView;
@property (strong ,nonatomic) STTableView *twoTableView;
@property (strong ,nonatomic) STTableView *thereTableView;

@property (strong ,nonatomic)NSMutableArray *dataArray;
@property (strong ,nonatomic)NSMutableArray *oneTableArray;
@property (strong ,nonatomic)NSMutableArray *twoTableArray;
@property (strong ,nonatomic)NSMutableArray *thereTableArray;

@property (strong ,nonatomic)NSMutableArray *oneSeleArray;
@property (strong ,nonatomic)NSMutableArray *twoSeleArray;
@property (strong ,nonatomic)NSMutableArray *thereSeleArray;
@property (strong, nonatomic) UIButton *clearButton;

@end

@implementation Good_TeacherClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self interFace];
    [self addAllView];
    [self addTabView];
    [self addClearButton];
    [self netWorkTeacherGetCategory];
}

- (void)interFace {
    self.view.backgroundColor = [UIColor clearColor];
    self.view.userInteractionEnabled = YES;
    _dataArray = [NSMutableArray array];
    _oneTableArray = [NSMutableArray array];
    _twoTableArray = [NSMutableArray array];
    _thereTableArray = [NSMutableArray array];
    
    _oneSeleArray = [NSMutableArray array];
    _twoSeleArray = [NSMutableArray array];
    _thereSeleArray = [NSMutableArray array];
    self.view.hidden = YES;
    //添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeSelfView) name:@"TeacherClassRemove" object:nil];
}

- (void)addAllView {
    if (_tabView == nil) {
        _tabView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, MainScreenHeight - MACRO_UI_UPHEIGHT - 45)];
        _tabView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
        [self.view addSubview:_tabView];
    }
    _tabView.frame = CGRectMake(0, 0, MainScreenWidth, MainScreenHeight - MACRO_UI_UPHEIGHT - 45);
}

- (void)addTabView {
    CGFloat tableViewW = MainScreenWidth / 3;
    if (_oneTableView == nil) {
        _oneTableView = [[STTableView alloc] initWithFrame:CGRectMake(0, 0, MainScreenWidth, 0) style:UITableViewStyleGrouped];
        _oneTableView.backgroundColor = [UIColor whiteColor];
        _oneTableView.dataSource = self;
        _oneTableView.delegate = self;
        _oneTableView.rowHeight = 40;
        _oneTableView.tag = 1;
        _oneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _oneTableView.showsVerticalScrollIndicator = NO;
        _oneTableView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_oneTableView];
        //iOS 11 适配
        if (currentIOS >= 11.0) {
            Passport *ps = [[Passport alloc] init];
            [ps adapterOfIOS11With:_oneTableView];
        }
    }
    _oneTableView.frame = CGRectMake(0, 0, MainScreenWidth, 0);
    
    if (_twoTableView == nil) {
        _twoTableView = [[STTableView alloc] initWithFrame:CGRectMake(tableViewW + MainScreenWidth, 0, tableViewW, 0) style:UITableViewStyleGrouped];
        _twoTableView.delegate = self;
        _twoTableView.dataSource = self;
        _twoTableView.rowHeight = 40;
        _twoTableView.tag = 2;
        _twoTableView.backgroundColor = [UIColor colorWithHexString:@"@f9f9f9"];
        _twoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _twoTableView.showsVerticalScrollIndicator = NO;
        _twoTableView.showsHorizontalScrollIndicator = NO;
        [_tabView addSubview:_twoTableView];
        
        //iOS 11 适配
        if (currentIOS >= 11.0) {
            Passport *ps = [[Passport alloc] init];
            [ps adapterOfIOS11With:_twoTableView];
        }
        
        _thereTableView = [[STTableView alloc] initWithFrame:CGRectMake(tableViewW * 2 + MainScreenWidth, 0, tableViewW, 0) style:UITableViewStyleGrouped];
        _thereTableView.delegate = self;
        _thereTableView.dataSource = self;
        _thereTableView.rowHeight = 40;
        _thereTableView.tag = 3;
        _thereTableView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4"];
        _thereTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _thereTableView.showsVerticalScrollIndicator = NO;
        _thereTableView.showsHorizontalScrollIndicator = NO;
        [_tabView addSubview:_thereTableView];
        
        _thereTableView.hidden = YES;
        
        //iOS 11 适配
        if (currentIOS >= 11.0) {
            Passport *ps = [[Passport alloc] init];
            [ps adapterOfIOS11With:_thereTableView];
        }
    }
    
    //初始化
    _oneTableView.hidden = YES;
    _twoTableView.hidden = YES;
    _thereTableView.hidden = YES;
}

- (void)addClearButton {
    //    MainScreenHeight - 200 - 109
    if (_clearButton == nil) {
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _dataArray.count * 40, MainScreenWidth, MainScreenHeight - 109 - _dataArray.count * 40)];
        _clearButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [_clearButton addTarget:self action:@selector(removeSelfView) forControlEvents:UIControlEventTouchUpInside];
        //        [self.view addSubview:_clearButton];
    }
    _clearButton.frame = CGRectMake(0, _dataArray.count * 40, MainScreenWidth, MainScreenHeight - 109 - _dataArray.count * 40);
}


#pragma mark --- UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_oneTableView == tableView) {
        return _dataArray.count;
    } else if (_twoTableView == tableView) {
        return _twoTableArray.count;
    } else if (_thereTableView == tableView) {
        return _thereTableArray.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _oneTableView) {
        static NSString *CellID = @"cellClassOne";
        //自定义cell类
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        //自定义cell类
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        }
        cell.textLabel.text = [[_dataArray objectAtIndex:indexPath.row] stringValueForKey:@"title"];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        cell.textLabel.font = Font(14);
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.selectedBackgroundView.backgroundColor =  [UIColor redColor];
        
        if ([_oneSeleArray[indexPath.row] integerValue] == 0) {
            
        } else {
            cell.textLabel.textColor = BasidColor;
            cell.backgroundColor =  [UIColor colorWithHexString:@"#f9f9f9"];
        }
        return cell;
    } else if (tableView == _twoTableView) {
        static NSString *CellID = @"cellClassTwo";
        //自定义cell类
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        //自定义cell类
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        }
        cell.textLabel.text = [[_twoTableArray objectAtIndex:indexPath.row] stringValueForKey:@"title"];
        cell.backgroundColor = [UIColor colorWithHexString:@"#f9f9f9"];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = Font(14);
        
        if ([_twoSeleArray[indexPath.row] integerValue] == 0) {
            
        } else {
            cell.textLabel.textColor = BasidColor;
            cell.backgroundColor =  [UIColor colorWithHexString:@"#f4f4f4"];
        }
        return cell;
    } else if (tableView == _thereTableView) {
        static NSString *CellID = @"cellClassThere";
        //自定义cell类
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        //自定义cell类
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        }
        cell.textLabel.text = [[_thereTableArray objectAtIndex:indexPath.row] stringValueForKey:@"title"];
        cell.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4"];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = Font(14);
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_oneTableView == tableView) {//点击一级分类的时候
        _oneTableView.hidden = NO;
        _twoTableView.hidden = NO;
        _thereTableView.hidden = YES;
        [_oneSeleArray removeAllObjects];
        for (int i = 0 ; i < _dataArray.count ; i ++) {
            if (i == indexPath.row) {
                [_oneSeleArray addObject:@"1"];
            } else {
                [_oneSeleArray addObject:@"0"];
            }
        }
        [_oneTableView reloadData];
        _twoTableArray = _dataArray[indexPath.row][@"child"];
        for (int i = 0 ;i < _twoTableArray.count ; i ++) {
            [_twoSeleArray addObject:@"0"];
        }
        CGFloat mainHeight = _dataArray.count > _twoTableArray.count ? _dataArray.count * 40 : _twoTableArray.count * 40;
        CGFloat allTableViewHeight = mainHeight > _tabView.height ? _tabView.height : mainHeight;
        [UIView animateWithDuration:0.25 animations:^{
            _oneTableView.frame = CGRectMake(0, 0, MainScreenWidth / 2, allTableViewHeight);
            _twoTableView.frame = CGRectMake(MainScreenWidth / 2, 0, MainScreenWidth / 2, allTableViewHeight);
            _thereTableView.frame = CGRectMake(MainScreenWidth / 3 * 2 + MainScreenWidth, 0, 0, allTableViewHeight);
        }];
        if ([[_dataArray objectAtIndex:indexPath.row] arrayValueForKey:@"child"] == nil) {//说明只有一级
            NSDictionary *dict = _dataArray[indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationTeacherClassTypeID" object:dict];
            [self removeSelfView];
            return;
        }
        [_twoTableView reloadData];
    } else if (_twoTableView == tableView) {//点击二级分类
        _oneTableView.hidden = NO;
        _twoTableView.hidden = NO;
        _thereTableView.hidden = NO;
        //点击处理
        [_twoSeleArray removeAllObjects];
        for (int i = 0 ; i < _twoTableArray.count ; i ++) {
            if (i == indexPath.row) {
                [_twoSeleArray addObject:@"1"];
            } else {
                [_twoSeleArray addObject:@"0"];
            }
        }
        [_twoTableView reloadData];
        _thereTableArray = _twoTableArray[indexPath.row][@"child"];
        CGFloat mainHeight = _dataArray.count > _twoTableArray.count ? _dataArray.count * 40 : _twoTableArray.count * 40;
        CGFloat passHeight = mainHeight > _thereTableArray.count * 40 ? mainHeight : _thereTableArray.count * 40;
        CGFloat allTableViewHeight = passHeight > _tabView.height ? _tabView.height : passHeight;
        [UIView animateWithDuration:0.25 animations:^{
            _oneTableView.frame = CGRectMake(0, 0, MainScreenWidth / 3, allTableViewHeight);
            _twoTableView.frame = CGRectMake(MainScreenWidth / 3, 0, MainScreenWidth / 3, allTableViewHeight);
            _thereTableView.frame = CGRectMake(MainScreenWidth / 3 * 2, 0, MainScreenWidth / 3, allTableViewHeight);
        }];
        if (_thereTableArray.count == 0) {
            NSDictionary *dict = _twoTableArray[indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationTeacherClassTypeID" object:dict];
            [self removeSelfView];
            return;
        }
        [_thereTableView reloadData];
    } else if (_thereTableView == tableView) {//点击三级分类
        //通知
        NSDictionary *dict = _thereTableArray[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationTeacherClassTypeID" object:dict];
        [self removeSelfView];
    }
}

#pragma mark --- 事件点击
- (void)clearButtonCilck:(UIButton *)button {
    [self removeSelfView];
}

#pragma mark --- 通知
-(void)removeSelfView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationTeacherClassTypeButton" object:nil];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark --- 网络请求
- (void)netWorkTeacherGetCategory {
    
    NSString *endUrlStr = YunKeTang_Teacher_teacher_getCategory;
    NSString *allUrlStr = [YunKeTang_Api_Tool YunKeTang_GetFullUrl:endUrlStr];
    
    NSMutableDictionary *mutabDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [mutabDict setObject:@"20" forKey:@"count"];
    //    NSString *oath_token_Str = nil;
    if (UserOathToken) {
        //        oath_token_Str = [NSString stringWithFormat:@"%@:%@",UserOathToken,UserOathTokenSecret];
        //        [mutabDict setObject:oath_token_Str forKey:OAUTH_TOKEN];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:allUrlStr]];
    [request setHTTPMethod:NetWay];
    NSString *encryptStr = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetEncryptStr:mutabDict];
    [request setValue:encryptStr forHTTPHeaderField:HeaderKey];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *dict = [YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr_Before:responseObject];
        if ([[dict stringValueForKey:@"code"] integerValue] == 1) {
            if ([[dict arrayValueForKey:@"data"] isKindOfClass:[NSArray class]]) {
                _dataArray = (NSMutableArray *)[dict arrayValueForKey:@"data"];
            } else {
                _dataArray = (NSMutableArray *)[YunKeTang_Api_Tool YunKeTang_Api_Tool_GetDecodeStr:responseObject];
            }
            
            for (int i = 0 ; i < _dataArray.count ; i ++) {
                [_oneSeleArray addObject:@"0"];
            }
            if (_dataArray.count * 40 < _tabView.height) {
                _oneTableView.frame = CGRectMake(0, 0, MainScreenWidth, _dataArray.count * 40);
            } else {
                _oneTableView.frame = CGRectMake(0, 0, MainScreenWidth, _tabView.height);
            }
        }
        [_oneTableView reloadData];
        if (_dataArray.count>0) {
            _oneTableView.hidden = NO;
            self.view.hidden = NO;
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
    }];
    [op start];
}




@end
