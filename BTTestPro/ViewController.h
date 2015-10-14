//
//  ViewController.h
//  BTTestPro
//
//  Created by 刘 晓东 on 15/10/10.
//  Copyright © 2015年 刘 晓东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CBCentralManager *myCBCentralManager;
@property (nonatomic, strong) NSMutableArray *periphearlList;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) UILabel * heartRateLabel;
@property (nonatomic, strong) UITableView *searchResultList;

@end

