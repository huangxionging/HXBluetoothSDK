//
//  HXBaseQueue.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/12/18.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXBaseQueue : NSObject

// 查询是否还有元素
- (BOOL) hasElement;

// 队列长度
- (NSUInteger) queueLength;

// 入队操作
- (void) queuePush: (id) obj;

// 访问队首元素
- (id) frontOfQueue;

// 访问队尾元素
- (id) rearOfQueue;

// 出队操作
- (id) queuePop;

@end
