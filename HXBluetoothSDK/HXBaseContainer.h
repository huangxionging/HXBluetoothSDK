//
//  HXBaseContainer.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/12/19.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  容器
 */
@interface HXBaseContainer : NSObject

/**
 *  @brief  共享的单例
 *  @param  void
 *  @return 共享实例
 */
+ (instancetype) shareBaseContainer;

@end
