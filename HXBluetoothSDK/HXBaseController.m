//
//  HXBaseController.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseController.h"

@interface HXBaseController ()

@end

@implementation HXBaseController

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)startWork {
    [self startWorkWithClient: [HXBaseClient shareBaseClient]];
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
    [self deviceDeliverData];
}

#pragma mark- 
- (void) deviceDeliverData {
    
    __weak HXBaseController *weakSelf = self;
    // 更新数据回调
    [weakSelf.baseDevice setUpdateDataBlock:^(HXBaseActionDataModel *actionDataModel) {
        
        // 查询 action
        HXBaseAction *action = [weakSelf.actionSheet objectForKey: actionDataModel.keyword];
        
        // 投送消息
        [action receiveUpdateData: actionDataModel];
    }];
    
    // 写数据回调
    [weakSelf.baseDevice setWriteDataBlock:^(HXBaseActionDataModel *actionDataModel) {
        // 查询 action
        HXBaseAction *action = [weakSelf.actionSheet objectForKey: actionDataModel.keyword];
        
        // 投送消息
        [action receiveUpdateData: actionDataModel];
    }];
}

- (void)sendAction:(NSString *)actionName parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, HXBaseError *))failure {
    __weak HXBaseController *weakSelf = self;
    
    HXBaseAction *action = [[NSClassFromString(actionName) alloc] initWithParameter: parameters answer:^(HXBaseActionDataModel *answerDataModel) {
        // 发送回复数据
        [weakSelf.baseDevice sendActionWithModel: answerDataModel];
    } finished:^(id result) {
        BOOL state = [weakSelf removeAction: action];
        if (state == YES) {
            // 成功回调
            success(action, result);
        } else {
            HXBaseError *error = [HXBaseError errorWithcode:kBaseErrorTypeUnknown info: @"未知错误"];
            failure(action, error);
        }
    }];
    
    // 获取注册状态
    BOOL state = [weakSelf registerAction: action];
    if (state == YES) {
        // 发送数据
        [weakSelf.baseDevice sendActionWithModel: [HXBaseActionDataModel modelWithAction: action]];
    } else {
        HXBaseError *error = [HXBaseError errorWithcode:kBaseErrorTypeChannelUsed info: @"通道已被占用"];
        failure(action, error);
    }
}

#pragma mark- action 列表
- (NSMutableDictionary<NSString *,HXBaseAction *> *)actionSheet {
    
    // 初始化 操作表
    if (_actionSheet == nil) {
        _actionSheet = [NSMutableDictionary dictionaryWithCapacity: 10];
    }
    return  _actionSheet;
}

#pragma mark- action 关键字集合
- (NSMutableSet<NSString *> *)actionKeywordSet {
    if (_actionKeywordSet == nil) {
        _actionKeywordSet = [NSMutableSet setWithCapacity: 10];
    }
    return _actionKeywordSet;
}

#pragma mark- 注册 action
- (BOOL) registerAction: (HXBaseAction *) action {
    
    // 得到 action 的 key
    NSSet *keySet = action.keySetForAction;
    
    // 如果存在交集, 表明通道被占用, 返回 NO
    if ([self.actionKeywordSet intersectsSet: keySet]) {
        return NO;
    } else {
        // 通道存在, 则占用
        // 取并集
        [self.actionKeywordSet unionSet: keySet];
        [keySet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.actionSheet setObject: action forKey: obj];
        }];
        return YES;
    }
}

#pragma mark- 注册 action
- (BOOL) removeAction: (HXBaseAction *) action  {
    // 释放通道
    NSSet *keySet = action.keySetForAction;
    if ([self.actionKeywordSet intersectsSet: keySet]) {
        // 求差集
        [self.actionKeywordSet minusSet: keySet];
        
        // 释放通道
        [keySet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self.actionSheet removeObjectForKey: obj];
        }];
        return YES;
    } else {
        return NO;
    }
    
    
}



@end
