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

@property (nonatomic, weak) HXBaseAction *baseAction;

/**
 *  基础连接, 负责查找外设
 */
@property (nonatomic, strong) HXBaseClient *baseClient;

/**
 *  基础设备, 负责管理数据
 */
@property (nonatomic, strong) HXBaseDevice *baseDevice;

@end

@implementation HXBaseController

+ (instancetype) shareBaseController {
    
    HXBaseController *baseController = [[HXBaseController alloc] init];
    
    if (baseController) {
        
    }
    
    return baseController;
}

#pragma mark---开始工作
- (void)startWorkWithClient:(HXBaseClient *)baseClient{
    
#ifdef HXLOG_FLAG
    HXDEBUG;
#endif
    
    self.baseClient = baseClient;
    
    __weak HXBaseController *weakSelf = self;
    
    // 申请权限保护
    [baseClient lockWithOwner: weakSelf];
    
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
    
    
    
    [weakSelf.baseClient setSearchedPeripheralBlock:^(HXBasePeripheralModel *peripheral) {
        
        if (peripheral != nil) {
            
            //
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
    
    [weakSelf.baseClient setConnectionPeripheralBlock:^(HXBasePeripheralModel *peripheral) {
        [weakSelf.baseDevice startWorkWith: peripheral];
    }];
}

- (void) setBaseDevice:(HXBaseDevice *)baseDevice {
    self->_baseDevice = baseDevice;
}

- (void)sendAction:(HXBaseAction *)baseAction {
    
    __weak HXBaseController *weakSelf = self;
    
    [weakSelf.baseDevice sendActionWithModel: [baseAction modelForAction]];
    
    [weakSelf.baseDevice setUpdateDataBlock:^(HXBaseActionDataModel *actionDataModel) {
        [baseAction receiveUpdateData: actionDataModel];
    }];
    
    [weakSelf.baseDevice setWriteDataBlock:^(HXBaseActionDataModel *actionDataModel) {
        [baseAction receiveUpdateData: actionDataModel];
    }];
}


#pragma mark-

@end
