//
//  HXBaseAction.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/6.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXBaseAction.h"
#import "HXBaseActionDataModel.h"



@interface HXBaseAction ()

@end

@implementation HXBaseAction


+ (instancetype)actionWithFinishedBlock:(void (^)(BOOL, NSDictionary<NSString *,id> *))finishedBlock {
    HXBaseAction *action = [[super alloc] init];
    
    if (action) {
        action->_finishedBlock = finishedBlock;
        
        // 类名
        action->_acionName = [NSString stringWithUTF8String: object_getClassName(self)];
        
        // 默认命令长度
        action->_actionLength = 20;
        
        // 监听完成对象
    //    [action addObserver: action forKeyPath: @"finished" options:NSKeyValueObservingOptionNew context: nil];
    }
    
    return action;
}

- (NSData *)actionData {
    return [[NSData alloc] init];
}

- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel {
    
}

- (void)setAnswerActionDataBlock:(void (^)(HXBaseActionDataModel *))answerActionBlock {
    self->_answerBlock = answerActionBlock;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString: @"finished"]) {
        self.finished;
    }
}

@end
