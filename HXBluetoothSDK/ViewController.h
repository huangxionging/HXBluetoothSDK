//
//  ViewController.h
//  HXBluetoothSDK
//
//  Created by huangxiong on 15/11/5.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *titleString;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)resStart:(id)sender;

- (IBAction)sendFindAction:(id)sender;
- (IBAction)cancleBindDevice:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)applyBindDevice:(id)sender;
- (IBAction)synchronizeStep:(id)sender;
- (IBAction)preventLossSwitch:(id)sender;
- (IBAction)wechatMessage:(id)sender;
- (IBAction)synchronizeSleep:(id)sender;
- (IBAction)synchronizeParameter:(id)sender;

@end

