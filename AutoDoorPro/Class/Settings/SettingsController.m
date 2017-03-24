//
//  SettingsController.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "SettingsController.h"
#import "SEFilterControl.h"
#import "ASValueTrackingSlider.h"
#import "UIButton+Block.h"
#import "BLESliderView.h"

#define channelOnCharacteristicView @"CharacteristicView"

typedef NS_ENUM(NSInteger,SliderTag) {
    SliderTagSpeed = 1000,
    SliderTagDamp = 1001,
    SliderTagClosure = 1002,
    SliderTagTime = 1003,
};
@interface SettingsController ()<BLESliderViewDelegate> {
    int speedValue;
    int dampValue;
    int closureValue;
    int timeValue;
    int autoCloseValue;
    int openDirectionValue;
}

/** 假导航*/
@property (nonatomic,strong) XHNavView *navBar;
/** 速度滑条*/
@property (nonatomic,strong) BLESliderView *speedView;
/** 阻尼滑条*/
@property (nonatomic,strong) BLESliderView *dampView;
/** 开门时间滑条*/
@property (nonatomic,strong) BLESliderView *timeView;
/** 紧闭力*/
@property (nonatomic,strong) BLESliderView *closureView;
/** 自动关门*/
@property (nonatomic,strong) UISwitch *autoCloseSwitch;
/** 开门方向*/
@property (nonatomic,strong) UISwitch *openDirectionSwitch;



// 测试用 控件
@property (nonatomic,strong) UIView *testView;
@property (nonatomic,strong) UILabel *sendLabel;
@property (nonatomic,strong) UILabel *reciveLabel;
@end

@implementation SettingsController

//  MARK: - <----------LifyCycle---------->
- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUserInterface];
    [self test];
    [self setMasonry];
    [self loadData];
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
    // Dispose of any resources that can be recreated.
}


//  MARK: - <----------Public---------->
//  MARK: - <----------Private---------->
- (void)prepareUserInterface {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.navBar];
    WEAK_SELF(weakSelf);
    self.navBar.leftBlock = ^() {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    // 速度
    [self.view addSubview:self.speedView];
    // 阻尼·
    [self.view addSubview:self.dampView];
    // 时间
    [self.view addSubview:self.timeView];
    // 闭合力
    [self.view addSubview:self.closureView];
    // 自动关门
    [self.view addSubview:self.autoCloseSwitch];
    // 开门方向
    [self.view addSubview:self.openDirectionSwitch];
    
    // 发送
    // 辅助适配线
    UIView *tempLine = [UIView new];
    [self.view addSubview:tempLine];
    [tempLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(1);
        make.height.offset(APPH - 100);
        make.centerX.equalTo(self.view);
    }];
    // 发送
    CGFloat distance = 5;// 两个按键之间的距离/2
    CGFloat topDistance = 20;// 两个按键距离时间滑块距离
    UIButton *sendButton = [UIButton new];
    sendButton.backgroundColor = [UIColor colorWithRed:0.17 green:0.69 blue:0.80 alpha:1.00];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.view addSubview:sendButton];
    sendButton.layer.cornerRadius = 5;
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.right.equalTo(tempLine).offset(-distance * APPP);
        make.top.equalTo(self.openDirectionSwitch.mas_bottom).offset(topDistance * APPP);
    }];
    [sendButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
         weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_REQUEST]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_REQUEST] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
        
    }];
    // 接收
    UIButton *reciveButton = [UIButton new];
    reciveButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [reciveButton setTitle:@"接收" forState:UIControlStateNormal];
    reciveButton.layer.cornerRadius = 5;
    [self.view addSubview:reciveButton];
    [reciveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.left.equalTo(tempLine).offset(distance * APPP);
        make.top.equalTo(self.openDirectionSwitch.mas_bottom).offset(topDistance * APPP);
    }];
    [reciveButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_RECIVE]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_RECIVE] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }];
    // 中间清码按钮
    UIButton *clearButton = [UIButton new];
    clearButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [clearButton setTitle:@"清码" forState:UIControlStateNormal];
    clearButton.layer.cornerRadius = 5;
    [self.view addSubview:clearButton];
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.centerX.equalTo(self.view);
        make.top.equalTo(sendButton.mas_bottom).offset(20);
    }];
    [clearButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_CLEAR]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_CLEAR] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }];
    // 自学习
    UIButton *studyButton = [UIButton new];
    studyButton.backgroundColor = [UIColor colorWithRed:0.17 green:0.69 blue:0.80 alpha:1.00];
    [studyButton setTitle:@"自学习" forState:UIControlStateNormal];
    [self.view addSubview:studyButton];
    studyButton.layer.cornerRadius = 5;
    [studyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.right.equalTo(clearButton.mas_left).offset(-20);
        make.centerY.equalTo(clearButton);
    }];
    [studyButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_STUDY]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_STUDY] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }];
    // 右侧对码按钮
    UIButton *clearButton2 = [UIButton new];
    clearButton2.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [clearButton2 setTitle:@"对码" forState:UIControlStateNormal];
    clearButton2.layer.cornerRadius = 5;
    [self.view addSubview:clearButton2];
    [clearButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.centerY.equalTo(clearButton);
        make.left.equalTo(clearButton.mas_right).offset(20);
    }];
    [clearButton2 handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_PAIR]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_PAIR] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    }];
}
- (void)loadData {
    //初始化数据
    sect = [NSMutableArray arrayWithObjects:@"read value",@"write value",@"desc",@"properties", nil];
    readValueArray = [[NSMutableArray alloc]init];
    descriptors = [[NSMutableArray alloc]init];
    // 配置ble委托
    [self babyDelegate];
    // 读取服务
    if (self.currPeripheral && self.characteristic) {
        baby.channel(channelOnCharacteristicView).characteristicDetails(self.currPeripheral,self.characteristic);
    } else {
        baby.having(self.currPeripheral).and.channel(channelOnCharacteristicView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }
    // 初始化数据值
    speedValue = 0;
    dampValue = 0;
    closureValue = 0;
    timeValue = 0;
}
// 判断是否已经找到符合的特征
- (BOOL)isSuccess {
    if (self.characteristic && self.currPeripheral.state == CBPeripheralStateConnected) {
        return YES;
    } else {
        return NO;
    }
}

- (void)notify {
    if(self.currPeripheral.state != CBPeripheralStateConnected) {
        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    if (self.characteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate) {
        
        if(self.characteristic.isNotifying) {
            [baby cancelNotify:self.currPeripheral characteristic:self.characteristic];
            
        }else{
            [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
            
            [baby notify:self.currPeripheral
          characteristic:self.characteristic
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                       NSLog(@"notify block");
                       NSLog(@"new value %@",characteristics.value);
                       self.reciveLabel.text = [NSString stringWithFormat:@"接收到的数据:%@",characteristics.value];
                   }];
        }
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"这个characteristic没有nofity的权限"];
        return;
    }
    
}

//  MARK: - <----------Slider Delegate---------->
- (void)sliderValueChanged:(NSInteger)value tag:(NSInteger)tag {
    switch (tag) {
        case SliderTagSpeed:
        {
            speedValue = (int)value;
        }
            break;
        case SliderTagDamp:
        {
            dampValue = (int)value;
        }
            break;
        case SliderTagClosure:
        {
            closureValue = (int)value;
        }
            break;
        case SliderTagTime:
        {
            timeValue = (int)value;
        }
            break;
            
        default:
            break;
    }
    [self sendData];
}

- (void)sendData {
    
    if(![self isSuccess]) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    self.autoCloseSwitch.isOn ? (autoCloseValue = 1) : (autoCloseValue = 0);
    self.openDirectionSwitch.isOn ? (openDirectionValue = 1) : (openDirectionValue = 0);
//    NSLog(@"速度:%d缓冲:%d时间:%d闭合:%d",speedValue,dampValue,timeValue,closureValue);
//    NSLog(@"速度:%@缓冲:%@时间:%@闭合:%@",[BLECode ToHex:speedValue],[BLECode ToHex:dampValue],[BLECode ToHex:timeValue],[BLECode ToHex:closureValue]);
    NSString *code = [NSString stringWithFormat:@"55%@%@%@%@%@%@%@",[BLECode ToHex:1],[BLECode ToHex:9],[BLECode ToHex:speedValue],[BLECode ToHex:dampValue],[BLECode ToHex:timeValue],[BLECode ToHex:autoCloseValue + openDirectionValue],[BLECode ToHex:closureValue]];
    self.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:code]];
    if(!self.currPeripheral && !self.characteristic && self.currPeripheral.state != CBPeripheralStateConnected) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    [self.currPeripheral writeValue:[BLECode getCheckSum:code] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
}

-(void)switchAction:(id)sender {
    [self sendData];
}
//  MARK: - <----------Baby Delegate---------->
-(void)babyDelegate{
    
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    [baby setBlockOnConnectedAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnCharacteristicView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
    }];
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            ///插入section到tableview
            //[weakSelf insertSectionToTableView:s];
        }
        
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
        //[weakSelf insertRowToTableView:service];
        
    }];
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
//        CBCharacteristicProperties p = characteristics.properties;
//        if ((p & CBCharacteristicPropertyRead)&&(p & CBCharacteristicPropertyWrite)) {
//            weakSelf.characteristic = characteristics;
//        }
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        if (characteristic.descriptors.count > 0) {
            weakSelf.characteristic = characteristic;
        }
        
    }];

    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnCharacteristicView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        // [weakSelf notify];

        for (int i =0 ; i<descriptors.count; i++) {
            if (descriptors[i]==descriptor) {

            }
        }
        NSLog(@"CharacteristicViewController Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置写数据成功的block
    [baby setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [baby setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnCharacteristicView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
}



//  MARK: - <----------Lazy---------->
- (XHNavView *)navBar {
    if (!_navBar) {
        _navBar = [XHNavView new];
        _navBar.navTitle = @"Demo";
        _navBar.iconName = @"ic_launcher";
        _navBar.leftName = @"back";
    }
    return _navBar;
}

- (BLESliderView *)speedView {
    if (!_speedView) {
        _speedView = [BLESliderView new];
        _speedView.tag = SliderTagSpeed;
        _speedView.delegate = self;
        _speedView.bleMaxValue = 100.0;
        _speedView.tips = @[@"低",@"高"];
        _speedView.sliderTitle = @"速度:";
    }
    return _speedView;
}

- (BLESliderView *)closureView {
    if (!_closureView) {
        _closureView = [BLESliderView new];
        _closureView.tag = SliderTagClosure;
        _closureView.delegate = self;
        _closureView.bleMaxValue = 100.0;
        _closureView.tips = @[@"小",@"大"];
        _closureView.sliderTitle = @"紧闭力:";
    }
    return _closureView;
}

- (BLESliderView *)dampView {
    if (!_dampView) {
        _dampView = [BLESliderView new];
        _dampView.tag = SliderTagDamp;
        _dampView.delegate = self;
        _dampView.bleMaxValue = 100.0;
        _dampView.tips = @[@"小",@"大"];
        _dampView.sliderTitle = @"缓冲:";
    }
    return _dampView;
}

- (BLESliderView *)timeView {
    if (!_timeView) {
        _timeView = [BLESliderView new];
        _timeView.tag = SliderTagTime;
        _timeView.delegate = self;
        _timeView.bleMaxValue = 30.0;
        _timeView.tips = @[@"0",@"30"];
        _timeView.sliderTitle = @"开门时间:";
    }
    return _timeView;
}

- (UISwitch *)autoCloseSwitch {
    if (!_autoCloseSwitch) {
        _autoCloseSwitch = [UISwitch new];
        [_autoCloseSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _autoCloseSwitch;
}

- (UISwitch *)openDirectionSwitch {
    if (!_openDirectionSwitch) {
        _openDirectionSwitch = [UISwitch new];
        [_openDirectionSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _openDirectionSwitch;
}

- (NSArray *)levelArray {
    return @[@"一档",@"二挡",@"三挡",@"四挡",@"五档"];
}

//  MARK: - <----------Masonry---------->

- (void)setMasonry {
    // 导航
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.height.offset(64);
        make.top.left.right.equalTo(self.view);
    }];
    
    // 速度
    [self.speedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(70);
        make.height.offset(60 * APPP);
    }];
    // 阻尼/缓冲
    [self.dampView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.speedView.mas_bottom).offset(5);
        make.height.offset(60 * APPP);
    }];
    
    // 时间滑块
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.closureView.mas_bottom).offset(5);
        make.height.offset(60 * APPP);
    }];
    // 闭合力
    [self.closureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.dampView.mas_bottom).offset(5);
        make.height.offset(60 * APPP);
    }];
    // 自动关门
    [self.autoCloseSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-30 * APPP);
        make.top.equalTo(self.timeView.mas_bottom).offset(5);
    }];
    UILabel *autoLabel = [UILabel new];
    autoLabel.text = @"自动关门";
    [self.view addSubview:autoLabel];
    [autoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.autoCloseSwitch);
        make.left.equalTo(self.view.mas_left).offset(30);
    }];
    
    // 开门方向
    [self.openDirectionSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-30 * APPP);
        make.top.equalTo(self.autoCloseSwitch.mas_bottom).offset(20);
    }];
    UILabel *openDirection = [UILabel new];
    openDirection.text = @"开门方向";
    [self.view addSubview:openDirection];
    [openDirection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.openDirectionSwitch);
        make.left.equalTo(self.view.mas_left).offset(30);
    }];

    
}


@end
