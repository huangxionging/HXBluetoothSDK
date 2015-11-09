//
//  HXBaseDevice.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HXBaseActionDataModel.h"
#import "HXBasePeripheralModel.h"

@interface HXBaseDevice : NSObject <CBPeripheralDelegate>

/**
 *  添加服务
 */
- (void) addServiceWithUUIDString: (NSString *)serviceUUIDString;

- (void) addCharacteristicWithUUIDString: (NSString *)characteristicUUIDString;

/**
 *  @brief  通过外设开始工作
 *  @param  peripheral 是外设
 *  @return void
 */
- (void) startWorkWith: (HXBasePeripheralModel *)peripheralModel;

/**
 *  @brief  发送命令
 *  @param  actionDataModel 是操作的数据模型
 *  @return void
 */
- (void) sendActionWithModel:(HXBaseActionDataModel *) actionDataModel;

/**
 *  @brief  设置更新回调, 主要用于接收外设发回的数据, 每次接收一个短包
 *  @param  upadateDataBlock 更新数据回调
 *  @return void
 */
- (void) setUpdateDataBlock: (void(^)(HXBaseActionDataModel *actionDataModel)) upadateDataBlock;

/**
 *  @brief  设置写回调, 主要是发送命令数据
 *  @param  writeDataBlock 写回调
 *  @return void
 */
- (void) setWriteDataBlock: (void(^)(HXBaseActionDataModel *actionDataModel)) writeDataBlock;

@end
