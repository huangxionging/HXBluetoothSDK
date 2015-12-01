//
//  StringToHex.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/27.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#include "StringToHex.h"

StringToHex::StringToHex () {
    
    // 将16进制数据写入 map 表
    for (int index = 0; index < 16; ++index) {
        
        // 创建 char
        char *hexChar = (char *)malloc(sizeof(char));
        
        // 写入 char
        sprintf(hexChar, "%x", index);

        // 插入到 map
        hex_map.insert(pair<char, int>(*hexChar, index));
    }
    
}

StringToHex::~StringToHex() {
    free(&hex_map);
}



Byte *StringToHex::bytesForString(NSString *strings) {
    
    if (strings == nil) {
        return NULL;
    }
    NSUInteger length = strings.length / 2 - 1;
    
    Byte *bytes = (Byte *)malloc(sizeof(Byte) *length);
    
    memset(bytes, 0, length);
    NSString *lowcaseString = [strings lowercaseString];
    
    for (NSInteger index = 2; index < lowcaseString.length; index+=2) {
        
        char highChar = [lowcaseString characterAtIndex: index];
        char lowChar = [lowcaseString characterAtIndex: index + 1];
        
        NSLog(@"%c === %c", highChar, lowChar);
        // 获取值
        int highValue = hex_map.find(highChar)->second;
        int lowValue = hex_map.find(lowChar)->second;
        
        bytes[index / 2 - 1] = highValue * 16 + lowValue;
    }
    
    return bytes;
}

NSData *StringToHex::dataForString (NSString *strings) {
    
    NSInteger leng = strings.length / 2 - 1;
    
    Byte *bytes = this->bytesForString(strings);
    
    return [NSData dataWithBytes: bytes length: leng];
    
}

NSString *StringToHex::hexStringForData(NSData *data) {
    
    // 用可变字符串接
    NSMutableString *mutableString = [NSMutableString string];
    
    // 处理 data 所有的数据
    NSInteger length = data.length;
    Byte *bytes = (Byte *)[data bytes];
    for (NSInteger index = 0; index < length; ++index) {
        [mutableString appendFormat: @"%02x", bytes[index]];
    }
    
    return mutableString;
}


