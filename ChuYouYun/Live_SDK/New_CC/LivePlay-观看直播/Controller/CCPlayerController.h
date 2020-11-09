//
//  CCPlayerController.h
//  CCLiveCloud
//
//  Created by MacBook Pro on 2018/10/22.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPlayerController : UIViewController


/**
 初始化

 @param roomName 直播间名称
 @return self
 */
- (instancetype)initWithRoomName:(NSString *)roomName userId: (NSString*)userId roomId: (NSString*)roomId viewerName: (NSString*)viewerName token: (NSString*)token ;


@end

NS_ASSUME_NONNULL_END
