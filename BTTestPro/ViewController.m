//
//  ViewController.m
//  BTTestPro
//
//  Created by 刘 晓东 on 15/10/10.
//  Copyright © 2015年 刘 晓东. All rights reserved.
//

#import "ViewController.h"
#import "HeartRateDataView.h"
#import <AVFoundation/AVFoundation.h>

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

#define HeartRateServiceTypeUUID @"180D"

@interface ViewController ()
{
    NSTimer *myTimer;
    HeartRateDataView *hrdView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (nil == _periphearlList) {
        _periphearlList = [[NSMutableArray alloc] init];
    }

    _heartRateLabel                 = [[UILabel alloc] init];
    _heartRateLabel.backgroundColor = [UIColor clearColor];
    _heartRateLabel.font            = [UIFont boldSystemFontOfSize:15];
    _heartRateLabel.textColor       = [UIColor colorWithRed:0.267 green:0.631 blue:0.725 alpha:1.000];
    _heartRateLabel.frame           = CGRectMake(12,350,70, 20);
    _heartRateLabel.text            = @"心率";
    [self.view addSubview:_heartRateLabel];

    _searchResultList            = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, ScreenWidth, 300) style:UITableViewStylePlain];
    _searchResultList.dataSource = self;
    _searchResultList.delegate   = self;
    [_searchResultList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_searchResultList];

    _myCBCentralManager          = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    
    UIButton *reportHeartRateBtn       = [UIButton buttonWithType:UIButtonTypeSystem];
    reportHeartRateBtn.frame           = CGRectMake(13,284, 294, 43);
    [reportHeartRateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reportHeartRateBtn setTitle:@"语音播报" forState:UIControlStateNormal];
    reportHeartRateBtn.backgroundColor = [UIColor colorWithRed:0.265 green:1.000 blue:0.256 alpha:1.000];
    
    reportHeartRateBtn.tag       = 103;
    [self.view addSubview:reportHeartRateBtn];
    [reportHeartRateBtn addTarget:self action:@selector(reportHeartRateBtnAction) forControlEvents:UIControlEventTouchUpInside];
    reportHeartRateBtn.enabled   = YES;
    
    hrdView = [[HeartRateDataView alloc] initWithFrame:CGRectMake(13, 380, 294, 170)];
    hrdView.backgroundColor = [UIColor colorWithRed:0.071 green:0.894 blue:1.000 alpha:1.000];
    [self.view addSubview:hrdView];
    
    
    if (myTimer == nil) {
        NSTimeInterval timeInterval = 5.0f;
        myTimer                     = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                   target:self
                                                 selector:@selector(reportHeartRage)
                                                 userInfo:nil repeats:YES];
        [myTimer setFireDate:[NSDate distantFuture]];
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    //[myTimer invalidate];
   // myTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated{

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_periphearlList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell                  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    CBPeripheral *peri    = [_periphearlList objectAtIndex:indexPath.row];
    if (peri) {
        cell.textLabel.text = peri.name;
        //cell.imageView.image = [UIImage imageNamed:@"conference-512"];
    }
    return cell;
}

#pragma mark - talbedelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peri = [_periphearlList objectAtIndex:indexPath.row];
    [_myCBCentralManager connectPeripheral:peri options:nil];
    NSLog(@"connect periphear :%@ ", peri);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma-mark  <CBCentralManagerDelegate>
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSArray *uuidArray = [NSArray arrayWithObjects:[CBUUID UUIDWithString:HeartRateServiceTypeUUID], nil];
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已经打开");
            [_myCBCentralManager scanForPeripheralsWithServices:uuidArray options:nil];
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"蓝牙关闭。。");
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"peripheral : %@",peripheral);
    NSLog(@"RSSI : %@",RSSI);
    NSLog(@"advertisementData: %@",advertisementData);
    [_periphearlList addObject:peripheral];
    [_searchResultList reloadData];
   // [_myCBCentralManager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
     NSLog(@">>>连接到名称为（%@）的设备-成功",peripheral.name);
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
      NSLog(@">>>连接到名称为（%@）的设备-失败,原因:%@",[peripheral name],[error localizedDescription]);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@">>>断开到名称为（%@）的设备连接-成功",peripheral.name);
     [_myCBCentralManager connectPeripheral:peripheral options:nil];
}

#pragma-mark  <CBPeriphearlDelegate>
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error)
    {
        NSLog(@">>>Discovered services for %@ with error: %@", peripheral.name, [error localizedDescription]);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@">>>service.UUID : %@",service.UUID);
        //扫描每个service的Characteristics，扫描到后会进入方法： -(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error)
    {
        NSLog(@"error Discovered characteristics for %@ with error: %@", service.UUID, [error localizedDescription]);
        return;
    }
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        NSLog(@"lxd:->->service:%@ 的 Characteristic: %@",service.UUID,characteristic.UUID);
        NSLog(@"lxd:->->service:%@ 的 Characteristic: %@",service.UUID.UUIDString,characteristic.UUID.UUIDString);
    }
    //获取Characteristic的值，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        {
            //[peripheral readValueForCharacteristic:characteristic];
            //180D Heart Rate
            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
                [self notifyCharacteristic:peripheral characteristic:characteristic];
            }
        }
    }
    
    //搜索Characteristic的Descriptors，读到数据会进入方法：-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    for (CBCharacteristic *characteristic in service.characteristics){
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

//获取的charateristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //!注意，value的类型是NSData，具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"characteristic uuid:%@  value:%@",characteristic.UUID,characteristic.value);
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
    {
        int heartRate = 0;
        if( (characteristic.value)  || !error )
        {
            char i = 0;
            [characteristic.value getBytes:&i length:1];
            if ( (i&1) == 1) {
                uint16_t result;
                [characteristic.value getBytes:&result range:NSMakeRange(1, sizeof(result))];
                heartRate = result;
            }else
            if ((i&1) == 0) {
                uint8_t result;
                [characteristic.value getBytes:&result range:NSMakeRange(1, sizeof(result))];
                heartRate = result;
            }
            NSLog(@"^_^ : heart rate : %i" ,heartRate );
            _heartRateLabel.text = [NSString stringWithFormat:@"%i",heartRate];
            hrdView.heartValue = [NSNumber numberWithInteger:heartRate];
        }
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
    {
        //set refresh int
        uint8_t val = 4;
        NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
        [peripheral writeValue:valData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        
        int i;
        [characteristic.value getBytes: &i length: sizeof(i)];
        NSLog(@"lxd gere >>> characteristic value is:%i", i);
    }
    
}

//搜索到Characteristic的Descriptors
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //打印出Characteristic和他的Descriptors
    //NSLog(@"characteristic uuid:%@",characteristic.UUID);
    for (CBDescriptor *d in characteristic.descriptors) {
        //NSLog(@"Descriptor uuid:%@",d.UUID);
    }
}

//获取到Descriptors的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
   // NSLog(@"descriptor uuid:%@  value:%@",[NSString stringWithFormat:@"%@",descriptor.UUID],descriptor.value);
}

//设置通知
-(void)notifyCharacteristic:(CBPeripheral *)peripheral
             characteristic:(CBCharacteristic *)characteristic{
    //设置通知，数据通知会进入：didUpdateValueForCharacteristic方法
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

//取消通知
-(void)cancelNotifyCharacteristic:(CBPeripheral *)peripheral
                   characteristic:(CBCharacteristic *)characteristic{
    
    [peripheral setNotifyValue:NO forCharacteristic:characteristic];
}

#pragma-mark voice
- (void)reportHeartRateBtnAction {
    [myTimer setFireDate:[NSDate date]];
}

- (void)reportHeartRage {
    [self saySomethingWith:_heartRateLabel.text];
}

- (void)saySomethingWith:(NSString*)someThing{
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:_heartRateLabel.text];
    //设置语言类别（不能被识别，返回值为nil）
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voiceType;
    //设置语速快慢
    utterance.rate *= 1;
    //语音合成器会生成音频
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
    
    [synthesizer speakUtterance:utterance];
}

@end