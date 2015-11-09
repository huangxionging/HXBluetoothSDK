//
//  HXBaseAction.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseAction.h"

@interface HXBaseAction ()

@end

@implementation HXBaseAction

- (NSData *)actionData {
    return [[NSData alloc] init];
}

#pragma mark---操作的模型
- (HXBaseActionDataModel *) modelForAction {
    HXBaseActionDataModel *actionDataModel = [[HXBaseActionDataModel alloc] init];
    
    // 操作数据模型
    if (actionDataModel) {
        actionDataModel.actionData = self.actionData;
        actionDataModel.characteristicString = self.characteristic.UUID.UUIDString;
        actionDataModel.actionDatatype = kBaseActionDataTypeSend;
        actionDataModel.writeType = kBaseActionWriteTypeWriteTypeWithResponse;
    }
    
    return actionDataModel;
}

- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel {
    
}

- (void)setAnswerActionDataBlock:(void (^)(HXBaseActionDataModel *))answerActionBlock {
    
}

@end
