//
//  HXBaseClient.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/5.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseClient.h"

/**
 *  扫描回调
 */
typedef void(^scanReadyBlock)(CBCentralManagerState ready);

/**
 *  找到最佳外设回调
 */
typedef void(^ searchedPeripheralBlock)(CBPeripheral *peripheral);


@interface HXBaseClient () <CBCentralManagerDelegate>

/**
 *  中心角色管理器
 */
@property (nonatomic, strong) CBCentralManager *centralManager;

/**
 *  外设
 */
@property (nonatomic, strong) CBPeripheral *peripheral;

/**
 *  扫描服务的数组
 */
@property (nonatomic, strong) NSMutableArray<CBUUID *> *serviceUUIDs;

/**
 *  超时定时器
 */
@property (nonatomic, strong) NSTimer *timeOutTimer;

/**
 *  超时时间
 */
@property (nonatomic, assign) NSTimeInterval timeOutInterval;


@end

@implementation HXBaseClient {
    /**
     *  权限保护使用
     */
    id _objc;
    
    /**
     *  可以开始扫描的回调
     */
    scanReadyBlock _scanReadyBlock;
    
    /**
     *  外设信号量强度
     */
    NSInteger _peripheralSingalValue;
    
    /**
     *  已找到外设回调
     */
    searchedPeripheralBlock _searchedPeripheralBlock;
}

#pragma mark---保护性判断, 之后在重写, .........
+ (instancetype)shareBaseClient {
    HXBaseClient *shareBaseClient = [[HXBaseClient alloc] init];
    
    if (shareBaseClient) {
        shareBaseClient.centralManager = [[CBCentralManager alloc] initWithDelegate: shareBaseClient queue: nil];
        shareBaseClient->_peripheralSingalValue = -90;
    }
    return shareBaseClient;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self->_objc != nil) {
        return nil;
    }
    else {
        return self;
    }
}

- (BOOL) applyAuthorityProtectionForInstance:(id)objc {
    
    if (self->_objc == nil) {
        self->_objc = objc;
        return YES;
    }
    else {
        return NO;
    }
}

- (void)freeAuthorityProtectionForInstance:(id)objc {
    
    if ([self->_objc isEqual: objc]) {
        
        // 放弃权限
        self->_objc = nil;
    }
}


#pragma mark---完全单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static HXBaseClient *baseClient = nil;
    
    if (baseClient == nil) {
        // 只执行一次
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            baseClient = [super allocWithZone:zone];
            baseClient->_objc = nil;
            baseClient->_serviceUUIDs = nil;
        });
        return baseClient;
    }
    else {
        return baseClient;
    }
    
}


#pragma mark---添加扫描外设服务的 UUID
- (void)addPeripheralScanService:(CBUUID *)serviceUUID {
    
    // 首先判断 serviceUUID 不为空且真的是 CBUUID 类型
    if (serviceUUID && [serviceUUID isKindOfClass: [CBUUID class]]) {
        if (self.serviceUUIDs == nil) {
            self.serviceUUIDs = [[NSMutableArray alloc] init];
        }
        
        // 添加到数组中
        [self.serviceUUIDs addObject: serviceUUID];
    }
    
}

#pragma mark---通过数组添加
- (void)addPeripheralScanServices:(NSArray<CBUUID *> *)serviceUUIDs {
    // 判断数组是否为空且真的是数组的实例
    if (serviceUUIDs && [serviceUUIDs isKindOfClass: [NSArray class]]) {
        [self.serviceUUIDs addObjectsFromArray: serviceUUIDs];
    }
}

#pragma mark---设置可以扫描的回调
- (void)setScanReadyBlock:(void (^)(CBCentralManagerState))scanReadyBlock {
    self->_scanReadyBlock = scanReadyBlock;
}

#pragma mark---找到外设
- (void)setSearchedPeripheralBlock:(void (^)(CBPeripheral *))searchedPeripheralBlock {
    self->_searchedPeripheralBlock = searchedPeripheralBlock;
}


#pragma mark---设置扫描超时
- (void)setScanTimeOut:(NSTimeInterval)interval {
    self.timeOutInterval = interval;
}


#pragma mark---开始扫描服务
- (void)startScanPeripheralWithOptions:(NSDictionary<NSString *,id> *)options {
    
#ifdef HXLOG_FLAG
    HXDEBUG;
    NSLog(@"开始搜索");
#endif
    // 开始搜索
    [self.centralManager scanForPeripheralsWithServices: self.serviceUUIDs options: options];
    
    // 重置定时器
    [self.timeOutTimer invalidate];
    // 重新定时
    self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval: self.timeOutInterval target: self selector: @selector(scanTimeOut) userInfo: nil repeats: NO];
}

#pragma mark---超时处理方法
- (void)scanTimeOut {
    
#ifdef HXLOG_FLAG
    HXDEBUG;
    NSLog(@"回传外设");
#endif
    
    // 回传
    if (self->_searchedPeripheralBlock) {
        self->_searchedPeripheralBlock(self.peripheral);
    }
}

#pragma mark---停止扫描
- (void) stopScan {
    [self.centralManager stopScan];
}

#pragma mark----连接外设
- (void)connectPeripheralWithOptions:(NSDictionary<NSString *,id> *)options {
    [self.centralManager connectPeripheral: self.peripheral options: options];
}

#pragma mark--- CBCentralManagerDelegate
/**
 *  中心设备已更新状态
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
#ifdef HXLOG_FLAG
    HXDEBUG;
    NSLog(@"中心设备已更新状态");
#endif
    if (self->_scanReadyBlock) {
        self->_scanReadyBlock(central.state);
    }
}

/**
 *  发现外设
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    // 过滤条件
    if (RSSI.integerValue < -90 || RSSI.integerValue > 90) {
        return;
    }
    
#ifdef HXLOG_FLAG
    HXDEBUG;
    //    peripheral.identifier.UUIDString
    NSLog(@"发现外设: %@ ====> 广播数据: %@ ====> 信号强度: %@", peripheral, advertisementData, RSSI);
#endif
    
    // 取信号量最大的外设, 等待设备超时, 将外设回传给设备
    if (RSSI.integerValue > self->_peripheralSingalValue) {
        self->_peripheralSingalValue = RSSI.integerValue;
        self.peripheral = peripheral;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    
}


@end
