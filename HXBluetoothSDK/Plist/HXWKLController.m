//
//  HXWKLController.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXWKLController.h"
#import "HXWKLSearchDeviceAction.h"
#import "HXWKLBindDeviceAction.h"
#import "HXBaseWorkingManager.h"

#import <objc/message.h>

@interface HXWKLController ()

/**
 *  扫描服务 UUIDs
 */
@property (nonatomic, strong) NSArray<NSString *> *scanServiceUUIDs;


/**
 *  发现特征的服务 UUIDs
 */
@property (nonatomic, strong) NSArray<NSString *> *discoverSeriveUUIDs;

/**
 *  读特征
 */
@property (nonatomic, strong) NSArray<NSString *> *readChracteristicUUIDs;

/**
 *  写特征
 */
@property (nonatomic, strong) NSArray<NSString *> *writeChracteristicUUIDs;

/**
 *  是否具备读特征
 */
@property (nonatomic, assign) BOOL isReadCharacterstic;

/**
 *  是否具备写特征
 */
@property (nonatomic, assign) BOOL isWriteCharacteristic;

/**
 *  写特征的 UUID 标识符
 */
@property (nonatomic, strong) NSString *writeCharacteristicUUIDString;

@property (nonatomic, weak) NSDictionary *serviceDictionary;

@property (nonatomic, strong) void(^block)(BOOL finished, BlockType type);



@end


@implementation HXWKLController

- (void)setBlock:(void (^)(BOOL, BlockType))block {
    _block = block;
}

#pragma mark---初始化方法
- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Bluetooth" ofType: @"plist"];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile: path];
        
        _serviceDictionary = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"" ofType: @"plist"]];
        
        self->_scanServiceUUIDs = dictionary[@"BraceletScanServices"];
        self->_discoverSeriveUUIDs = dictionary[@"BraceletDiscoveredServices"];
        self->_readChracteristicUUIDs = dictionary[@"BraceletReadCBCharacteristics"];
        self->_writeChracteristicUUIDs = dictionary[@"BraceletWriteCBCharacteristics"];
        self->_isReadCharacterstic = NO;
        self->_isWriteCharacteristic = NO;
    }
    
    return self;
}

#pragma mark---观察者监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // 监听 Device 的特征, 如果读特征都准备好了, 立即绑定
    if ([keyPath isEqualToString: @"isChracteristicReady"]) {
        
        if (self.baseDevice.isChracteristicReady == YES) {
            
            // 取消定时器
//            [self.baseDevice stopDiscoverCharacteristicTimer];
            [self setUpdateDataBlock];
            [self setWriteDataBlock];
            if (_block) {
                _block(YES, kBlockTypeClient);
            }
            NSLog(@"已链接");
        }
    }
}

#pragma mark---发送操作
- (void)sendAction:(HXBaseAction *)baseAction {
    
    if (self.baseDevice.isChracteristicReady) {
        
        // 写操作的标示符
        baseAction.characteristicUUIDString = _writeCharacteristicUUIDString.lowercaseString;
        
        __weak HXBaseController *weakSelf = self;
        
        [weakSelf.baseDevice sendActionWithModel: [HXBaseActionDataModel modelWithAction: baseAction]];
        
        // 更新数据回调
        [weakSelf.baseDevice setUpdateDataBlock:^(HXBaseActionDataModel *actionDataModel) {
            
            [baseAction receiveUpdateData: actionDataModel];
        }];
        
        // 写数据回调
        [weakSelf.baseDevice setWriteDataBlock:^(HXBaseActionDataModel *actionDataModel) {
            [baseAction receiveUpdateData: actionDataModel];
        }];
        
    }
    else {
        return;
    }
}

- (void) setUpdateDataBlock {
    // 更新数据回调
    [self.baseDevice setUpdateDataBlock:^(HXBaseActionDataModel *actionDataModel) {
        
//        [baseAction receiveUpdateData: actionDataModel];
    }];
}

- (void) setWriteDataBlock {
    // 写数据回调
    [self.baseDevice setWriteDataBlock:^(HXBaseActionDataModel *actionDataModel) {
//        [baseAction receiveUpdateData: actionDataModel];
    }];
}




#pragma mark---控制器开始工作
- (void)startWork {
    
    __weak HXWKLController *weakSelf = self;
    
    HXDEBUG;
    weakSelf.baseClient = [HXBaseClient shareBaseClient];
    
    for (NSString *UUIDString in self->_scanServiceUUIDs) {
        [weakSelf.baseClient addPeripheralScanService: [CBUUID UUIDWithString: UUIDString.lowercaseString]];
    }
    
    // 设置扫描超时时间
    [weakSelf.baseClient setScanTimeOut: 15.0];
    
    // 已经准备开始扫描回调
    [weakSelf.baseClient setScanReadyBlock:^(CBCentralManagerState ready) {
        switch (ready) {
            case CBCentralManagerStatePoweredOn: {
                
                // 开始扫描
                [weakSelf.baseClient startScanPeripheralWithOptions: nil];
                break;
            }
                
            default:
                break;
        }
    }];
    
    
    // 已找到
    [weakSelf.baseClient setSearchedPeripheralBlock:^(HXBasePeripheralModel *peripheral) {
        
        if (peripheral != nil) {
            [weakSelf.baseClient stopScan];
            [weakSelf.baseClient connectPeripheralWithOptions: nil];
#ifdef HXLOG_FLAG
            HXDEBUG;
            NSLog(@"发现外设: %@ ====>", peripheral);
#endif
        }
        else {
            
            [weakSelf cleanup];
            [weakSelf.baseClient startScanPeripheralWithOptions: nil];
        }
    }];
    
    [weakSelf.baseClient setConnectionPeripheralBlock:^(HXBasePeripheralModel *peripheral) {
        if (peripheral.error == nil) {
            [weakSelf deviceStartWorkWith: peripheral];
        }
        else {
            NSLog(@"断开链接");
            _isWriteCharacteristic = NO;
            _isReadCharacterstic = NO;
            self.baseDevice.isChracteristicReady = NO;
            [weakSelf.baseClient cancelPeripheralConnection];
        }
    }];
}

#pragma mark---清理
- (void) cleanup {
    
    _isWriteCharacteristic = NO;
    _isReadCharacterstic = NO;
    self.baseDevice.isChracteristicReady = NO;
    self.baseDevice = nil;
    [self.baseClient connectPeripheralWithOptions: nil];
}

#pragma mark---设备开始工作
- (void)deviceStartWorkWith:(HXBasePeripheralModel *)peripheralModel {
    
    if (self.baseDevice == nil) {
        self.baseDevice = [[HXBaseDevice alloc] init];
        [self.baseDevice addObserver: self forKeyPath: @"isChracteristicReady" options:NSKeyValueObservingOptionNew context: nil];
    }
    
    // 添加发现服务
    for (NSString *UUIDString in self->_discoverSeriveUUIDs) {
        [self.baseDevice addServiceUUIDWithUUIDString: [UUIDString lowercaseString]];
    }
    
    // 添加读特征
    for (NSString *UUIDString in self->_readChracteristicUUIDs) {
        [self.baseDevice addCharacteristicUUIDWithUUIDString: [UUIDString lowercaseString]];
    }
    
    // 添加写特征
    for (NSString *UUIDString in self->_writeChracteristicUUIDs) {
        [self.baseDevice addCharacteristicUUIDWithUUIDString: [UUIDString lowercaseString]];
    }
    // 开始工作
    [self.baseDevice startWorkWith: peripheralModel];
    
    // 超时定时器回调
    [self.baseDevice discoverCharacteristicTimerTimeOutBlock:^(NSError *error) {
        NSLog(@"%@", error);
        HXDEBUG;
        
        // 说明外设查找失败, 这里为了方便才继续
        [self.baseClient startScanPeripheralWithOptions: nil];
    }];
    
    
    __weak NSArray *readArray = self->_readChracteristicUUIDs;
    
    __weak NSArray *writeArray = self->_writeChracteristicUUIDs;
    
    __weak HXBaseDevice *device = self.baseDevice;
    
    // 发现特征服务回调
    [self.baseDevice setDiscoverServiceBlock:^(HXBaseServiceModel *discoverServiceModel) {
        
        for (CBCharacteristic *characteristic in discoverServiceModel.service.characteristics) {
            
            NSLog(@"%@", characteristic);
            
            
            // 读特征
            if ([readArray containsObject: [characteristic.UUID.UUIDString lowercaseString]]) {
                
                [peripheralModel.peripheral setNotifyValue: YES forCharacteristic: characteristic];
                [peripheralModel.peripheral readValueForCharacteristic: characteristic];
                
                [device addCharacteristic: characteristic];
                _isReadCharacterstic = YES;
                
                if (_isWriteCharacteristic == YES && _isReadCharacterstic == YES) {
                    device.isChracteristicReady = YES;
                }
            }
            
            // 写特征
            if ([writeArray containsObject: [characteristic.UUID.UUIDString lowercaseString]]) {
                
                _isWriteCharacteristic = YES;
                _writeCharacteristicUUIDString = [characteristic.UUID.UUIDString lowercaseString];
                [device addCharacteristic: characteristic];
                if (_isWriteCharacteristic == YES && _isReadCharacterstic == YES) {
                    device.isChracteristicReady = YES;
                }
                
            }
            
        }
        
    }];
}


@end
