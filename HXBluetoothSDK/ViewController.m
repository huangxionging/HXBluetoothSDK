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
#import "HXWKLSleepAction.h"

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
    
    __weak UILabel *title = _titleString;
    [controller setBlock:^(BOOL finished, BlockType type) {
        if (finished == YES) {
            if (type == kBlockTypeClient) {
                title.text = @"正在绑定...";
            }
            else {
                [_indicatorView stopAnimating];
                _indicatorView.hidden = YES;
                title.text = @"绑定成功...";
            }
        }
    }];
    
    [controller startWork];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)resStart:(id)sender {
    
    [controller.baseClient cancelPeripheralConnection];
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    _titleString.text = @"正在搜索....";
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
    
    _titleString.text = @"解除绑定成功...";
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
    
    
    HXWKLBindDeviceAction *applyBindDevice = [HXWKLBindDeviceAction actionWithFinishedBlock:^(BOOL finished, id responseObject) {
        
        if (finished == YES) {
            NSLog(@"绑定成功");
            [_indicatorView stopAnimating];
            _indicatorView.hidden = YES;
        }
        
    }];
    
    applyBindDevice.bindDeviceState = kWKLBindDeviceStateApply;
    
    [controller sendAction: applyBindDevice];
    
    [applyBindDevice setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        [controller.baseDevice sendActionWithModel: answerDataModel];
    }];
}

- (IBAction)synchronizeStep:(id)sender {
    
    _titleString.text = @"正在同步计步...";
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    HXWKLStepAction *stepAction = [HXWKLStepAction actionWithFinishedBlock:^(BOOL finished, id responseObject) {
        
        _titleString.text = @"同步成功";
        _indicatorView.hidden = YES;
        [_indicatorView stopAnimating];
        _dataSource = responseObject[@"data"];
        [_tableView reloadData];
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
    
    _titleString.text = @"正在同步睡眠...";
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    HXWKLSleepAction *sleepAction = [HXWKLSleepAction actionWithFinishedBlock:^(BOOL finished, id responseObject) {
        
        _titleString.text = @"同步成功";
        _indicatorView.hidden = YES;
        [_indicatorView stopAnimating];
        _dataSource = responseObject[@"data"];
        [_tableView reloadData];
    }];
    
 //   sleepAction.stepActionType = kWKLStepActionTypeSynchronizeStepData;
    sleepAction.startDate = @"0";
    sleepAction.endDate = @"0";
    //    stepAction.startDate = @"2015/11/01";
    //    stepAction.endDate = @"2015/11/16";
    
    // 发送同步操作
    [controller sendAction: sleepAction];
    
    [sleepAction setAnswerActionDataBlock:^(HXBaseActionDataModel *answerDataModel) {
        [controller.baseDevice sendActionWithModel: answerDataModel];
    }];

}

- (IBAction)synchronizeParameter:(id)sender {
    
    _titleString.text = @"正在同步参数...";
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    
    
    
    HXWKLSynchronizeParameterAction *synchronizeParam = [HXWKLSynchronizeParameterAction actionWithFinishedBlock:^(BOOL finished, id responseObject) {
        
        _titleString.text = @"同步成功";
        _indicatorView.hidden = YES;
        [_indicatorView stopAnimating];
        
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
    return _dataSource.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource[section][@"sportData"] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _dataSource[section][@"date"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @"Cell"];
        
    }
    
    NSDictionary *dict = _dataSource[indexPath.section][@"sportData"][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"时间: %@", dict.allValues[1]];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ 步", dict.allValues[0]];
    
    return  cell;
}
@end
