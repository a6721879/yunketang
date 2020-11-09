//
//  STTableView.m
//  YunKeTang
//
//  Created by smelltime on 2020/6/2.
//  Copyright © 2020 ZhiYiForMac. All rights reserved.
//

#import "STTableView.h"

@implementation STTableView

- (void)setHeaderHidden:(BOOL)headerHidden {
    self.mj_header.hidden = YES;
}

- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
    // 1.创建新的header
    if (!self.mj_header) {
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:target refreshingAction:action];
    }
}

- (void)addFooterWithTarget:(id)target action:(SEL)action
{
    if (!self.mj_footer) {
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:target refreshingAction:action];
    }
}

- (void)headerEndRefreshing {
    [self.mj_header endRefreshing];
}

- (void)footerEndRefreshing {
    [self.mj_footer endRefreshing];
}

- (void)setFooterHidden:(BOOL) isHidden {
    self.mj_footer.hidden = isHidden;
}

- (void)headerBeginRefreshing {
    [self.mj_header beginRefreshing];
}

@end
