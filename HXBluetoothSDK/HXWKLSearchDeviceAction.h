//
//  HXWKLSearchDeviceAction.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseAction.h"

@interface HXWKLSearchDeviceAction : HXBaseAction

/**
 *  重写
 */
- (NSData *)actionData;

/**
 *  重写
 */
- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel;

@end
