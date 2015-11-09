//
//  HXWKLDevice.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/9.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXWKLDevice.h"

@implementation HXWKLDevice

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
}

@end
