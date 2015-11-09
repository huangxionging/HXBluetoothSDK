//
//  HXBaseAction.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HXBaseActionDataModel.h"

@interface HXBaseAction : NSObject

/**
 *  操作的名字
 */
@property (nonatomic, copy, readonly) NSString *acionName;

/**
 *  操作的长度
 */
@property (nonatomic, assign, readonly) NSInteger actionLength;

/**
 *  操作的数据
 */
@property (nonatomic, strong, readonly) NSData *actionData;

/**
 *  对应的特征
 */
@property (nonatomic, strong) CBCharacteristic *characteristic;

/**
 *  是否长包操作
 */
@property (nonatomic, assign, readonly) BOOL isLongAction;

/**
 *  表示该操作是否已完成.
 */
@property (nonatomic, assign, readonly) BOOL finished;


- (HXBaseActionDataModel *) modelForAction;

/**
 *  @brief  接收更新数据
 *  @param  updateDataModel 是更新数据模型
 *  @return void
 */
- (void) receiveUpdateData: (HXBaseActionDataModel *)updateDataModel;

/**
 *  @brief  回复数据的回调
 *  @param  answerActionBlock 是操作回复的数据模型回调
 *  @return void
 */
- (void) setAnswerActionDataBlock: (void(^)(HXBaseActionDataModel *answerDataModel)) answerActionBlock;

@end
