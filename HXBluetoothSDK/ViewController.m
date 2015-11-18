//
//  ViewController.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/5.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "ViewController.h"
#import "HXWKLController.h"
#import "HXBaseClient.h"
#import "HXBaseDevice.h"
#import "HXWKLSearchDeviceAction.h"
#import "HXWKLBindDeviceAction.h"
#import "HXWKLChangeColorAction.h"
#import "HXWKLStepAction.h"
#import "HXWKLSynchronizeParameterAction.h"
#import "NSDate+HXUtilityTool.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate> {
    HXWKLController *controller;
    NSMutableArray *_dataSource;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [_indicatorView startAnimating];
       
    controller = [[HXWKLController alloc] init];
    
    [controller startWork];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resStart:(id)sender {
    if (controller.baseClient) {
        [controller.baseClient startScanPeripheralWithOptions: nil];
    }
}

- (IBAction)sendFindAction:(id)sender {
    
 //   [controller sendAction: [[HXWKLSearchDeviceAction alloc] init]];
    [controller sendAction: [HXWKLSearchDeviceAction actionWithFinishedBlock:^(BOOL finished, NSDictionary<NSString *,id> *finisedInfo) {
        
        if (finished == YES) {
            NSLog(@"操作成功");
        }
        else {
            NSLog(@"操作失败");
        }
    }]];
    
}

- (IBAction)cancleBindDevice:(id)sender {
    
    HXWKLBindDeviceAction *cancleBindDevice = [HXWKLBindDeviceAction actionWithFinishedBlock:^(BOOL finished, NSDictionary<NSString *,id> *finisedInfo) {
        if (finished == YES) {
            NSLog(@"解除绑定成功");
        }
        
    }];
    
    cancleBindDevice.bindDeviceState = kWKLBindDeviceStateCancel;
    
    [controller sendAction: cancleBindDevice];
    
    [cancleBindDevice setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        [controller.baseDevice sendActionWithModel: answerDataModel];
    }];
}

- (IBAction)changeColor:(id)sender {
    HXWKLChangeColorAction *changeColorAction = [HXWKLChangeColorAction actionWithFinishedBlock:^(BOOL finished, NSDictionary<NSString *,id> *finisedInfo) {
        
        if (finished == YES) {
            NSLog(@"颜色成功");
        }
        
    }];
    
    changeColorAction.colorType = arc4random() % 4;
    
    [controller sendAction: changeColorAction];
    
    [changeColorAction setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        [controller.baseDevice sendActionWithModel: answerDataModel];
    }];

}

- (IBAction)applyBindDevice:(id)sender {
    
    HXWKLBindDeviceAction *applyBindDevice = [HXWKLBindDeviceAction actionWithFinishedBlock:^(BOOL finished, NSDictionary<NSString *,id> *finisedInfo) {
        
        if (finished == YES) {
            NSLog(@"绑定成功");
        }
        
    }];
    
    applyBindDevice.bindDeviceState = kWKLBindDeviceStateApply;
    
    [controller sendAction: applyBindDevice];
    
    [applyBindDevice setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        [controller.baseDevice sendActionWithModel: answerDataModel];
    }];
}

- (IBAction)synchronizeStep:(id)sender {
    HXWKLStepAction *stepAction = [HXWKLStepAction actionWithFinishedBlock:^(BOOL finished, NSDictionary<NSString *,id> *finisedInfo) {
        
    }];
    
    stepAction.stepActionType = kWKLStepActionTypeSynchronizeStepData;
    stepAction.startDate = @"0";
    stepAction.endDate = @"0";
//    stepAction.startDate = @"2015/11/01";
//    stepAction.endDate = @"2015/11/16";
    
    // 发送同步操作
    [controller sendAction: stepAction];
    
    [stepAction setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        [controller.baseDevice sendActionWithModel: answerDataModel];
    }];
}

- (IBAction)preventLossSwitch:(id)sender {
}

- (IBAction)wechatMessage:(id)sender {
}

- (IBAction)synchronizeSleep:(id)sender {
}

- (IBAction)synchronizeParameter:(id)sender {
    HXWKLSynchronizeParameterAction *synchronizeParam = [HXWKLSynchronizeParameterAction actionWithFinishedBlock:^(BOOL finished, NSDictionary<NSString *,id> *finisedInfo) {
        
        
    }];
    synchronizeParam.time = [[NSDate date] stringForCurrentDateWithFormatString: @"yyyy/MM/dd HH:mm:ss"];
    synchronizeParam.steps = 20000;
    synchronizeParam.wearType = kWKLWearLocationTypeWrist;
    synchronizeParam.sportType = kWKLSportTypeWalk;
    synchronizeParam.isFirstSynchronize = YES;
    synchronizeParam.protocolEditionNumber = 0;
    synchronizeParam.genderType = kWKLGenderTypeMan;
    synchronizeParam.age = 25;
    synchronizeParam.weight = 75; // kg
    synchronizeParam.bodyHeight = 173; // cm
    // 功能
    synchronizeParam.functionItem = 0x10100000;
    
    [controller sendAction: synchronizeParam];
    
    [synchronizeParam setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  nil;
}
@end
