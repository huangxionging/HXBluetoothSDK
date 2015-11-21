//
//  HXWKLController.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseController.h"
#import "HXWKLSearchDeviceAction.h"
#import "HXWKLBindDeviceAction.h"


typedef NS_ENUM(NSUInteger, BlockType) {
    kBlockTypeClient = 0,
    kBlockTypeDevice,
    
};


@interface HXWKLController : HXBaseController

/**
 *  @brief  开始工作
 *  @param  void
 *  @return void
 */
- (void) startWork;

- (void) setBlock: (void(^)(BOOL finished, BlockType type)) block;


@end
