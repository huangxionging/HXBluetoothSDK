//
//  HXWKLPayAction.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/23.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseAction.h"

/**
 *  支付类型
 */
typedef NS_ENUM(NSUInteger, WKLPayActionType) {
    /**
     *  查询余额
     */
    kWKLPayActionTypeQueryBalance = 0,
    
    /**
     *  查询交易记录
     */
    kWKLPayActionTypeQueryDealRecord,
    
    /**
     *  复位, 打开 NFC
     */
    kWKLPayActionTypeResetting,
    
    /**
     *  关闭 NFC
     */
    kWKLPayActionTypeClose,
    
    /**
     *  查询 app 序列号
     */
    kWKLPayActionTypeQueryAppSerial,
    
    /**
     *  查询城市编码;
     */
    kWKLPayActionTypeQueryCityCode
};



@interface HXWKLPayAction : HXBaseAction

/**
 *  支付操作类型
 */
@property (nonatomic, assign) WKLPayActionType payActionType;

/**
 *  查询交易记录的序号
 */
@property (nonatomic, assign) NSInteger queryDealRecordNumber;


/**
 *  重写 actionData
 */
- (NSData *)actionData;


/**
 *  重写 receiveUpdateData
 */
- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel;


@end
