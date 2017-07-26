//
//  ControllDoorController.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "ControllDoorController.h"
#import "SettingsController.h"
#define channelOnPeropheralView @"peripheralView"

@interface ControllDoorController ()

@property (nonatomic,strong)CBCharacteristic *characteristic;

/** 假导航*/
@property (nonatomic,strong) XHNavView *navBar;
/** 硬件版本*/
@property (nonatomic,strong) UILabel *hardwareVersion;
/** 软件版本*/
@property (nonatomic,strong) UILabel *softwareVersion;

// 测试用 控件
@property (nonatomic,strong) UIView *testView;
@property (nonatomic,strong) UILabel *sendLabel;
@property (nonatomic,strong) UILabel *reciveLabel;

@end

@implementation ControllDoorController

//  MARK: - <----------LifyCycle---------->

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (isPopSettingViewController) {
        baby.channel(channelOnPeropheralView).characteristicDetails(self.currPeripheral,self.characteristic);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self preparUserInterface];
    [self test];
    [self setMasonry];
    [self requestData];
}

- (void)test {
    // 测试显示用
    self.testView = [UIView new];
    [self.view addSubview:self.testView];
    self.sendLabel = [UILabel new];
    [self.testView addSubview:self.sendLabel];
    self.reciveLabel = [UILabel new];
    [self.testView addSubview:self.reciveLabel];
    [self.testView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        make.width.offset(APPW);
        make.height.offset(80);
    }];
    [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.testView);
        make.top.equalTo(self.testView.mas_top).offset(10);
        make.height.offset(30);
    }];
    [self.reciveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.testView);
        make.height.offset(30);
        make.bottom.equalTo(self.testView.mas_bottom).offset(-10);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//  MARK: - <----------Public---------->
//  MARK: - <----------Private---------->

- (void)preparUserInterface {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navBar];
    [self.view addSubview:self.hardwareVersion];
    [self.view addSubview:self.softwareVersion];
    WEAK_SELF(weakSelf);
    self.navBar.leftBlock = ^() {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    weakify(self);
    self.navBar.rightBlock = ^() {
        strongify(self);
        SettingsController *vc = [SettingsController new];
        vc->baby = baby;
        vc.currPeripheral = weakSelf.currPeripheral;
        vc.characteristic = weakSelf.characteristic;
        if(weakSelf.characteristic.isNotifying) {
        [self->baby cancelNotify:weakSelf.currPeripheral characteristic:weakSelf.characteristic];
        }
        isPopSettingViewController = NO;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
}

- (void)notify {
    WEAK_SELF(weakSelf);
    if(self.currPeripheral.state != CBPeripheralStateConnected) {
        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    if (self.characteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate) {
        
        if(self.characteristic.isNotifying) {
            [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
        }else{
            [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
            // 5502 0aaa bbcc ddee ffa3
            [baby notify:self.currPeripheral
          characteristic:self.characteristic
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                       NSLog(@"notify block");
                       NSLog(@"new value %@",characteristics.value);
                       weakSelf.reciveLabel.text = [NSString stringWithFormat:@"接收到的数据:%@",characteristics.value.description];
                       NSString *value = characteristics.value.description;
                       NSLog(@"%@",value);
                       if ([value hasPrefix:@"<5502"]) {
                           weakSelf.hardwareVersion.text = [NSString stringWithFormat:@"硬件版本:%@",[BLETool hardwareInfo:value]];
                           weakSelf.softwareVersion.text = [NSString stringWithFormat:@"软件版本:%@",[BLETool softwareInfo:value]];
                       }
                   }];
        }
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"这个characteristic没有nofity的权限"];
        return;
    }

}

// 获取版本号
- (void)getVersion {
    self.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode hexToBytes:BLE_ORDER_GETVERSION]];
    if (![self isSuccess]) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    [self.currPeripheral writeValue:[BLECode hexToBytes:BLE_ORDER_GETVERSION] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)fengCode {
    self.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_FENGMING]];
    if (![self isSuccess]) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    [self.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_FENGMING] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)openCode {
    self.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_OPEN]];
    if (![self isSuccess]) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    [self.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_OPEN] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)closeCode {
    self.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_CLOSE]];
    if (![self isSuccess]) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    [self.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_CLOSE]forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

- (void)requestData {
    self.services = [NSMutableArray new];
    [self babyDelegate];
    //开始扫描设备
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2];
    [SVProgressHUD showInfoWithStatus:@"准备连接设备"];
//    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
}

// 判断是否已经找到符合的特征
- (BOOL)isSuccess {
    if (self.currPeripheral.state == CBPeripheralStateConnected && self.characteristic) {
        return YES;
    } else {
        return NO;
    }
}



- (void)loadData {
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    baby.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}
//babyDelegate
-(void)babyDelegate{
    
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
            //[weakSelf insertSectionToTableView:s];
        }
        
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
        //[weakSelf insertRowToTableView:service];
        
    }];
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        
        NSData *data = characteristics.value;
    }];
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        
    }];

    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        if (characteristic.descriptors.count > 0) {
            weakSelf.characteristic = characteristic;
            [weakSelf notify];
            [weakSelf getVersion];
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
        

    }];
    
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
        //            [bry beatsOver];
        //        }
        
    }];
    
    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
}
- (void)timerTask {
    //    NSLog(@"timerTask");
    //    [self.currPeripheral readRSSI];
}

//  MARK: - <----------Lazy---------->
- (XHNavView *)navBar {
    if (!_navBar) {
        _navBar = [XHNavView new];
        _navBar.navTitle = @"Demo";
        _navBar.iconName = @"ic_launcher";
        _navBar.rightTitle = @"设置";
        _navBar.leftName = @"back";
    }
    return _navBar;
}

- (UILabel *)hardwareVersion {
    if (!_hardwareVersion) {
        _hardwareVersion = [UILabel new];
    }
    return _hardwareVersion;
}

- (UILabel *)softwareVersion {
    if (!_softwareVersion) {
        _softwareVersion = [UILabel new];
    }
    return _softwareVersion;
}

//  MARK: - <----------Masonry---------->

- (void)setMasonry {
    // 辅助适配线
    UIView *tempLine = [UIView new];
    [self.view addSubview:tempLine];
    [tempLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(1);
        make.height.offset(APPH - 100);
        make.centerX.equalTo(self.view);
    }];
    
    // 版本号显示
    [self.hardwareVersion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(100 * APPP);
        make.centerX.equalTo(self.view);
    }];
    [self.softwareVersion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hardwareVersion.mas_bottom).offset(5 * APPP);
        make.centerX.equalTo(self.view);
    }];
    
    // 开门
    CGFloat distance = 5;// 两个按键之间的距离/2
    CGFloat topDistance = 200;// 两个按键距离顶部距离
    UIButton *openButton = [UIButton new];
    openButton.backgroundColor = [UIColor colorWithRed:0.44 green:0.72 blue:0.22 alpha:1.00];
    [openButton setTitle:@"开门" forState:UIControlStateNormal];
    openButton.layer.cornerRadius = 5;
    [openButton addTarget:self action:@selector(openCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openButton];
    [openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.right.equalTo(tempLine).offset(-distance * APPP);
        make.top.equalTo(self.view.mas_top).offset(topDistance * APPP);
    }];
    // 关门
    UIButton *closeButton = [UIButton new];
    closeButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [closeButton setTitle:@"关门" forState:UIControlStateNormal];
    closeButton.layer.cornerRadius = 5;
    [closeButton addTarget:self action:@selector(closeCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.left.equalTo(tempLine).offset(distance * APPP);
        make.top.equalTo(self.view.mas_top).offset(topDistance * APPP);
    }];
    
    // 蜂鸣器
    UIButton *fengButton = [UIButton new];
    fengButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [fengButton setTitle:@"蜂鸣器响" forState:UIControlStateNormal];
    fengButton.layer.cornerRadius = 5;
    [fengButton addTarget:self action:@selector(fengCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fengButton];
    [fengButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.top.equalTo(closeButton.mas_bottom).offset(40 * APPP);
        make.centerX.equalTo(self.view);
    }];
    // 导航
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.height.offset(64);
        make.top.left.right.equalTo(self.view);
    }];
}

//  MARK: - <----------Lazy---------->



@end
