//
//  HXBaseDevice.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseDevice.h"
#import "HXBaseClient.h"

typedef void(^updateDataFailureBlock)(NSError *error);

typedef void(^updateDataSucessBlock)(NSData *data);

typedef void(^writeDataFailureBlock)(NSError *error);

typedef void(^writeDataSuccessBlock)(NSData *data);

@interface HXBaseDevice ()<CBPeripheralDelegate> {
    
    // 更新成功的回调
    updateDataSucessBlock _updateSuccess;
    
    // 更新失败的回调
    updateDataFailureBlock _updateFailure;
    
    // 写成功的回调
    writeDataSuccessBlock _writeSuccess;
    
    // 写失败的回调
    writeDataFailureBlock _writeFailure;
}

@end

@implementation HXBaseDevice

- (instancetype)init {
    self = [super init];
    
    if (self) {
       
        
    }
    return self;
}

- (instancetype)initWithPeriheral:(CBPeripheral *)peripheral {
    self = [super init];
    
    if (self) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
    }
    
    return self;
}

- (void)setUpdateDataSuccessBlock:(void (^)(NSData *))upadateDataSuccessBlock andUpdateDataFailureBlock:(void (^)(NSError *))updateDataFailureBlock {
    _updateSuccess = 
}

#pragma mark---CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        
        if (self->_updateFailure) {
            self->_updateFailure(error);
        }
        else {
#ifdef HXLOG_FLAG
            HXDEBUG;
            exit(0);
#endif
        }
        return;
    }
    
    if (self->_updateSuccess) {
        self->_updateSuccess(characteristic.value);
    }
    else {
#ifdef HXLOG_FLAG
        HXDEBUG;
        exit(0);
#endif
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if (error) {
        
        if (self->_writeFailure) {
            self->_writeFailure(error);
        }
        else {
#ifdef HXLOG_FLAG
            HXDEBUG;
            exit(0);
#endif
        }
        return;
    }
    
    if (self->_writeSuccess) {
        self->_writeSuccess(characteristic.value);
    }
    else {
#ifdef HXLOG_FLAG
        HXDEBUG;
        exit(0);
#endif
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}


- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

@end
