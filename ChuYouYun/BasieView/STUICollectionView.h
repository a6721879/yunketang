//
//  STUICollectionView.h
//  YunKeTang
//
//  Created by smelltime on 2020/6/4.
//  Copyright © 2020 ZhiYiForMac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STUICollectionView : UICollectionView

- (void)addHeaderWithTarget:(id)target action:(SEL)action;
- (void)addFooterWithTarget:(id)target action:(SEL)action;
- (void)headerEndRefreshing;
- (void)footerEndRefreshing;
- (void)setFooterHidden:(BOOL) isHidden;
- (void)headerBeginRefreshing;


@end

NS_ASSUME_NONNULL_END
