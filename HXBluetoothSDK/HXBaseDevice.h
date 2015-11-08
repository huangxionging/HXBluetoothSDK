//
//  HXBaseDevice.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBPeripheral;

@interface HXBaseDevice : NSObject

/**
 *  外设.
 */
@property (nonatomic, strong) CBPeripheral *peripheral;

// 
- (instancetype) initWithPeriheral: (CBPeripheral *) peripheral;

- (void) start;

/**
 *  @brief  设置更新回调, 主要用于接收外设发回的数据, 每次接收一个短包
 *  @param  upadateDataSuccessBlock 更新成功回调, updateDataFailureBlock 更新失败回调
 *  @return void
 */
- (void) setUpdateDataSuccessBlock: (void(^)(NSData *data)) upadateDataSuccessBlock andUpdateDataFailureBlock: (void(^)(NSError *error)) updateDataFailureBlock;

/**
 *  @brief  设置写回调, 主要是发送命令数据
 *  @param  writeDataSuccessBlock 写回调, writeDataFailure 是写失败回调
 *  @return void
 */
- (void) setWriteDataSuccessBlock: (void(^)(NSData *data)) writeDataSuccessBlock andWriteDataFailureBlock: (void(^)(NSError *error)) writeDataFailure;

@end
