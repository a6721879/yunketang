//
//  STTableView.h
//  YunKeTang
//
//  Created by smelltime on 2020/6/2.
//  Copyright © 2020 ZhiYiForMac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STTableView : UITableView

- (void)addHeaderWithTarget:(id)target action:(SEL)action;
- (void)addFooterWithTarget:(id)target action:(SEL)action;
- (void)headerEndRefreshing;
- (void)footerEndRefreshing;
- (void)setFooterHidden:(BOOL) isHidden;
- (void)headerBeginRefreshing;

@property (nonatomic, assign) BOOL headerHidden;

@end

NS_ASSUME_NONNULL_END
