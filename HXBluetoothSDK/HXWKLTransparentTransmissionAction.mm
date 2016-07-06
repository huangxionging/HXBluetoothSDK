//
//  HXWKLTransparentTransmissionAction.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/24.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXWKLTransparentTransmissionAction.h"
#include "StringToHex.h"

@interface HXWKLTransparentTransmissionAction () {
    
    /**
     *  操作长度
     */
    NSInteger _actionLength;
    
    /**
     *  位域控制表
     */

    Byte _bitControlTable[15];

    /**
     *  短包数
     */
    Byte _shortPackage[120][17];
    
    /**
     *  表示设备是否主动发送
     */
    BOOL _deviceFirst;
    
    StringToHex *_hexString;
    
    // 关键字
    Byte _byteKeyWord;
    
    Byte _actionKeyWord;
    
    long _totalSize;
}

/**
 *  计步数据的总天数, 同时表示长包的个数
 */
@property (nonatomic, assign) NSInteger longPackageTotal;

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
 *  单个长包数据
 */
@property (nonatomic, strong) NSMutableData *longPackageData;

/**
 *  一天的总步数
 */
@property (nonatomic, copy) NSString *oneDayTotalData;

/**
 *  每天的数据信息
 */
@property (nonatomic, strong) NSMutableDictionary *dataInfo;

/**
 * 包含所有长包数据
 */
@property (nonatomic, strong) NSMutableArray *allData;


@end


@implementation HXWKLTransparentTransmissionAction

- (NSInteger)actionLength {
    return _actionLength;
}
- (NSData *)actionData {
    
    if (_content) {
        NSInteger length = _content.length / 2 - 1;
        _actionLength = 4 + length;
    } else {
        return nil;
    }
    
    if (_actionLength > 20) {
        NSLog(@"长度不合理");
        assert(0);
        return nil;
    }
    
    Byte *bytes = (Byte *)malloc(sizeof(Byte) * _actionLength);
    
    // 创建 解析器
    if (_hexString == NULL) {
        _hexString = new StringToHex();
    }
    
    bytes[0] = 0x5a;
    bytes[1] = 0x19;
    
    _actionKeyWord = 0x19;
    
    // 记录关键字
    _byteKeyWord = *_hexString->bytesForString(_keyWord);
    bytes[3] = _byteKeyWord;
    
    // 拷贝数据
    memcpy(&bytes[4], _hexString->bytesForString(_content), _actionLength - 4);
    
    // 数据
    NSData *data = [NSData dataWithBytes: bytes length: _actionLength];
    
    NSLog(@"%@", data);
    
    // App 主动发
    _deviceFirst = NO;
    
    return data;
}

- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser) {
        
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        if (bytes == NULL) {
            return;
        }
        
        if (bytes[0] == 0x5a) {
            _deviceFirst = YES;
        } else {
            _deviceFirst = NO;
        }
        
        // 表示 设备主动发送
        if (_deviceFirst) {
            
            // 长包
            if (bytes[1] == 0x19 && bytes[3] >= 0xf0) {
                 [self handleFirstAnswer: bytes];
                return;
            } else if (bytes[1] == 0x19 && bytes[3] < 0xf0) {
                // 短包处理
                NSLog(@"发送的是短包数据");
            }
            
            // 设备开始主动发数据, 通用长包处理过程
            if (bytes[1] == 0x05) {
                
                if (bytes[2] == 0x01) {
                    
                    // 处理短包 操作信息
                    [self handleShortPackageActionAnswer: bytes];
                } else if (bytes[2] >= 0x02 && bytes[2] < 0xfe) {
                    
                    // 处理短包有效信息
                    [self handleShortPackageEffectiveAnswer: bytes];
                    
                } else if (bytes[2] == 0xfe) {
                    // 每个长包的最后一个短包
                    [self handleShortPackageLastAnswer: bytes];
                    
                } else if (bytes[2] == 0xff) {
                    // 最后一天数据
                    [self handleLastDayPackage: bytes];
                    
                } else if (bytes[2] == 0x00) {
                    // 特殊回应
                    [self handleNextDayDataPackage];
                }
            }

        } else {
            
            // 余额读取成功;
            
            NSInteger length = bytes[3];
            
            
            _longPackageData.length = 0;
            
            [_longPackageData appendBytes: &bytes[4] length: length];

            // 短包 回复, 回复都是 0x5b
            
            NSLog(@"%@  ==== length: %@", _longPackageData, @(_longPackageData.length));
            
            if (self->_finishedBlock) {
                
               // NSString *string = _hexString->hexStringForData(_longPackageData);
                self->_finishedBlock(_hexString->hexStringForData(_longPackageData));
            }
        }
        
               
    }
}

#pragma mark---处理第一个数据
- (void) handleFirstAnswer: (Byte *) bytes {
    
    
    _totalSize = 0;
    
    _longPackageTotal = 0;
    
    // 总长包的个数
    _totalSize = (bytes[4] << 24) + (bytes[5] << 16) + (bytes[6] << 8) + bytes[7];
    
    NSInteger oneLongPackageSize = bytes[8] * 256 + bytes[9];
    
    _longPackageTotal = _totalSize / oneLongPackageSize + (_totalSize % oneLongPackageSize)?1:0;
    
    NSLog(@"长包数%@", @(_longPackageTotal));
    
}

#pragma mark--- 处理每个长包的第一个短包数据
- (void) handleShortPackageActionAnswer: (Byte *) bytes {
    
    if (bytes[9] != _actionKeyWord) {
        return;
    }
    
    // 有效数据个数
    self.effectiveDataCount = bytes[3] * 256 + bytes[4];
    
    // 记录长包数据
    if (_longPackageData == nil) {
        _longPackageData = [NSMutableData data];
    }
    
    // 清空每个长包
    _longPackageData.length = 0;
    
    _shortPackageNumber = bytes[2];
    
    // 短包个数,
    _shortPackageCount = self.effectiveDataCount / 17 + ((self.effectiveDataCount % 17)?1:0);
    
    // 记录长包序号
    _longPackageNumber = bytes[5] * 256 + bytes[6];
    
    // 第一个分包位域控制, 以下三种算法都 ok, 采用取反的方法 ! 不行
    //_bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff - (1<< ((_shortPackageNumber - 1) % 8));
    
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<(_shortPackageNumber - 1) % 8);
    
    // 最后一包所在位域
    NSInteger bitIndex = _shortPackageCount % 8 + 1;
    for (NSInteger index = bitIndex; index < 8; ++index) {
        _bitControlTable[(_shortPackageCount) / 8] &= 0xff^(1<<index);
    }
    
    // 0xff - pow(2, (_shortPackageNumber - 1) / 8))
    
    // 位域控制
    for (NSInteger index = (_shortPackageCount) / 8 + 1; index < 15; ++index) {
        _bitControlTable[index] = 0x00;
    }
    
//    // 年月日
//    NSInteger year = bytes[10] + 2000;
//    NSInteger month = bytes[11];
//    NSInteger day = bytes[12];
//    
//    // 当前指示日期
//    _indicatorDate = [NSString stringWithFormat:@"%@/%@/%@", @(year), @(month), @(day)];
    
    memset(_shortPackage, '\0', sizeof(_shortPackage));
}

#pragma mark---处理有效数据
- (void) handleShortPackageEffectiveAnswer: (Byte *) bytes {
    
    // 屏蔽掉不合理数据
    if (bytes[2] < 0x02 || bytes[2] >= 0xfe) {
        return;
    }
    
    
    // 获取短包序号 是从 0x02 开始
    _shortPackageNumber = bytes[2];
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[(_shortPackageNumber - 1) / 8] &= 0xff^(1<<((_shortPackageNumber - 1) % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 获取短包序号 是从 0x02 开始, 所以要减去 2
    memcpy(_shortPackage[_shortPackageNumber - 2], effectiveByte, sizeof(Byte) * 17);
}

#pragma mark---处理除最后一个长包外的每个长包的最后一个短包,
- (void) handleShortPackageLastAnswer: (Byte *) bytes {
    
    // 过滤数据
    if (bytes[2] != 0xfe) {
        return;
    }
    
    // 修改短包序号
    _shortPackageNumber = _shortPackageCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageNumber / 8] &= 0xff^(1<< (_shortPackageNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    memcpy(_shortPackage[_shortPackageNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
    
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDayData];
    }
    
    [self sendBitControllTable];
}

#pragma mark---判断位域表
- (BOOL) shortPackageFinished {
    
    // 判断位域表是否全部为 0
    for (NSInteger index = 0; index < 15; ++index) {
        
        if (_bitControlTable[index] != 0x00) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark---处理睡眠数据
- (void) handleOneDayData {
    
    for (NSInteger index = 0; index < _shortPackageCount; ++index) {
        
        if (index == _shortPackageCount - 1) {
            // 最后一个有效数据的长度
            NSInteger effectiveLength = _effectiveDataCount % 17;
            
            // 有效数据
            if (!effectiveLength) {
                effectiveLength = 17;
            }
            
            // 最后一个短包
            [_longPackageData appendBytes: _shortPackage[index] length: effectiveLength];
            
        } else {
            [_longPackageData appendBytes: &_shortPackage[index] length: 17];
        }
    }
    
    NSLog(@"所有数据:%@ ====> 长度: %@", _longPackageData, @(_longPackageData.length));
    
        // 获得数据
  
    
}

#pragma mark---发送位域控制表
- (void) sendBitControllTable {
    HXBaseActionDataModel *model = [[HXBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认位域表
    bytes[0] = 0x5b;
    bytes[1] = 0x05;
    bytes[3] = _longPackageNumber / 256;
    bytes[4] = _longPackageNumber % 256;
    
    Byte *bitControlTable = &bytes[5];
    
    memcpy(bitControlTable, _bitControlTable, sizeof(_bitControlTable) / sizeof(Byte));
    
    NSData *bitControlTableData = [NSData dataWithBytes: bytes length: 20];
    
    model.actionData = bitControlTableData;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    
    // 回传位域表
    NSLog(@"位域表: ======= %@", model.actionData);
    if (self->_answerBlock) {
        self->_answerBlock(model);
    }
   
}

#pragma mark---处理请求下一个长包
- (void) handleNextDayDataPackage {
    
    if (_longPackageNumber == _longPackageTotal || _longPackageTotal == 1) {
        // 表示所有数据发送完成
        
        NSLog(@"%@  ==== length: %@", _longPackageData, @(_longPackageData.length));
        
        if (self->_finishedBlock) {
            
           // NSString *string = _hexString->hexStringForData(_longPackageData);
            self->_finishedBlock( _hexString->hexStringForData(_longPackageData));
        }
        
        return;
    }
    
    memset(_bitControlTable, 0xff, sizeof(Byte) * 15);
    
    // 请求下一个长包数据
    HXBaseActionDataModel *model = [[HXBaseActionDataModel alloc] init];
    
    Byte bytes[20] = {0};
    
    // 确认长包
    bytes[0] = 0x5a;
    bytes[1] = 0x06;
    bytes[3] = _longPackageNumber / 256;
    bytes[4] = _longPackageNumber % 256;
    
    if (_longPackageNumber == _longPackageTotal || _longPackageTotal == 1) {
        bytes[3] = 0xff;
        bytes[4] = 0xff;
    }
    
    // 请求下一个回复数据
    NSData *nextData = [NSData dataWithBytes: bytes length: 20];
    model.actionData = nextData;
    model.actionDatatype = kBaseActionDataTypeUpdateSend;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    
    // 回传信息
    self->_answerBlock(model);
    
}

#pragma mark---处理最后一个长包的最后一个短包数据
- (void) handleLastDayPackage: (Byte *)bytes {
    _shortPackageNumber = _shortPackageCount;
    
    // 修改位域信息
    // 采用平移异或再相与
    _bitControlTable[_shortPackageNumber / 8] &= 0xff^(1<< (_shortPackageNumber % 8));
    
    // 拼接有效数据数据
    Byte *effectiveByte = &bytes[3];
    
    // 最后一个有效数据的长度
    NSInteger effectiveLength = _effectiveDataCount % 17;
    
    memcpy(_shortPackage[_shortPackageNumber - 1], effectiveByte, sizeof(Byte) * effectiveLength);
    
    if ([self shortPackageFinished]) {
        // 处理这一天的数据
        [self handleOneDayData];
    }
    
    [self sendBitControllTable];
}

@end
