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

/**
 *  操作完成的回调
 */
typedef void(^finishedBlock)(BOOL finished, NSDictionary<NSString *, id> *finishedInfo);

typedef void(^answerBlock)(HXBaseActionDataModel *answerModel);

@interface HXBaseAction : NSObject {

@protected
    finishedBlock _finishedBlock;
    answerBlock _answerBlock;
    NSTimer *_finishedActionTimer;
}

/**
 *  操作的名字
 */
@property (nonatomic, copy, readonly) NSString *acionName;

/**
 *  操作的长度
 */
@property (nonatomic, assign, readonly) NSInteger actionLength;

/**
 *  对应的特征的标识符
 */
@property (nonatomic, copy) NSString *characteristicUUIDString;

/**
 *  是否长包操作
 */
@property (nonatomic, assign, readonly) BOOL isLongAction;

/**
 *  表示该操作是否已完成.
 */
@property (nonatomic, assign, readonly) BOOL finished;

/**
 *  操作的数据
 */
- (NSData *)actionData;

/**
 *  对于不需要回复数据的操作, 建议使用此方法创建操作过
 *  @brief  通过类方法创建以及完成操作的回调
 *  @param  finishedBlock 是完成回调
 *  @return 返回为实例化
 */
+ (instancetype) actionWithFinishedBlock:(void(^)(BOOL finished, NSDictionary<NSString *, id> *finisedInfo)) finishedBlock;

/**
 *  对于不需要回复数据的操作, 建议使用此方法创建操作过
 *  @brief  通过类方法创建以及完成操作的回调
 *  @param  finishedBlock 是完成回调
 *  @return 返回为实例化
 */

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