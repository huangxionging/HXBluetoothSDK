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
 *  计步数据的总天数, 同时表示长包的个数
 */
@property (nonatomic, assign) NSInteger dayCount;

/**
 *  长包计数, 也即长包序号
 */
@property (nonatomic, assign) NSInteger longPackageNumber;

/**
 *  一个长包有效数据个数
 */
@property (nonatomic, assign) NSInteger effectiveDataCount;

/**
 *  短包个数
 */
@property (nonatomic, assign) NSInteger shortPackageCount;

/**
 * 短包序号计数
 */
@property (nonatomic, assign) NSInteger shortPackageNumber;

/**
 *  位域控制表
 */
@property (nonatomic, assign) Byte *bitControlTable;

/**
 *  长包数据
 */
@property (nonatomic, strong) NSMutableData *longPackageData;

/**
 *  指示日期
 */
@property (nonatomic, copy) NSString *indicatorDate;

/**
 *  一天的总步数
 */
@property (nonatomic, copy) NSString *oneDayTotalSteps;

/**
 *  每天的数据步数信息
 */
@property (nonatomic, strong) NSMutableDictionary *stepInfo;



@end

@implementation HXWKLStepAction

- (instancetype)init {
    
    if (self = [super init]) {
        self.saveInterval = 30.0;
        _bitControlTable = (Byte *)malloc(sizeof(Byte) * 15);
        memset(_bitControlTable, 0xff, sizeof(Byte) * 15);
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
        bytes[1] = 0x03;
        if ([self.endDate isEqualToString: @"0"]) {
            
            
            // 算法问题, 年份 - 2000, 表示两千年以后的年份
            // 开始日期
            bytes[3] = 0;
            bytes[4] = 0;
            bytes[5] = 0;
            // 结束日期
            bytes[6] = 0;
            bytes[7] = 0;
            bytes[8] = 0;
        }
        else {
            NSArray *startDateArray = [self.startDate componentsSeparatedByString: @"/"];
            NSArray *endDataArray = [self.endDate componentsSeparatedByString: @"/"];
            
            if (startDateArray.count != 3 || endDataArray.count != 3) {
                HXDEBUG;
                NSLog(@"日期不正确");
                exit(0);
            }
            
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
            
            // 处理回复的第一个数据
            [self handleFirstAnswer: (Byte *) bytes];
            
            return;
        }
        
        // 设备开始主动发数据
        if (bytes[0] == 0x5a && bytes[1] == 0x05) {
            
            if (bytes[2] == 0x01) {
                
                // 处理短包 操作信息
                [self handleShortPackageActionAnswer: bytes];
            } else if (bytes[2] >= 0x02 && bytes[2] < 0xfe) {
                
                // 处理短包有效信息
                [self handleShortPackageEffectiveAnswer: bytes];
                
            } else if (bytes[2] == 0xfe) {
                
                [self handleShortPackageLastAnswer: bytes];
                
            } else if (bytes[2] == 0xff) {
                
            }
        }
       
    }
}

- (void) handleFirstAnswer: (Byte *) bytes {
    
    // 总长包的个数
    self.dayCount = bytes[3] * 256 + bytes[4];
    
    NSLog(@"总天数%@", @(self.dayCount));
    
    if (bytes[5] == 0x00) {
       
    } else if (bytes[5] == 0x01) {
        NSLog(@"数据有效");
        // 总步数
        NSInteger steps = bytes[6] * 256 + bytes[7];
        
        NSLog(@"最后一天总步数%@", @(steps));
    }
    
    if (_stepInfo == nil) {
        _stepInfo = [NSMutableDictionary dictionaryWithCapacity: _dayCount];
    }
    
    // 清空所有数据
    [_stepInfo removeAllObjects];
}

// 处理每个长包的第一个短包数据
- (void) handleShortPackageActionAnswer: (Byte *) bytes {
    
    // 有效数据个数
    self.effectiveDataCount = bytes[3] * 256 + bytes[4];
    
    // 记录长包数据
    if (_longPackageData == nil) {
        _longPackageData = [NSMutableData data];
    }
        
    // 清空
    _longPackageData.length = 0;
    
    _shortPackageNumber = bytes[2];
    
    // 短包个数,
    _shortPackageCount = self.effectiveDataCount / 17 + ((self.effectiveDataCount % 17)?1:0);
    
    // 记录长包序号
    self.longPackageNumber = bytes[5] * 256 + bytes[6];
    
    // 第一个分包位域控制, 以下三种算法都 ok, 采用取反的方法 ! 不行
    //_bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff - (1<< ((_shortPackageNumber - 1) % 8));
    
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<(_shortPackageNumber - 1) % 8);
    
    // 0xff - pow(2, (_shortPackageNumber - 1) / 8))
    
    // 位域控制
    for (NSInteger index = _shortPackageCount + 1; index < 15; ++index) {
        _bitControlTable[index] = 0x00;
    }
    
    // 年月日
    NSInteger year = bytes[10] + 2000;
    NSInteger month = bytes[11];
    NSInteger day = bytes[12];
    
    // 当前指示日期
    _indicatorDate = [NSString stringWithFormat:@"%@/%@/%@", @(year), @(month), @(day)];
}

- (void) handleShortPackageEffectiveAnswer: (Byte *) bytes {
    
    // 屏蔽掉不合理数据
    if (bytes[2] < 0x02 || bytes[2] >= 0xfe) {
        return;
    }
    
    // 获取短包序号
    _shortPackageNumber = bytes[2];
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<((_shortPackageNumber - 1) % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    [_longPackageData appendBytes: effectiveByte length: 17];
}

- (void) handleShortPackageLastAnswer: (Byte *) bytes {
    
    // 过滤数据
    if (bytes[2] != 0xfe) {
        return;
    }
    
    _shortPackageNumber = _shortPackageCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageNumber / 8] &= 0xff^(1<< (_shortPackageNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    [_longPackageData appendBytes: effectiveByte length: effectiveLength];
    
    // 处理这一天的数据
    [self handleOneDaySteps];
    
    // 然后确认数据
    
    //                NSLog(@"%@", _longPackageData);
    //                HXBaseActionDataModel *model = [[HXBaseActionDataModel alloc] init];
    //                Byte acBY[20] = {0};
    //                acBY[0] = 0x5a;
    //                acBY[1] = 0x05;
    //                acBY[3] = self.longPackageNumber / 256;
    //                acBY[4] = self.longPackageNumber % 256;
    //                model.characteristicString = [self.characteristicUUIDString lowercaseString];
    //                model.actionData = [NSData dataWithBytes: acBY length: 20];
    //                self->_answerBlock(model);
}

- (void) handleOneDaySteps {
    
    NSLog(@"%@: 所有数据:%@ ====> %@", _indicatorDate, _longPackageData, @(_longPackageData.length));
    
    if (_longPackageData.length % 2 != 0) {
        HXDEBUG;
        exit(0);
    }
    
    // 获得数据
    Byte *bytes = (Byte *)[_longPackageData bytes];
    
    NSMutableArray *sportDataArray = [NSMutableArray array];
    
    for (NSInteger index = 0; index < _longPackageData.length / 2; index += 2) {
        
        NSString *timeSection = [NSString stringWithFormat:@"%02ld:%02ld~%02ld:%02ld", (long)(index/2 * 30/ 60), (long)(index/2 * 30 % 60), (long)(long)((index/2 + 1)*30/60), (long)((index/2 + 1)*30%60)];
        
        NSInteger stepData = bytes[index] * 256 + bytes[index + 1];
        
        if (stepData >= 0x000 && stepData <= 0xfeff) {
            NSDictionary *dictInfo = @{timeSection: @(stepData)};
            [sportDataArray addObject: dictInfo];
        } else if (stepData)
    }
    
    
}
@end
