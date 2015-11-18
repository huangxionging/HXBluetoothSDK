//
//  HXWKLStepAction.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/14.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXWKLStepAction.h"

@interface HXWKLStepAction ()

/**
 *  接收数据包计数
 */
@property (nonatomic, assign) NSInteger recieveDataCount;

/**
 *  计步数据的总天数, 同时标识长包的个数
 */
@property (nonatomic, assign) NSInteger dayCount;

/**
 * 是否
 */
//@property (nonatomic, assign) NSInteger
@end

@implementation HXWKLStepAction

- (instancetype)init {
    
    if (self = [super init]) {
        self.saveInterval = 30.0;
    }
    return self;
}

- (NSData *)actionData {
    
    Byte bytes[20] = {0};
    bytes[0] = 0x5a;
    bytes[1] = 0x02;
    
    // 间隔时间
    bytes[3] = self.saveInterval;
    
    if (self.stepActionType == kWKLStepActionTypeSynchronizeStepData) {
        
        NSArray *startDateArray = [self.startDate componentsSeparatedByString: @"/"];
        NSArray *endDataArray = [self.endDate componentsSeparatedByString: @"/"];
        
        if (startDateArray.count != 3 || endDataArray.count != 3) {
            HXDEBUG;
            NSLog(@"日期不正确");
            exit(0);
        }
        bytes[1] = 0x03;
        
        // 算法问题, 年份 - 2000, 表示两千年以后的年份
        // 开始日期
        bytes[3] = [startDateArray[0] integerValue] - 2000;
        bytes[4] = [startDateArray[1] integerValue];
        bytes[5] = [startDateArray[2] integerValue];
        // 结束日期
        bytes[6] = [endDataArray[0] integerValue] - 2000;
        bytes[7] = [endDataArray[1] integerValue];
        bytes[8] = [endDataArray[2] integerValue];
       
    }
    
    NSData *actionData = [NSData dataWithBytes: bytes length: self.actionLength];
    
    NSLog(@"%@", actionData);
    return actionData;
}

- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 同步命令回复
        if (bytes[0] == 0x5b && bytes[1] == 0x03) {
            
            // 总长包的个数
            self.dayCount = bytes[3] * 256 + bytes[4];
            
            if (bytes[5] == 0x00) {
                NSLog(@"所有数据无效");
            }
            
        }
    }
}
@end
