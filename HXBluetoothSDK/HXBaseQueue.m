//
//  HXBaseQueue.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/12/18.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseQueue.h"

@interface HXBaseQueue () {
    
    /**
     *  队列数组
     */
    NSMutableArray *_queue;
}

@end

@implementation HXBaseQueue

#pragma mark---判断队列是否还有元素
- (BOOL)hasElement {
    return self.queueLength?YES:NO;
}

#pragma mark---获取队列长度
- (NSUInteger)queueLength {
    return self->_queue.count;
}

#pragma mark---入队
- (void)queuePush:(id)obj {
    
    // 判断参数
    NSParameterAssert(obj);
    
    if (!_queue) {
        _queue = [NSMutableArray arrayWithCapacity: 10];
    }
    
    [_queue addObject: obj];
}

#pragma mark---出队
- (id)queuePop {
    id objc = _queue[0];
    
    [_queue removeObjectAtIndex: 0];
    
    return objc;
}

#pragma mark---访问队尾
- (id)frontOfQueue {
    return _queue[0];
}

#pragma mark---访问队尾
- (id)rearOfQueue {
    return [_queue lastObject];
}

@end
