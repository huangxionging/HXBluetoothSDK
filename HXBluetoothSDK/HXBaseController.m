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

@implementation HXBaseController

+ (instancetype) shareBaseController {
    
    HXBaseController *baseController = [[HXBaseController alloc] init];
    
    if (baseController) {
        
    }
    
    return baseController;
}

#pragma mark---开始工作
- (void)startWorkWithClient:(HXBaseClient *)baseClient {
    
    if (baseClient == nil) {
#ifdef HXLOG_FLAG
        HXDEBUG;
        NSLog(@"baseClient 不能为空");
        exit(0);
#endif
    }
    
    self.baseClient = baseClient;
    
    __weak HXBaseController *weakSelf = self;
    
    // 申请权限保护
    //        [client applyAuthorityProtectionForInstance: self];
    
    // 设置超时时间
    [weakSelf.baseClient setScanTimeOut: 15.0];
    
    // 设置扫描准备回调
    [weakSelf.baseClient setScanReadyBlock:^(NSInteger ready) {
        
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
    
    
    
    [weakSelf.baseClient setSearchedPeripheralBlock:^(CBPeripheral *peripheral) {
        
        
        if (peripheral != nil) {
            
            //
            [weakSelf.baseClient stopScan];
            weakSelf.baseDevice = [[HXBaseDevice alloc] initWithPeriheral: peripheral];
#ifdef HXLOG_FLAG
            HXDEBUG;
            NSLog(@"发现外设: %@ ====>", peripheral);
#endif
        }
        else {
            [weakSelf.baseClient startScanPeripheralWithOptions: nil];
        }
    }];
}

#pragma mark-

@end
