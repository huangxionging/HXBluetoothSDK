//
//  HXWKLController.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/10.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseController.h"


typedef NS_ENUM(NSUInteger, BlockType) {
    kBlockTypeClient = 0,
    kBlockTypeDevice,
    
};

@interface HXWKLController : HXBaseController

// 重写父类方法
- (void) startWork;

// 重写父类方法
- (void) setBlock: (void(^)(BOOL finished, BlockType type)) block;


@end
