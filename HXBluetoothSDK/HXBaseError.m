//
//  HXBaseError.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/12/3.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseError.h"

@implementation HXBaseError

+ (instancetype)errorWithcode:(BaseErrorType)errorType info:(NSString *)info {
    
    if ([info isKindOfClass: [NSString class]]) {
        return [HXBaseError errorWithDomain: @"www.new_life.com" code: errorType userInfo: @{NSLocalizedDescriptionKey : info}];
    } else {
        return [HXBaseError errorWithDomain: @"www.new_life.com" code: errorType userInfo: nil];
    }
    
}

- (void)errorLog {
    NSLog(@"%@", self.localizedDescription);
}

@end
