//
//  ViewController.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "ViewController.h"
#import "ControllDoorController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
/** 列表*/
@property (nonatomic,strong) UITableView *myTableView;
/** 数据*/
@property (nonatomic,strong) NSMutableArray *peripheralDataArr;
/** 蓝牙管理者*/
@property (nonatomic,strong) BabyBluetooth *baby;
/** 假导航*/
@property (nonatomic,strong) XHNavView *navBar;

@end

@implementation ViewController

//  MARK: - <----------LifyCycle---------->

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUserInterface];
    [self setMasonry];
    [self prepareData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 停止之前的链接
    [self.baby cancelAllPeripheralsConnection];
    // 设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
    self.baby.scanForPeripherals().begin();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//  MARK: - <----------Public---------->

//  MARK: - <----------Private---------->

- (void)prepareUserInterface {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.navBar];
    [self.view addSubview:self.myTableView];
    WEAK_SELF(weakSelf);
    self.navBar.rightBlock = ^() {
        [weakSelf refreshData];
    };
}

- (void)prepareData {
    // 设置代理初始化
    [self babyDelegate];
}
// 刷新
- (void)refreshData {
    [self.baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    self.baby.scanForPeripherals().begin();
}

//  MARK: - <----------TableViewDelegate---------->

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%ld",(unsigned long)self.peripheralDataArr.count);
    return self.peripheralDataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50 * APPP;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    NSDictionary *item = self.peripheralDataArr[indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    NSDictionary *advertisementData = [item objectForKey:@"advertisementData"];
    NSNumber *RSSI = [item objectForKey:@"RSSI"];
    NSString *peripheralName;
    if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
        peripheralName = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
        peripheralName = peripheral.name;
    }else{
        peripheralName = [peripheral.identifier UUIDString];
    }
    
    cell.textLabel.text = peripheralName;
    // 信号和服务 mac
    
    // cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];
    cell.detailTextLabel.text = [item objectForKey:@"device_mac"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    WEAK_SELF(weakSelf);
    
    [self.baby cancelScan];
    ControllDoorController *vc = [ControllDoorController new];
    NSDictionary *item = self.peripheralDataArr[indexPath.row];
    CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
    vc.currPeripheral = peripheral;
    vc->baby = self->_baby;
    [self.navigationController pushViewController:vc animated:YES];
    
    // FIXME: 暂时干掉了
    
//    // 输入密码
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入密码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UITextField *textField = alertController.textFields.firstObject;
//        if ([textField.text isEqualToString:@"888888"]) {
//            // 停止扫描
//            [weakSelf.baby cancelScan];
//            [weakSelf.myTableView deselectRowAtIndexPath:indexPath animated:YES];
//            ControllDoorController *vc = [ControllDoorController new];
//            NSDictionary *item = weakSelf.peripheralDataArr[indexPath.row];
//            CBPeripheral *peripheral = [item objectForKey:@"peripheral"];
//            vc.currPeripheral = peripheral;
//            vc->baby = self->_baby;
//            [weakSelf.navigationController pushViewController:vc animated:YES];
//        } else {
//            [SVProgressHUD showErrorWithStatus:@"密码错误"];
//        }
//    }];
//    
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//    }];
//    [alertController addAction:cancelAction];
//    [alertController addAction:okAction];
//    [self presentViewController:alertController animated:YES completion:^{
//        
//    }];
    
    
}

//  MARK: - <----------BluetoothDelegate---------->
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [self.baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    [self.baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSData *data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
        NSString *mac = [[NSMutableString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        mac = [mac stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"搜索到了设备:%@,MAC:%@",peripheral.name,mac);
        
        [weakSelf insertTableView:peripheral advertisementData:advertisementData RSSI:RSSI MAC:mac];
    }];
    
    
    //设置发现设service的Characteristics的委托
    [self.baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [self.baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [self.baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [self.baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    
    //设置查找设备的过滤器 此处暂时未定规则
    [self.baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        //最常用的场景是查找某一个前缀开头的设备
        //        if ([peripheralName hasPrefix:@"Pxxxx"] ) {
        //            return YES;
        //        }
        //        return NO;
        
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
        if (peripheralName.length >= 0) {
            return YES;
        }
        return NO;
    }];
    
    
    [self.baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [self.baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    
    /*设置babyOptions
     
     参数分别使用在下面这几个地方，若不使用参数则传nil
     - [centralManager scanForPeripheralsWithServices:scanForPeripheralsWithServices options:scanForPeripheralsWithOptions];
     - [centralManager connectPeripheral:peripheral options:connectPeripheralWithOptions];
     - [peripheral discoverServices:discoverWithServices];
     - [peripheral discoverCharacteristics:discoverWithCharacteristics forService:service];
     
     该方法支持channel版本:
     [baby setBabyOptionsAtChannel:<#(NSString *)#> scanForPeripheralsWithOptions:<#(NSDictionary *)#> connectPeripheralWithOptions:<#(NSDictionary *)#> scanForPeripheralsWithServices:<#(NSArray *)#> discoverWithServices:<#(NSArray *)#> discoverWithCharacteristics:<#(NSArray *)#>]
     */
    
    //示例:
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [self.baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    
}

#pragma mark -UIViewController 方法
// 插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI MAC:(NSString *)mac {
    NSArray *peripherals = [self.peripheralDataArr valueForKey:@"peripheral"];
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setValue:peripheral forKey:@"peripheral"];
        [item setValue:RSSI forKey:@"RSSI"];
        [item setValue:advertisementData forKey:@"advertisementData"];
        [item setValue:mac forKey:@"device_mac"];
        [self.peripheralDataArr  addObject:item];
        
        [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}



//  MARK: - <----------Lazy---------->

- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, APPW, APPH - 64) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.tableFooterView = [UIView new];
        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _myTableView;
}

- (BabyBluetooth *)baby {
    if (!_baby) {
        _baby = [BabyBluetooth shareBabyBluetooth];
    }
    return _baby;
}

- (NSMutableArray *)peripheralDataArr {
    if (!_peripheralDataArr) {
        _peripheralDataArr = [NSMutableArray new];
    }
    return _peripheralDataArr;
}

- (XHNavView *)navBar {
    if (!_navBar) {
        _navBar = [XHNavView new];
        _navBar.navTitle = @"Demo";
        _navBar.iconName = @"ic_launcher";
        _navBar.rightTitle = @"刷新";
    }
    return _navBar;
}

//  MARK: - <----------Masonry---------->

- (void)setMasonry {
    // 导航
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.height.offset(64);
        make.top.left.right.equalTo(self.view);
    }];

}

@end
