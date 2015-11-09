//
//  HXBaseController.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HXBaseClient, HXBaseDevice, HXBaseAction;

/**
 *  基础控制器
 */
@interface HXBaseController : NSObject

/**
 *  @brief  开始工作
 *  @param  baseClient
 *  @return void
 */
- (void) startWorkWithClient: (HXBaseClient *)baseClient;

/**
 *  @brief  设置设备
 *  @param  baseDevice 是从外部传进来的设备
 *  @return void
 */

- (void)setBaseDevice:(HXBaseDevice *)baseDevice;


/**
 *  @brief  发送操作
 *  @param  baseAction
 *  @return void
 */
- (void) sendAction: (HXBaseAction *) baseAction;

@end
