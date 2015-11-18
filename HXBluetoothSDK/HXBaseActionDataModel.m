//
//  HXBaseActionDataModel.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/9.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseActionDataModel.h"
#import "HXBaseAction.h"

@implementation HXBaseActionDataModel

+ (instancetype) modelWithAction: (HXBaseAction *)action {
    HXBaseActionDataModel *actionDataModel = [[HXBaseActionDataModel alloc] init];
    
    if (actionDataModel) {
        actionDataModel.actionData = [action actionData];
        actionDataModel.characteristicString = [action.characteristicUUIDString lowercaseString];
        actionDataModel.actionDatatype = kBaseActionDataTypeUpdateSend;
        actionDataModel.writeType = CBCharacteristicWriteWithResponse;
    }
    
    return actionDataModel;
}


@end
