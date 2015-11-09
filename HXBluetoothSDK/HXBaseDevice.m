//
//  HXBaseDevice.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseDevice.h"
#import "HXBaseClient.h"

typedef void(^updateDataBlock)(HXBaseActionDataModel *data);
typedef void(^writeDataBlock)(HXBaseActionDataModel *data);

@interface HXBaseDevice () {
    
    // 更新成功的回调
    updateDataBlock _updateDataBlock;
    
    // 写成功的回调
    writeDataBlock _writeDataBlock;
    
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
}


@end

@implementation HXBaseDevice

- (instancetype)init {
    self = [super init];
    
    if (self) {
       
        
    }
    return self;
}

- (void)addServiceWithUUIDString:(NSString *)serviceUUIDString {
    
    if (self->_serviceUUIDs == nil) {
        self->_serviceUUIDs = [[NSMutableDictionary alloc] init];
    }
    
    [self->_serviceUUIDs setObject: [CBUUID UUIDWithString: serviceUUIDString] forKey: serviceUUIDString];
    
//    if (![[self->_serviceUUIDs allKeys] containsObject: serviceUUIDString]) {
//        
//    }
}

- (void)addCharacteristicWithUUIDString:(NSString *)characteristicUUIDString {
    if (self->_characteristicUUIDs == nil) {
        self->_characteristicUUIDs = [[NSMutableDictionary alloc] init];
    }
    
    // 设置特征
    [self->_characteristicUUIDs setObject: [CBUUID UUIDWithString: characteristicUUIDString] forKey: characteristicUUIDString];
}

-(void)startWorkWith:(HXBasePeripheralModel *)peripheralModel{
    self->_peripheral = peripheralModel.peripheral;
    self->_peripheral.delegate = self;
    [self->_peripheral discoverServices: self->_characteristicUUIDs.allValues];
}


- (void)sendActionWithModel:(HXBaseActionDataModel *)actionDataModel {
    
}

- (void)setUpdateDataBlock:(void (^)(HXBaseActionDataModel *))upadateDataBlock {
    self->_updateDataBlock = upadateDataBlock;
}

- (void)setWriteDataBlock:(void (^)(HXBaseActionDataModel *))writeDataBlock {
    self->_writeDataBlock = writeDataBlock;
}

#pragma mark---CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        if (self->_chracteristics == nil) {
            self->_chracteristics = [[NSMutableDictionary alloc] init];
        }
        
        NSLog(@"%@", characteristic);
        
        if (characteristic.properties == CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic: characteristic];
            [peripheral setNotifyValue: YES forCharacteristic: characteristic];
        }
        
        
        // 所有 UUID 构成的服务
        [self->_chracteristics setObject: characteristic forKey: characteristic.UUID.UUIDString];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
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
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
#ifdef HXLOG_FLAG
    HXDEBUG;
#endif
    
    if (self->_updateDataBlock) {
        HXBaseActionDataModel *actionDataModel = [[HXBaseActionDataModel alloc] init];
        actionDataModel.actionData = characteristic.value;
        actionDataModel.characteristicString = characteristic.UUID.UUIDString;
        actionDataModel.error = error;
        actionDataModel.actionDatatype = kBaseActionDataTypeAnwser;
        self->_updateDataBlock(actionDataModel);
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
#ifdef HXLOG_FLAG
    HXDEBUG;
#endif
    
    if (self->_writeDataBlock) {
        HXBaseActionDataModel *actionDataModel = [[HXBaseActionDataModel alloc] init];
        actionDataModel.actionData = characteristic.value;
        actionDataModel.characteristicString = characteristic.UUID.UUIDString;
        actionDataModel.error = error;
        actionDataModel.actionDatatype = kBaseActionDataTypeAnwser;
        self->_writeDataBlock(actionDataModel);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}


- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

@end
