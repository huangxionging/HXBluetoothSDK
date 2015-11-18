//
//  HXBaseController.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HXBaseClient.h"
#import "HXBaseDevice.h"
#import "HXBaseAction.h"

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

/**
 *  @brief  设备开始工作, 通过传入外设模型
 *  @param  peripheralModel 是外设模型
 *  @return void
 */
- (void) deviceStartWorkWith: (HXBasePeripheralModel *) peripheralModel;

@end
