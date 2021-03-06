//
//  HXWKLChangeColorAction.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/14.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseAction.h"

typedef NS_ENUM(NSUInteger, WKLColorType) {
    
    /**
     *  蓝色
     */
    kWKLColorTypeBlue = 0,
    
    /**
     *  橙色
     */
    kWKLColorTypeOrange = 1,
    
    /**
     *  绿色
     */
    kWKLColorTypeGreen = 2,
    
    /**
     *  红色
     */
    kWKLColorTypeRed = 3,
};

@interface HXWKLChangeColorAction : HXBaseAction

/**
 *  颜色
 */
@property (nonatomic, assign) WKLColorType colorType;

/**
 *  重写操作数据
 */
- (NSData *)actionData;

/**
 *  重写接收数据的方法
 */
- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel;

@end
