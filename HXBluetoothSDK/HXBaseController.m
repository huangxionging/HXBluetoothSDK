//
//  HXBaseController.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseController.h"
#import "HXBaseClient.h"
#import "HXBaseDevice.h"
#import "HXBaseAction.h"

@interface HXBaseController ()

@end

@implementation HXBaseController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark---开始工作
- (void)startWorkWithClient:(HXBaseClient *)baseClient{
    
#ifdef HXLOG_FLAG
    HXDEBUG;
#endif
    
    self->_baseClient = baseClient;
    __weak HXBaseController *weakSelf = self;
    
    // 设置超时时间
    [weakSelf.baseClient setScanTimeOut: 15.0];
    
    // 设置扫描准备回调
    [weakSelf.baseClient setScanReadyBlock:^(CBCentralManagerState ready) {
        
        // 根据状态做不同操作
        switch (ready) {
                // 正常打开, 可以进行搜索操作
            case CBCentralManagerStatePoweredOn: {
                // 开始搜索;
                [weakSelf.baseClient startScanPeripheralWithOptions: nil];
                break;
            }
                
            case CBCentralManagerStatePoweredOff: {
                
                break;
            }
                
            case CBCentralManagerStateUnauthorized: {
                
                break;
            }
                
            case CBCentralManagerStateUnsupported: {
                
                break;
            }
                
            case CBCentralManagerStateResetting: {
                
                break;
            }
                
            case CBCentralManagerStateUnknown: {
                
                break;
            }
            default:
                break;
        }
    }];
    
    // 设置已找到外设回调
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
            [weakSelf.baseClient startScanPeripheralWithOptions: nil];
        }
    }];
    
    // 已连接回调
    [weakSelf.baseClient setConnectionPeripheralBlock:^(HXBasePeripheralModel *peripheral) {
        
        if (peripheral.error == nil) {
            [weakSelf deviceStartWorkWith: peripheral];
        }
        else {
            NSLog(@"断开链接");
            [weakSelf.baseClient connectPeripheralWithOptions: nil];
        }
        
    }];
}

#pragma mark---设备开始工作
- (void) deviceStartWorkWith: (HXBasePeripheralModel *) peripheralModel {
    [self.baseDevice startWorkWith: peripheralModel];
}

#pragma mark---发送操作
- (void)sendAction:(HXBaseAction *)baseAction {
    
    __weak HXBaseController *weakSelf = self;
    
    // 发送数据
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

@end
