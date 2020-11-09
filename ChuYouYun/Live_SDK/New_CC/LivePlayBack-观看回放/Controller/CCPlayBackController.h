//
//  CCPlayBackController.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/11/20.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPlayBackController : UIViewController

- (instancetype)initWithUserId: (NSString*)userId roomId: (NSString*)roomId liveId: (NSString*)liveId recordId: (NSString*)recordId viewerName: (NSString*)viewerName token: (NSString*)token;

@end

NS_ASSUME_NONNULL_END
