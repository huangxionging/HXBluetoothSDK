//
//  HXBaseAction.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 *  表示该操作是否已完成.
 */
@property (nonatomic, assign, readonly) BOOL finished;


@end
