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
#import "ADRadioButton.h"

#define channelOnCharacteristicView @"CharacteristicView"

BOOL isPopSettingViewController = NO;

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
    int specByte1;
    int specByte2;
    NSString *specBytes;
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
/** 工作模式 */
@property (nonatomic,strong) ADRadioButton *radioButtons;



// 测试用 控件
@property (nonatomic,strong) UIView *testView;
@property (nonatomic,strong) UILabel *sendLabel;
@property (nonatomic,strong) UILabel *reciveLabel;
@end

@implementation SettingsController

//  MARK: - <----------LifyCycle---------->

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getStauts];
}

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
    weakify(self);
    self.navBar.leftBlock = ^() {
        strongify(self);
        isPopSettingViewController = YES;
        [self->baby cancelNotify:weakSelf.currPeripheral characteristic:weakSelf.notifyCharacteristic];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    // 速度
    [self.view addSubview:self.speedView];
    // 阻尼· 暂时去掉
    //[self.view addSubview:self.dampView];
    // 时间
    [self.view addSubview:self.timeView];
    
    // 工作模式
    
    [self.view addSubview:self.radioButtons];
    self.radioButtons.block = ^(NSInteger index) {
        strongify(self);
        switch (index) {
            case 0:
            {
                specBytes = @"00";
                [self sendData];
            }
                break;
            case 1:
            {
                specBytes = @"01";
                [self sendData];
            }
                break;
            case 2:
            {
                specBytes = @"10";
                [self sendData];
            }
                break;
                
            default:
                break;
            
        }
        
    };
    
    
    // 闭合力
    // [self.view addSubview:self.closureView];
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
    
    CGFloat distance = 5;// 两个按键之间的距离/2
    CGFloat topDistance = 20;// 两个按键距离时间滑块距离
    
    // 接收
//    UIButton *reciveButton = [UIButton new];
//    reciveButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
//    [reciveButton setTitle:@"接收" forState:UIControlStateNormal];
//    reciveButton.layer.cornerRadius = 5;
//    [self.view addSubview:reciveButton];
//    [reciveButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.offset(80 * APPP);
//        make.height.offset(35 * APPP);
//        make.left.equalTo(tempLine).offset(distance * APPP);
//        make.top.equalTo(self.openDirectionSwitch.mas_bottom).offset(topDistance * APPP);
//    }];
//    [reciveButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
//        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_RECIVE]];
//        if(![weakSelf isSuccess]) {
//            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
//            return;
//        }
//        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_RECIVE] forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
//    }];
    // 中间清码按钮
    UIButton *clearButton = [UIButton new];
    clearButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [clearButton setTitle:@"清码" forState:UIControlStateNormal];
    clearButton.layer.cornerRadius = 5;
    [self.view addSubview:clearButton];
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(35 * APPP);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.openDirectionSwitch.mas_bottom).offset(topDistance * APPP);
    }];
    [clearButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_CLEAR]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_CLEAR] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }];
    // 自学习
    UIButton *studyButton = [UIButton new];
    studyButton.backgroundColor = [UIColor colorWithRed:0.17 green:0.69 blue:0.80 alpha:1.00];
    [studyButton setTitle:@"自学习" forState:UIControlStateNormal];
    [self.view addSubview:studyButton];
    studyButton.layer.cornerRadius = 5;
    [studyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(35 * APPP);
        make.right.equalTo(clearButton.mas_left).offset(-20);
        make.centerY.equalTo(clearButton);
    }];
    [studyButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_STUDY]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_STUDY] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }];
    // 右侧对码按钮
    UIButton *clearButton2 = [UIButton new];
    clearButton2.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [clearButton2 setTitle:@"对码" forState:UIControlStateNormal];
    clearButton2.layer.cornerRadius = 5;
    [self.view addSubview:clearButton2];
    [clearButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(35 * APPP);
        make.centerY.equalTo(clearButton);
        make.left.equalTo(clearButton.mas_right).offset(20);
    }];
    [clearButton2 handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_PAIR]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_PAIR] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }];
    
    
    // 重启
    
    UIButton *sendButton = [UIButton new];
    sendButton.backgroundColor = [UIColor colorWithRed:0.17 green:0.69 blue:0.80 alpha:1.00];
    [sendButton setTitle:@"重启" forState:UIControlStateNormal];
    [self.view addSubview:sendButton];
    sendButton.layer.cornerRadius = 5;
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(35 * APPP);
        make.width.offset(100 * APPP);
        make.right.equalTo(tempLine).offset(-distance * APPP);
        make.top.equalTo(clearButton.mas_bottom).offset(20);
    }];
    [sendButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_RESET]];
        if(![weakSelf isSuccess]) {
            [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
            return;
        }
        [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_RESET] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }];
    
    // 恢复出厂设置
    UIButton *resetButton = [UIButton new];
    resetButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [resetButton setTitle:@"恢复出厂设置" forState:UIControlStateNormal];
    resetButton.layer.cornerRadius = 5;
    [self.view addSubview:resetButton];
    [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(35 * APPP);
        make.width.offset(100 * APPP);
        make.left.equalTo(tempLine).offset(distance * APPP);
        make.top.equalTo(clearButton.mas_bottom).offset(20);
    }];
    [resetButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        // 输入密码
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入密码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alertController.textFields.firstObject;
            if ([textField.text isEqualToString:@"666666"]) {
                //
                weakSelf.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:BLE_ORDER_FACTORY_RESET]];
                if(![weakSelf isSuccess]) {
                    [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
                    return;
                }
                
                [weakSelf.currPeripheral writeValue:[BLECode getCheckSum:BLE_ORDER_FACTORY_RESET] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
            } else {
                [SVProgressHUD showErrorWithStatus:@"密码错误"];
            }
        }];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:^{
            
        }];
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
    if (self.currPeripheral && self.writeCharacteristic) {
        baby.channel(channelOnCharacteristicView).characteristicDetails(self.currPeripheral,self.writeCharacteristic);
    } else {
        baby.having(self.currPeripheral).and.channel(channelOnCharacteristicView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
    }
    // 初始化数据值
    speedValue = 30;
    dampValue = 80;
    closureValue = 10;
    timeValue = 7;
    specByte1 = 0;
    specByte2 = 0;
    [self notify];
}
// 判断是否已经找到符合的特征
- (BOOL)isSuccess {
    if (self.currPeripheral.state == CBPeripheralStateConnected) {
        return YES;
    } else {
        return NO;
    }
}
// 数据监听
- (void)notify {
    
    WEAK_SELF(weakSelf);
    if(self.currPeripheral.state != CBPeripheralStateConnected) {
        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    
    [baby notify:self.currPeripheral
  characteristic:self.notifyCharacteristic
           block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
               NSLog(@"notify block");
               NSLog(@"new value %@",characteristics.value);
               weakSelf.reciveLabel.text = [NSString stringWithFormat:@"接收到的数据:%@",characteristics.value.description];
               NSString *value = [BLECode hexadecimalString:characteristics.value];
               // 状态
               if ([value hasPrefix:@"5501"]) {
                   [weakSelf updateStatus:value];
               }
               
           }];

//    if (self.notifyCharacteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate) {
//        WEAK_SELF(weakSelf);
//        if(self.characteristic.isNotifying) {
//            [baby notify:self.currPeripheral
//          characteristic:self.characteristic
//                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//                       NSLog(@"notify block");
//                       NSLog(@"new value %@",characteristics.value);
//                       weakSelf.reciveLabel.text = [NSString stringWithFormat:@"接收到的数据:%@",characteristics.value.description];
//                       NSString *value = [BLECode hexadecimalString:characteristics.value];
//                       // 状态
//                       if ([value hasPrefix:@"5501"]) {
//                           [weakSelf updateStatus:value];
//                       }
//                       
//                   }];
//
//
//        }else{
//            [self.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
//            
//                   }
//    }
//    else{
//        //[SVProgressHUD showErrorWithStatus:@"这个characteristic没有nofity的权限"];
//        return;
//    }
    
}

// 更新状态
- (void)updateStatus:(NSString *)value {
    
    NSLog(@"返回的速度:%ld,阻尼:%ld,开门时间:%ld,紧闭力:%ld,自动:%@",[BLETool speed:value],[BLETool damp:value],[BLETool openTime:value],[BLETool closure:value],[BLETool switchStatus:value]);
    self.speedView.currentValue = [BLETool speed:value];
    self.dampView.currentValue = [BLETool damp:value];
    self.timeView.currentValue = [BLETool openTime:value];
    self.closureView.currentValue = [BLETool closure:value];
    
    NSString *binaryStr = [BLETool getSpecStatus:value];
    NSString *value1 = [binaryStr substringWithRange:NSMakeRange(0, 2)];
    NSString *value3 = [binaryStr substringWithRange:NSMakeRange(2, 1)];
    NSString *value4 = [binaryStr substringWithRange:NSMakeRange(3, 1)];
    
    if ([value1 isEqualToString:@"00"]) {
        self.radioButtons.selectedIndex = 0;
    }
    if ([value1 isEqualToString:@"01"]) {
        self.radioButtons.selectedIndex = 1;
    }
    if ([value1 isEqualToString:@"10"]) {
        self.radioButtons.selectedIndex = 2;
    }
    
    [self.autoCloseSwitch setOn:[value3 isEqualToString:@"1"]];
    [self.openDirectionSwitch setOn:[value4 isEqualToString:@"1"]];

//    if ([[BLETool switchStatus:value] isEqualToString:@"0"]) {
//        [self.autoCloseSwitch setOn:NO];
//        [self.openDirectionSwitch setOn:NO];
//    }
//    if ([[BLETool switchStatus:value] isEqualToString:@"1"]) {
//        [self.autoCloseSwitch setOn:YES];
//        [self.openDirectionSwitch setOn:NO];
//    }
//    if ([[BLETool switchStatus:value] isEqualToString:@"2"]) {
//        [self.autoCloseSwitch setOn:NO];
//        [self.openDirectionSwitch setOn:YES];
//    }
//    if ([[BLETool switchStatus:value] isEqualToString:@"3"]) {
//        [self.autoCloseSwitch setOn:YES];
//        [self.openDirectionSwitch setOn:YES];
//    }
}

// 获取状态
- (void)getStauts {
    self.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode hexToBytes:BLE_ORDER_GETSTATUS]];
    if (![self isSuccess]) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    [self.currPeripheral writeValue:[BLECode hexToBytes:BLE_ORDER_GETSTATUS] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    //[self notify];
}

//  MARK: - <----------Slider Delegate---------->
- (void)sliderValueChanged:(NSNumberFormatter*)value tag:(NSInteger)tag value:(CGFloat)cvalue
{
    NSString *result = [value stringFromNumber:@(cvalue)];
    switch (tag) {
        case SliderTagSpeed:
        {
            speedValue = (int)result.integerValue;
        }
            break;
        case SliderTagDamp:
        {
            dampValue = (int)result.integerValue;
        }
            break;
        case SliderTagClosure:
        {
            closureValue = (int)result.integerValue;
        }
            break;
        case SliderTagTime:
        {
            timeValue = (int)result.integerValue;
        }
            break;
            
        default:
            break;
    }
    [self sendData];
}

- (void)specialData {
    
}

- (void)sendData {
    
    if(![self isSuccess]) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    self.autoCloseSwitch.isOn ? (autoCloseValue = 1) : (autoCloseValue = 0);
    self.openDirectionSwitch.isOn ? (openDirectionValue = 1) : (openDirectionValue = 0);
    
    // 特殊位拼接字符串
    NSString *spec = [NSString stringWithFormat:@"%@%d%d",specBytes,autoCloseValue,openDirectionValue];
    //NSData *data = [[NSData alloc]initWithBase64EncodedString:sepc options:NSUTF8StringEncoding];
    NSLog(@"======= %@",[BLECode getBinaryByhex:nil binary:spec]);
    
    
   
//    NSInteger v = 0;
//    if (autoCloseValue == 0 && openDirectionValue == 0) {
//        v = 0;
//    } else if (autoCloseValue == 1 && openDirectionValue == 0) {
//        v = 1;
//    } else if (autoCloseValue == 0 && openDirectionValue == 1) {
//        v = 2;
//    } else if (autoCloseValue == 1 && openDirectionValue == 1) {
//        v = 3;
//    }
//    NSLog(@"速度:%d缓冲:%d时间:%d闭合:%d 特殊:%ld",speedValue,dampValue,timeValue,closureValue,(long)v);
    
//    NSLog(@"速度:%@缓冲:%@时间:%@闭合:%@ 特殊:%@",[BLECode ToHex:speedValue],[BLECode ToHex:dampValue],[BLECode ToHex:timeValue],[BLECode ToHex: ],[BLECode ToHex:(int)[BLECode toDecimalWithBinary:spec].integerValue]);
    
    // [BLECode ToHex:dampValue]
    
    
    NSString *code = [NSString stringWithFormat:@"55%@%@%@%@%@%@%@",[BLECode ToHex:1],[BLECode ToHex:9],[BLECode ToHex:speedValue],[BLECode ToHex:dampValue],[BLECode ToHex:timeValue],[BLECode ToHex:(int)[BLECode toDecimalWithBinary:spec].integerValue],[BLECode ToHex:closureValue]];
    self.sendLabel.text = [NSString stringWithFormat:@"发送指令:%@",[BLECode getCheckSum:code]];
    if(!self.currPeripheral && !self.writeCharacteristic && self.currPeripheral.state != CBPeripheralStateConnected) {
        [SVProgressHUD showErrorWithStatus:@"已经断开连接或者链接不匹配"];
        return;
    }
    [self.currPeripheral writeValue:[BLECode getCheckSum:code] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    
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
        
        // 写入的特征值
        
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF6"]) {
            if (!weakSelf.writeCharacteristic) {
                if (characteristic.properties & CBCharacteristicPropertyWrite) {
                    weakSelf.writeCharacteristic = characteristic;
                    [weakSelf getStauts];
                }
            }
        }
        // 通知的特征值
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF7"]) {
            
            if (!weakSelf.notifyCharacteristic) {
                weakSelf.notifyCharacteristic = characteristic;
                [weakSelf notify];
            }
            
        }
        
//        if (characteristic.properties & CBCharacteristicPropertyRead) {
//            if (characteristic.properties & CBCharacteristicPropertyWrite) {
//                if (characteristic.properties & CBCharacteristicPropertyNotify) {
//                    weakSelf.notifyCharacteristic = characteristic;
//                    [weakSelf notify];
//                    [weakSelf getStauts];
//                }
//            }
//        }
//        if (characteristic.properties & CBCharacteristicPropertyNotify || characteristic.properties & CBCharacteristicPropertyIndicate) {
//            weakSelf.characteristic = characteristic;
//            [weakSelf notify];
//            [weakSelf getStauts];
//        }
        
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
        [SVProgressHUD showInfoWithStatus:@"写入成功!"];
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

- (ADRadioButton *)radioButtons {
    if (!_radioButtons) {
        _radioButtons = [[ADRadioButton alloc]initWithFrame:CGRectMake(0, 0, APPW - (40 * APPP), 40 * APPP)];
        _radioButtons.rowCount = 3;
        _radioButtons.buttonSettings = @[@[@"独立",@"2"],@[@"联动",@"2"],@[@"接力",@"2"]];
    }
    return _radioButtons;
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
//    [self.dampView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.offset(APPW);
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.speedView.mas_bottom).offset(5);
//        make.height.offset(60 * APPP);
//    }];
    
    // 时间滑块
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.speedView.mas_bottom).offset(5);
        make.height.offset(60 * APPP);
    }];
    
    UILabel *tempLab = [UILabel new];
    tempLab.text = @"工作模式";
    [self.view addSubview:tempLab];
    [tempLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20 * APPP);
        make.top.equalTo(self.timeView.mas_bottom).offset(5);
        make.height.offset(20 * APPP);
    }];
    
    
    [self.radioButtons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW - (40 * APPP));
        make.centerX.equalTo(self.view);
        make.top.equalTo(tempLab.mas_bottom);
        make.height.offset(40 * APPP);
    }];
    // 闭合力
//    [self.closureView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.offset(APPW);
//        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.dampView.mas_bottom).offset(5);
//        make.height.offset(60 * APPP);
//    }];
    // 自动关门
    [self.autoCloseSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-30 * APPP);
        make.top.equalTo(self.radioButtons.mas_bottom).offset(5);
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
