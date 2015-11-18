//
//  HXWKLSynchronizeParameterAction.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/17.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseAction.h"

/**
 *  穿戴位置
 */
typedef NS_ENUM(NSUInteger, WKLWearLocationType){
    /**
     *  手腕
     */
    kWKLWearLocationTypeWrist = 1,
    
    /**
     *  脖子
     */
    kWKLWearLocationTypeNeck,
    
    /**
     *  腰部
     */
    kWKLWearLocationTypeWaist,
    
    /**
     *  脚步
     */
    kWKLWearLocationTypeFoot,
};
//:1步行(默认),2睡觉,3骑车,4游泳,5网球,6篮球,7足球
typedef NS_ENUM(NSUInteger, WKLSportType) {
    kWKLSportTypeWalk = 1,
    kWKLSportTypeSleep,
    kWKLSportTypeRideBike,
    kWKLSportTypeSwim,
    kWKLSportTypeTennis,
    kWKLSportTypeBasketball,
    kWKLSportTypeFootball,
};

/**
 *  性别
 */
typedef NS_ENUM(NSUInteger, WKLGenderType) {
    kWKLGenderTypeMan = 0,
    kWKLGenderTypeWoman,
    kWKLGenderTypeUnkonw,
};

@interface HXWKLSynchronizeParameterAction : HXBaseAction

/**
 *  同步时间格式: @"2015/11/17 10:05:30" 日期和时间用空格隔开
 */
@property (nonatomic, copy) NSString *time;

/**
 *  运动目标, 步数, 数字为100的倍数
 */
@property (nonatomic, assign) NSInteger steps;

/**
 * 位置
 */
@property (nonatomic, assign) WKLWearLocationType wearType;

/**
 *  运动模式
 */
@property (nonatomic, assign) WKLSportType sportType;

/**
 *  标识
 */
@property (nonatomic, assign) BOOL isFirstSynchronize;

/**
 *  协议版本
 */
@property (nonatomic, assign) NSUInteger protocolEditionNumber;

/**
 *  性别
 */
@property (nonatomic, assign) WKLGenderType genderType;

/**
 *  年龄
 */
@property (nonatomic, assign) NSUInteger age;

/**
 *  体重
 */
@property (nonatomic, assign) NSUInteger weight;

/**
 *  身高
 */
@property (nonatomic, assign) NSUInteger bodyHeight;

/**
 *  功能选项: 采用一个字节的 8 个比特位表示, 从左到右依次降低 bit[7] ~ bit[0]
 *  bit[7]表示是否同步修改本字节表示的参数: 0 表示不修改参数, 1 表示修改
 *  bit[6]度量单位的选择: 0 表示公制, 1表示英制
 *  bit[5]表示蓝牙断开提醒: 0 表示关闭提醒, 1打开提醒
 *  其余位均属于未定义, 预留使用
 */
@property (nonatomic, assign) NSUInteger functionItem;


/**
 *  重写操作数据
 */
- (NSData *)actionData;

/**
 *  重写接收数据
 */
- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel;

@end
