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
#import "HXWKLPayAction.h"
#import "HXBaseWorkingManager.h"

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
       
//    controller = [[HXWKLController alloc] init];
    
  //  __weak UILabel *title = _titleString;
//    [controller setBlock:^(BOOL finished, BlockType type) {
//        if (finished == YES) {
//            if (type == kBlockTypeClient) {
//                title.text = @"正在绑定...";
//            }
//            else {
//                [_indicatorView stopAnimating];
//                _indicatorView.hidden = YES;
//                title.text = @"绑定成功...";
//            }
//        }
//    }];
//    
//    [controller startWork];
//
    
    [HXBaseWorkingManager managerWithConfiguresOfFile: @"HXWKLBluetooth"];
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
    
    [[HXBaseWorkingManager manager] post: @"bleto://actions/short_actions/synchronize_parameter?type=5" parameters: nil success:^(HXBaseAction *action, id responseObject) {

    } failure:^(HXBaseAction *action, HXBaseError *error) {
        
    }];
    
}

- (IBAction)cancleBindDevice:(id)sender {
    
    _titleString.text = @"解除绑定成功...";
}

- (IBAction)changeColor:(id)sender {
 
}

- (IBAction)applyBindDevice:(id)sender {
    
}

- (IBAction)synchronizeStep:(id)sender {
    
    _titleString.text = @"正在同步计步...";
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
}

- (IBAction)preventLossSwitch:(id)sender {
}

- (IBAction)wechatMessage:(id)sender {
}

- (IBAction)synchronizeSleep:(id)sender {
    
}

- (IBAction)synchronizeParameter:(id)sender {
    
    _titleString.text = @"正在同步参数...";
    _indicatorView.hidden = NO;
    [_indicatorView startAnimating];
    
    
}

- (IBAction)queryBalance:(id)sender {
    
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
