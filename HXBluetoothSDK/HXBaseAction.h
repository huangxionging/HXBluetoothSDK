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


@interface HXBaseAction : NSObject {

@protected
    void (^_answerBlock)(HXBaseActionDataModel *answerModel);
    void (^_finishedBlock)(id result);
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
 *  @brief  注册类使用的 key 集合数组, 每个子类需要实现
 *  @param  void
 *  @return 数组
 */
- (NSSet *) keySetForAction;

/**
 *  @brief  操作的数据
 *  @param  void
 *  @return 操作的数据
 */
- (NSData *)actionData;

/**
 *  对于不需要回复数据的操作, 建议使用此方法创建操作过
 *  @brief  通过类方法创建以及完成操作的回调
 *  @param  finishedBlock 是完成回调
 *  @return 返回为实例化
 */
/**
 *  @author huangxiong, 2016/04/14 09:49:23
 *
 *  @brief 通过类方法创建以及完成操作的回调
 *
 *  @param parameter     是需要的参数
 *  @param finishedBlock 回调
 *
 *  @return 实例
 *
 *  @since 1.0
 */
+ (instancetype) actionWith: (id) parameter andAnswerActionDataBlock: (void(^)(HXBaseActionDataModel *answerDataModel)) answerActionBlock andFinishedBlock:(void(^)(id result)) finishedBlock;

/**
 *  @author huangxiong, 2016/04/13 19:57:10
 *
 *  @brief 初始化 action 的参数和完成回调, 不同功能的 action 需要重写该方法
 *
 *  @param parameter 是需要的参数
 *  @answerActionBlock 是回复数据的回调
 *  @param finishedBlock ok
 *
 *  @since 1.0
 */
- (instancetype) initWithParameter: (id) parameter answer: (void(^)(HXBaseActionDataModel *answerDataModel)) answerBlock finished: (void(^)(id result))finishedBlock;

/**
 *  @brief  接收更新数据
 *  @param  updateDataModel 是更新数据模型
 *  @return void
 */
- (void) receiveUpdateData: (HXBaseActionDataModel *)updateDataModel;



@end