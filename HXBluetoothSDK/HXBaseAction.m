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

+ (instancetype)actionWith:(id)parameter andAnswerActionDataBlock:(void (^)(HXBaseActionDataModel *))answerActionBlock andFinishedBlock:(void (^)(id))finishedBlock{
    
    HXBaseAction *action = [[super alloc] initWithParameter: parameter answer: answerActionBlock finished: finishedBlock];
    
    return action;
}

- (NSArray *)registerKeysForAction {
    if ([[self class] isSubclassOfClass: [HXBaseAction class]]) {
        NSLog(@"请在子类实现");
        HXDEBUG;
        NSParameterAssert(0);
    }
    return nil;
}

- (NSData *)actionData {
    if ([[self class] isSubclassOfClass: [HXBaseAction class]]) {
        NSLog(@"请在子类实现");
        HXDEBUG;
        NSParameterAssert(0);
    }
    return [[NSData alloc] init];
}

- (void)receiveUpdateData:(HXBaseActionDataModel *)updateDataModel {
    
    if ([[self class] isSubclassOfClass: [HXBaseAction class]]) {
        NSLog(@"请在子类实现");
        HXDEBUG;
        NSParameterAssert(0);
    }
}

- (void)setAnswerActionDataBlock:(void (^)(HXBaseActionDataModel *))answerActionBlock {
    self->_answerBlock = answerActionBlock;
}

#pragma mark- 初始化 action
- (instancetype)initWithParameter:(id)parameter answer:(void (^)(HXBaseActionDataModel *))answerBlock finished:(void (^)(id))finishedBlock {
    if (self = [super init]) {
        self->_answerBlock = answerBlock;
        self->_finishedBlock = finishedBlock;
        
        // 类名
        self->_acionName = [NSString stringWithUTF8String: object_getClassName(self)];
        
        // 默认命令长度
        self->_actionLength = 20;
    }
    return self;
}

@end
