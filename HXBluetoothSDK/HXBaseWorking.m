//
//  HXBaseWorking.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseWorking.h"

@implementation HXBaseWorking

+ (instancetype)manager {
    
    HXBaseWorking *baseWorking = [[super alloc] init];
    
    return baseWorking;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static HXBaseWorking *baseWorking = nil;
    dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        baseWorking = [super allocWithZone:zone];
    });
    
    return baseWorking;

}

- (void)get:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, NSError *))failure {
    
}

- (void)post:(NSString *)URLString parameters:(id)parameters success:(void (^)(HXBaseAction *, id))success failure:(void (^)(HXBaseAction *, NSError *))failure {
    
}
                                             

@end
