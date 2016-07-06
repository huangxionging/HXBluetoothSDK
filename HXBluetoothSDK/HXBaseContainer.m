//
//  HXBaseContainer.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/12/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseContainer.h"

@interface HXBaseContainer () {
    
    NSMutableDictionary *_mutableDictionary;
}

@end

@implementation HXBaseContainer

+ (instancetype) shareBaseContainer {
    return [[HXBaseContainer alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static HXBaseContainer *baseContainer = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        baseContainer = [super allocWithZone: zone];
        
        if (baseContainer) {
            baseContainer->_mutableDictionary = [NSMutableDictionary dictionaryWithCapacity: 10];
        }
    });
    
    return baseContainer;
}

- (void) addElement: (id) obj {
    
}

@end
