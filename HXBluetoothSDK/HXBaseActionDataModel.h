//
//  HXBaseActionDataModel.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/9.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  操作数据的数据类型
 */
typedef NS_ENUM(NSUInteger, BaseActionDataType){
    /**
     *  发送的数据
     */
    kBaseActionDataTypeSend = 0,
    
    /**
     *  回复的数据
     */
    kBaseActionDataTypeAnwser,
};

/**
 * 操作数据是否需要回复, 与 (CBCharacteristicWriteType) 对应
 */
typedef NS_ENUM(NSUInteger, BaseActionWriteType){
    /**
     *  发送的数据
     */
    kBaseActionWriteTypeWriteTypeWithResponse = 0,
    
    /**
     *  回复的数据
     */
    kBaseActionWriteTypeWriteTypeWithoutResponse,
};


@interface HXBaseActionDataModel : NSObject

/**
 *  操作数据
 */
@property (nonatomic, strong) NSData *actionData;

/**
 *  操作使用的特征所用的 UUID 的标识符
 */
@property (nonatomic, copy) NSString *characteristicString;

/**
 *  操作数据类型, 类型为发送的数据, 还是回复的数据
 */
@property (nonatomic, assign) BaseActionDataType actionDatatype;

/**
 *  错误结果
 */
@property (nonatomic, strong) NSError *error;

/**
 *  是否需要回复
 */
@property (nonatomic, assign) BaseActionWriteType writeType;

@end
