//
//  HXWKLBindDeviceAction.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/11.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseAction.h"

typedef NS_ENUM(NSUInteger, WKLBindDeviceState) {
    /**
     *  查询绑定状态
     */
    kWKLBindDeviceStateQuery = 0,
    /**
     *  申请绑定
     */
    kWKLBindDeviceStateApply = 1,
    
    /**
     *  确认绑定
     */
    kWKLBindDeviceStateConfirm = 2,
    
    /**
     * 解除绑定
     */
    kWKLBindDeviceStateCancel = 3
};

@interface HXWKLBindDeviceAction : HXBaseAction


/**
 *  绑定状态
 */
@property (nonatomic, assign) WKLBindDeviceState bindDeviceState;

/**
 *  绑定操作
 */
- (NSData *)actionData;

@end
