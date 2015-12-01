//
//  StringToHex.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/27.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#ifndef StringToBytes_hpp
#define StringToBytes_hpp

#import <stdio.h>
#import <map>
#import <string>
#import <Foundation/Foundation.h>

using namespace std;

class StringToHex {
    map<char, int> hex_map;
    
    
public:
    
    // 默认构造函数
    StringToHex();
    
    // 析构函数
    ~StringToHex();
    
    // 将 oc 字符串转换成字节
    Byte * bytesForString(NSString *strings);
    
    // 转换成 data
    NSData * dataForString(NSString *strings);
    
    // 将 16 进制数据转换成 字符串
    NSString *hexStringForData(NSData *data);
    
};

#endif /* StringToBytes_hpp */