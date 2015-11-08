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
 *  基础连接, 负责查找外设
 */
@property (nonatomic, strong) HXBaseClient *baseClient;

/**
 *  基础设备, 负责管理数据
 */
@property (nonatomic, strong) HXBaseDevice *baseDevice;

/**
 *  @brief  开始工作
 *  @param  baseClient
 *  @return void
 */
- (void) startWorkWithClient: (HXBaseClient *)baseClient;


/**
 *  @brief  发送操作
 *  @param  baseAction
 *  @return void
 */
- (void) sendAction: (HXBaseAction *) baseAction;

@end
