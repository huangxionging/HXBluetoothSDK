//
//  HXWKLBindDeviceAction.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/11.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXWKLBindDeviceAction.h"

@interface HXWKLBindDeviceAction ()

@property (nonatomic, assign) NSInteger wklActionLength;

@end

@implementation HXWKLBindDeviceAction

- (NSInteger)actionLength {
    return self.wklActionLength;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.wklActionLength = 20;
    }
    
    return self;
}



#pragma mark---命令数据
- (NSData *)actionData {
    
    Byte bytes[20] = {0};
    
    bytes[0] = 0x5a;
    bytes[1] = 0x0b;
    bytes[3] = self->_bindDeviceState;
    
    // 回复确认绑定
    if (self->_bindDeviceState == kWKLBindDeviceStateConfirm) {
        bytes[0] = 0x5a;
    }
    
    // 解除绑定
    if (self->_bindDeviceState == kWKLBindDeviceStateCancel) {
        
    }
    
    return [NSData dataWithBytes: bytes length: 20];
}

#pragma mark--- 接收数据的方法
- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel {
    
    NSLog(@"%@", updateDataModel.actionData);
    
    if (updateDataModel) {
        Byte *bytes = (Byte *)[updateDataModel.actionData bytes];
        
        // 并且操作数据存在
        if (updateDataModel.actionDatatype == kBaseActionDataTypeUpdateAnwser && bytes) {
            if (bytes[0] == 0x5a && bytes[1] == 0x0b && bytes[3] == 0x02 && bytes[4] == 0x00) {
                // 这个是确认绑定指令
                self->_bindDeviceState = kWKLBindDeviceStateConfirm;
                
                // 回复指令
                self->_answerBlock([HXBaseActionDataModel modelWithAction: self]);
                
            }
            else if (bytes[0] == 0x5b && bytes[1] == 0x0b && bytes[3] == 0x01) {
                
                if (bytes[4] == 0x00) {
                    NSLog(@"设备允许绑定 延时为 %@ s", @(bytes[5]));
                }
            }
        }
        else if (updateDataModel.actionDatatype == kBaseActionDataTypeWriteAnswer){
            
            if (!updateDataModel.error && self.bindDeviceState == kWKLBindDeviceStateConfirm) {
                self->_finishedBlock(YES, nil);
                NSLog(@"写成功");
            }
            else {
                self->_finishedBlock(NO, nil);
            }
        }
        
    }
    
}

@end
