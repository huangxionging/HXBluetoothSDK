//
//  HXBaseDevice.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseDevice.h"

/**
 *  更新数据
 */
typedef void(^updateDataBlock)(HXBaseActionDataModel *data);

/**
 *  写数据
 */
typedef void(^writeDataBlock)(HXBaseActionDataModel *data);

/**
 *  发现服务的特征回调
 */
typedef void(^discoverServiceBlock) (HXBaseServiceModel *serviceModel);

/**
 *  搜索特征定时器超时回调
 */
typedef void(^discoverCharacteristicTimerBlock)(NSError *error);


@interface HXBaseDevice () {
    /**
     * 更新成功的回调
     */
    updateDataBlock _updateDataBlock;
    
    /** 
     * 写成功的回调
     */
    writeDataBlock _writeDataBlock;
    
    /**
     * 发现特征的服务回调
     */
    discoverServiceBlock _discoverServiceBlock;
    
    /**
     *  定时器超时回调
     */
    discoverCharacteristicTimerBlock _timeOutBlock;
    
    /**
     *  外设.
     */
    CBPeripheral *_peripheral;
    
    /**
     *  服务 UUID 构成的字典
     */
    NSMutableDictionary<NSString *, CBUUID *> *_serviceUUIDs;
    
    /**
     *  特征 UUID构成的字典
     */
    NSMutableDictionary<NSString *, CBUUID *> *_characteristicUUIDs;
    
    /**
     * 特征字典
     */
    NSMutableDictionary<NSString *, CBCharacteristic *> *_chracteristics;
    
    /**
     *  操作数据模型
     */
    HXBaseActionDataModel *_actionDataModel;
    
    /**
     *  服务模型
     */
    HXBaseServiceModel *_serviceModel;
    
    // 超时定时器
    NSTimer *_timeOutTimer;
}


@end

@implementation HXBaseDevice

#pragma mark---初始化
- (instancetype)init {
    self = [super init];
    
    if (self) {
        self->_actionDataModel = [[HXBaseActionDataModel alloc] init];
        self->_serviceModel = [[HXBaseServiceModel alloc] init];
        self.isChracteristicReady = NO;
        self->_timeOutTimer = nil;
        self.time = 10.0;
    }
    return self;
}

#pragma mark---添加服务 UUID
- (void)addServiceUUIDWithUUIDString:(NSString *)serviceUUIDString {
    
    if (self->_serviceUUIDs == nil) {
        self->_serviceUUIDs = [[NSMutableDictionary alloc] init];
    }
    
    // 所有的 UUID 均以小写标识
    [self->_serviceUUIDs setObject: [CBUUID UUIDWithString: [serviceUUIDString lowercaseString]] forKey: [serviceUUIDString lowercaseString]];
}

#pragma mark---添加特征
- (void)addCharacteristicUUIDWithUUIDString:(NSString *)characteristicUUIDString {
    if (self->_characteristicUUIDs == nil) {
        self->_characteristicUUIDs = [[NSMutableDictionary alloc] init];
    }
    
    // 设置特征
    [self->_characteristicUUIDs setObject: [CBUUID UUIDWithString: [characteristicUUIDString  lowercaseString]] forKey: [characteristicUUIDString lowercaseString]];
}

#pragma mark---通过外设模型
-(void)startWorkWith:(HXBasePeripheralModel *)peripheralModel{
    // 设置外设
    self->_peripheral = peripheralModel.peripheral;
    // 设置外设代理
    self->_peripheral.delegate = self;
    // 发现服务
    [self->_peripheral discoverServices: self->_serviceUUIDs.allValues];
    
    // 设置定时器
    self->_timeOutTimer = [NSTimer scheduledTimerWithTimeInterval: self.time  target:self selector: @selector(timeOut) userInfo: nil repeats: NO];
}

- (void)discoverCharacteristicTimerTimeOutBlock:(void (^)(NSError *))timerBlock {
    self->_timeOutBlock = timerBlock;
}

#pragma mark---定时器超时
- (void) timeOut {
    
    self->_timeOutTimer = nil;
    if (!self.isChracteristicReady) {
        
        if (self->_timeOutBlock) {
            NSDictionary *dict = @{@"info": @"特征发现超时"};
            NSError *error = [NSError errorWithDomain: @"www.new_life.com" code: 1000 userInfo: dict];
            self->_timeOutBlock(error);
        }
    }
}

#pragma mark--设置超时时间
- (void)setDiscoverCharacteristicTimerOutTime:(NSTimeInterval)time {
    self.time = time;
}

- (void)stopDiscoverCharacteristicTimer {
    [self->_timeOutTimer invalidate];
    self->_timeOutTimer = nil;
}

#pragma mark---获取服务的数组
- (NSArray<CBUUID *> *)serviceUUIDs {
    return self->_serviceUUIDs.allValues;
}

#pragma mark---获取特征的数据
- (NSArray<CBUUID *> *)characteristicUUIDs {
    return self->_characteristicUUIDs.allValues;
}

#pragma mark---添加特征
- (void) addCharacteristic: (CBCharacteristic *) characteristic {
    if (self->_chracteristics == nil) {
        self->_chracteristics = [[NSMutableDictionary alloc] init];
    }
    // 注意采用小写方式
    [self->_chracteristics setObject: characteristic forKey: [characteristic.UUID.UUIDString lowercaseString]];
}


#pragma mark---发送操作
- (void)sendActionWithModel:(HXBaseActionDataModel *)actionDataModel {
    
    
    if (self.isChracteristicReady) {
        // 发送操作
        
        // 查找特征
        CBCharacteristic *characteristic = [self->_chracteristics objectForKey: actionDataModel.characteristicString.lowercaseString];
        if (characteristic && actionDataModel.actionData) {
            // 写数据
            [self->_peripheral writeValue: actionDataModel.actionData forCharacteristic: characteristic type: actionDataModel.writeType];
        }
        else {
            HXDEBUG;
            exit(0);
        }
    }
}

#pragma mark---设置更新回调
- (void)setUpdateDataBlock:(void (^)(HXBaseActionDataModel *))upadateDataBlock {
    self->_updateDataBlock = upadateDataBlock;
}

#pragma mark---设置写数据回调
- (void)setWriteDataBlock:(void (^)(HXBaseActionDataModel *))writeDataBlock {
    self->_writeDataBlock = writeDataBlock;
}

#pragma mark---设置发现指定特征的服务回调
- (void) setDiscoverServiceBlock: (void(^)(HXBaseServiceModel *discoverServiceModel))discoverServiceBlock {
    self->_discoverServiceBlock = discoverServiceBlock;
}

#pragma mark---CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
#ifdef HXLOG_FLAG
    HXDEBUG;
#endif
    if (self->_discoverServiceBlock) {
        self->_serviceModel.service = service;
        self->_serviceModel.error = error;
        self->_discoverServiceBlock(self->_serviceModel);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    HXDEBUG;
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    HXDEBUG;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
        return;
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics: self->_characteristicUUIDs.allValues forService: service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    HXDEBUG;
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    HXDEBUG;
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    HXDEBUG;
    NSLog(@"通知已更新");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
#ifdef HXLOG_FLAG
    HXDEBUG;
#endif
    
    if (self->_updateDataBlock) {
        self->_actionDataModel.actionData = characteristic.value;
        self->_actionDataModel.characteristicString = characteristic.UUID.UUIDString.lowercaseString;
        self->_actionDataModel.error = error;
        self->_actionDataModel.actionDatatype = kBaseActionDataTypeUpdateAnwser;
        self->_updateDataBlock(self->_actionDataModel);
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    HXDEBUG;
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
#ifdef HXLOG_FLAG
    HXDEBUG;
#endif
    
    if (self->_writeDataBlock) {
        self->_actionDataModel.actionData = characteristic.value;
        self->_actionDataModel.characteristicString = characteristic.UUID.UUIDString.lowercaseString;
        self->_actionDataModel.error = error;
        self->_actionDataModel.actionDatatype = kBaseActionDataTypeWriteAnswer;
        self->_writeDataBlock(self->_actionDataModel);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    HXDEBUG;
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    HXDEBUG;
}

@end
