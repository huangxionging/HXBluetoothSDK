//
//  HXBaseWorking.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXBaseAction.h"

@interface HXBaseWorking : NSObject

+ (instancetype) manager;

/**
 *  get
 */
- (void) get:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *action, id responseObject))success failure:(void (^)(HXBaseAction *action, NSError *error))failure;

/**
 *  post 方法
 */
- (void) post:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *action, id responseObject))success failure:(void (^)(HXBaseAction *action, NSError *error))failure;

@end
