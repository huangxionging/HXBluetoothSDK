//
//  HXWKLPayAction.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/23.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXWKLPayAction.h"
#import "HXWKLTransparentTransmissionAction.h"
#import "StringToHex.h"

/**
 *  状态
 */
typedef NS_ENUM(NSUInteger, WKLPayActionState) {
    kWKLPayActionStateNomal = 0,
    kWKLPayActionStateSelectedFile,
    kWKLPayActionStateOpen,
};

@implementation HXWKLPayAction {
    HXWKLTransparentTransmissionAction *_transparentAction;
    WKLPayActionState _state;
}

- (instancetype)init {
    if (self = [super init]) {
    
        _state = kWKLPayActionStateNomal;
    }
    return self;
}

#pragma mark---重写操作数据方法
- (NSData *)actionData {
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x18;
    
    switch (_payActionType) {
        case kWKLPayActionTypeQueryBalance: {
            bytes[3] = 0x00;
            break;
        }
            
        case kWKLPayActionTypeQueryDealRecord: {
            
            if (_queryDealRecordNumber <= 0 || _queryDealRecordNumber > 10) {
                HXDEBUG;
                assert(0);
            }
            
            bytes[3] = _queryDealRecordNumber;
            break;
        }
            
        case kWKLPayActionTypeResetting: {
            bytes[3] = 0x21;
            break;
        }
            
        default:
            break;
    }

    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    
    NSLog(@"数据:%@ ====> length: %@", data, @(data.length));
    return data;
    
}

- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    
    Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
    
    // 关闭 NFC
    if (bytes && bytes[0] == 0x5b && bytes[1] == 0x18 && bytes[3] == 0x21) {
        
        // 然后复位
        [self resettingPayAction];
    }
    else if (bytes && bytes[0] == 0x5b && bytes[1] == 0x18 && bytes[3] == 0x20) {
        
        _transparentAction  = [HXWKLTransparentTransmissionAction actionWithFinishedBlock:^(BOOL finished, id response) {
            
            if ([response isKindOfClass: [NSString class]]) {
                
                if ([response hasSuffix: @"9000"]) {
                    
                    
                    if ([_transparentAction.content isEqualToString: @"0x00A40000023F00"]) {
                        NSLog(@"读取文件成功");
                        
                        _transparentAction.keyWord = @"0x07";
                        [self readFileWith: @"0x00A40000023F01"];
                        
                    } else if ([_transparentAction.content isEqualToString: @"0x00A40000023F01"]) {
                        NSLog(@"读取文件成功");
                        
                        // 读取余额
                        _transparentAction.keyWord = @"0x05";
                        [self readFileWith:@"0x805C000204"];
                        
                    } else if ([_transparentAction.content isEqualToString: @"0x805C000204"]) {
                        
                        
                        NSRange range = [response rangeOfString: @"9000"];
                        
                        NSString *string = [response substringToIndex:range.location];
                        
                        NSData *data = [self dataForString: string];
                        
                        Byte *bytes = (Byte *)[data bytes];
                        
                        NSInteger sum = 0;
                        for (NSInteger index = 0; index < data.length; ++index) {
                            sum += bytes[index] << ((data.length - index - 1) * 8);
                        }
                        NSLog(@"余额: === %@元", @(sum));
                        
                    }
                }
                
                
            
            }
        }];
        
        // 关键词
        _transparentAction.keyWord = @"0x07";
        [self readFileWith: @"0x00A40000023F00"];
        
        
        
        
    }
    else if (bytes && bytes[0] == 0x5b && bytes[1] == 0x19 && bytes[3] == 0x20) {
        
    } else {
        [_transparentAction receiveUpdateData: updateDataModel];
    }
}

- (void) closePayAction {
    Byte bytes[20] = {0};
    bytes[0] = 0x5a;
    bytes[1] = 0x18;
    bytes[3] = 0x21;
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    
    HXBaseActionDataModel *model = [[HXBaseActionDataModel alloc] init];
    model.actionData = data;
    model.actionDatatype = kBaseActionDataTypeWriteAnswer;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    
    if (self->_answerBlock) {
        self->_answerBlock(model);
    }
}

- (void) resettingPayAction {
    
    Byte bytes[20] = {0};
    bytes[0] = 0x5a;
    bytes[1] = 0x18;
    bytes[3] = 0x20;
    
    NSData *data = [NSData dataWithBytes: bytes length: 20];
    
    HXBaseActionDataModel *model = [[HXBaseActionDataModel alloc] init];
    model.actionData = data;
    model.actionDatatype = kBaseActionDataTypeWriteAnswer;
    model.writeType = CBCharacteristicWriteWithResponse;
    model.characteristicString = [self.characteristicUUIDString lowercaseString];
    
    if (self->_answerBlock) {
        self->_answerBlock(model);
    }
}

- (void) readFileWith: (NSString *) readFileString {
    
    _transparentAction.content = readFileString;
    // 然后选择文件
    _transparentAction.characteristicUUIDString = self.characteristicUUIDString;
    
    if (self->_answerBlock) {
        self->_answerBlock([HXBaseActionDataModel modelWithAction: _transparentAction]);
    }
    
    HXWKLPayAction *weakSelf = self;
    
    [_transparentAction setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        
        // 回传信息
        if (weakSelf->_answerBlock) {
            weakSelf->_answerBlock(answerDataModel);
        }
    }];
}

// 假设 string 都是合理的 16进制字符串, 以0x 开头, 且长度是2的倍数
- (NSData *)dataForString:(NSString *)string {
    
    // 先变换成小写
    NSString *lowcaseByteString = [string lowercaseString];
    
    // 必须以 0x 作为前缀
    if ([lowcaseByteString hasPrefix: @"0x"] && lowcaseByteString.length % 2 == 0) {
        
        // 创建字节数组
        NSInteger length = lowcaseByteString.length / 2 - 1;
        Byte *bytes = (Byte *) malloc(sizeof(Byte) * length);
        memset(bytes, 0, length);
        
        // 循环获取字节数据
        for (NSInteger index = 2; index < lowcaseByteString.length; index+=2) {
            
            // 获取字符串
            NSString *string = [lowcaseByteString substringWithRange: NSMakeRange(index, 2)];
            
            // 扫描字符串 获得 16 进制数据
            NSScanner *scanner = [[NSScanner alloc] initWithString: string];
            unsigned int hexValue = 0;
            [scanner scanHexInt: &hexValue];
            
            // 为字节赋值
            bytes[index / 2 - 1] = (Byte) hexValue;
            
        }
        
        NSData *data = [NSData dataWithBytes: bytes length: length];
        NSLog(@"%@", data);
        
        return data;
    }
    else {
        return nil;
    }
    
}

@end
