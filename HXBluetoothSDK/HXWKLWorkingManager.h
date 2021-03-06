//
//  HXWKLWorking.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/20.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseWorkingManager.h"

@interface HXWKLWorkingManager : HXBaseWorkingManager

- (void)get:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, NSError *))failure;

- (void)post:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, NSError *))failure;

@end
