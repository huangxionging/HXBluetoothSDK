//
//  ViewController.m
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/5.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "ViewController.h"
#import "HXBaseController.h"
#import "HXBaseClient.h"

@interface ViewController () {
    HXBaseController *controller;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
       
    controller = [[HXBaseController alloc] init];
    
    HXBaseClient *baseClient = [HXBaseClient shareBaseClient];
    
    [baseClient addPeripheralScanService: nil];
    
    [controller startWorkWithBaseClient: baseClient];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
