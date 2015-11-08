//
//  HXBaseClient.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/5.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/**
 *  负责蓝牙的基础连接, 外设扫描, 数据传输, 无需考虑可靠性问题.
 */
@interface HXBaseClient : NSObject

+ (instancetype) shareBaseClient;

/**
 *  @brief  申请权限保护, 若申请成功, 则 objc 实例与该类本身的单例绑定, 其他实例无法使用该单例, 除非 objc 解除权限保护
 *  @param  objc 是需要申请权限保护的对象
 *  @return 返回权限保护成功或者失败
 */
- (BOOL) applyAuthorityProtectionForInstance: (id) objc;

- (void) unlockWithOnwner

/**
 *  @brief  添加待扫描外设的服务的 UUID
 *  @param  serviceUUID 是待扫描外设的服务的 UUID
 *  @return void
 */
- (void) addPeripheralScanService: (CBUUID *) serviceUUID;

/**
 *  @brief  添加待扫描外设的服务的 UUID, 数组
 *  @param  serviceUUIDs 是待扫描外设的服务的 UUID 组成的数组
 *  @return void
 */
- (void) addPeripheralScanServices:(NSArray<CBUUID *> *) serviceUUIDs;

/**
 *  @brief  开始扫描
 *  @param  options 是扫描的选项数组
 *  @return void
 *
 *  @seealso            CBCentralManagerScanOptionAllowDuplicatesKey
 *	@seealso			CBCentralManagerScanOptionSolicitedServiceUUIDsKey
 */
- (void) startScanPeripheralWithOptions: (NSDictionary<NSString *, id> *) options;

/**
 *  @brief  设置 扫描超时时间, 默认为 10 秒
 *  @param  interval 是超时时间, 单位为秒数
 *  @return void
 */
- (void) setScanTimeOut: (NSTimeInterval) interval;

/**
 *  @brief  可以开始扫描的回调
 *  @param  scanReadyBlock 是可以开始扫描的回调, 回调会通知上层是否已经可以扫描
 *  @return void
 */
- (void) setScanReadyBlock: (void(^)(CBCentralManagerState ready)) scanReadyBlock;

/**
 *  @brief  已找到外设的回调
 *  @param  searchedPeripheralBlock 是查找最佳匹配的外设的操作, 回调会通知上层找到最佳外设
 *  @return void
 */
- (void) setSearchedPeripheralBlock: (void(^)(CBPeripheral *peripheral)) searchedPeripheralBlock;


/**
 *  @brief  停止扫描
 *  @param  void
 *  @return void
 */
- (void) stopScan;

/**
 *  @brief  停止扫描
 *  @param  options 是连接选项
 *  @return void
 */
- (void) connectPeripheralWithOptions: (NSDictionary<NSString *,id> *) options;

@end
