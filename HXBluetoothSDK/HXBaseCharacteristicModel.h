//
//  HXBaseCharacteristicModel.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface HXBaseCharacteristicModel : NSObject

/**
 *  特征
 */
@property (nonatomic, strong) CBCharacteristic *chracteristic;


@end
