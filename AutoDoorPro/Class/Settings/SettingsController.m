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

@interface SettingsController ()

/** 假导航*/
@property (nonatomic,strong) XHNavView *navBar;
/** 速度滑条*/
@property(nonatomic,strong) SEFilterControl *speedSlider;
/** 阻尼滑条*/
@property (nonatomic,strong) SEFilterControl *dampSlider;
/** 开门时间滑条*/
@property (nonatomic,strong) ASValueTrackingSlider *timeSlider;

@end

@implementation SettingsController

//  MARK: - <----------LifyCycle---------->
- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUserInterface];
    [self setMasonry];
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
    [self.view addSubview:self.speedSlider];
    // 阻尼·
    [self.view addSubview:self.dampSlider];
    // 时间
    [self.view addSubview:self.timeSlider];
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
        make.top.equalTo(self.timeSlider.mas_bottom).offset(topDistance * APPP);
    }];
    [sendButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        
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
        make.top.equalTo(self.timeSlider.mas_bottom).offset(topDistance * APPP);
    }];
    [reciveButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        
    }];
    // 中间清码按钮
    UIButton *clearButton = [UIButton new];
    clearButton.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [clearButton setTitle:@"遥控器清码" forState:UIControlStateNormal];
    clearButton.layer.cornerRadius = 5;
    [self.view addSubview:clearButton];
    [clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.centerX.equalTo(self.view);
        make.top.equalTo(sendButton.mas_bottom).offset(20);
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
    // 右侧清码按钮
    UIButton *clearButton2 = [UIButton new];
    clearButton2.backgroundColor = [UIColor colorWithRed:0.78 green:0.20 blue:0.20 alpha:1.00];
    [clearButton2 setTitle:@"遥控器清码" forState:UIControlStateNormal];
    clearButton2.layer.cornerRadius = 5;
    [self.view addSubview:clearButton2];
    [clearButton2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.centerY.equalTo(clearButton);
        make.left.equalTo(clearButton.mas_right).offset(20);
    }];
}
- (void)speedValueChanged:(SEFilterControl *)sender
{
    NSLog(@"当前滑块位置%d",sender.SelectedIndex);
    switch (sender.SelectedIndex) {
        case 0: {
            
        }
            break;
        case 1: {
            
        }
            break;
        case 2: {
        }
            break;
        case 3: {
            
        }
            break;
        case 4: {
            
        }
            break;
        default:
            break;
    }
}

- (void)dampValueChanged:(SEFilterControl *)sender
{
    NSLog(@"当前滑块位置%d",sender.SelectedIndex);
    switch (sender.SelectedIndex) {
        case 0: {
            
        }
            break;
        case 1: {
            
        }
            break;
        case 2: {
        }
            break;
        case 3: {
            
        }
            break;
        case 4: {
            
        }
            break;
        default:
            break;
    }
}

- (void)timeValueChanged:(ASValueTrackingSlider *)slider {
    NSLog(@"当前时间:%f",slider.value);
}


//  MARK: - <----------Lazy---------->
- (XHNavView *)navBar {
    if (!_navBar) {
        _navBar = [XHNavView new];
        _navBar.navTitle = @"Demo";
        _navBar.iconName = @"brandIcon";
        _navBar.leftName = @"back";
    }
    return _navBar;
}

- (SEFilterControl *)speedSlider {
    if (!_speedSlider) {
        _speedSlider = [[SEFilterControl alloc]initWithFrame:CGRectMake(60, 80, APPW - 60, 60) Titles:[self levelArray]];
        [_speedSlider addTarget:self action:@selector(speedValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_speedSlider setProgressColor:[UIColor groupTableViewBackgroundColor]];//设置滑杆的颜色
        [_speedSlider setTopTitlesColor:[UIColor orangeColor]];//设置滑块上方字体颜色
        [_speedSlider setSelectedIndex:0];//设置当前选中
    }
    return _speedSlider;
}

- (SEFilterControl *)dampSlider {
    if (!_dampSlider) {
        _dampSlider = [[SEFilterControl alloc]initWithFrame:CGRectMake(60, 150, APPW - 60, 60) Titles:[self levelArray]];
        [_dampSlider addTarget:self action:@selector(dampValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_dampSlider setProgressColor:[UIColor groupTableViewBackgroundColor]];//设置滑杆的颜色
        [_dampSlider setTopTitlesColor:[UIColor orangeColor]];//设置滑块上方字体颜色
        [_dampSlider setSelectedIndex:0];//设置当前选中
    }
    return _dampSlider;
}

- (ASValueTrackingSlider *)timeSlider {
    if (!_timeSlider) {
        _timeSlider = [ASValueTrackingSlider new];
        _timeSlider.maximumValue = 30.0;
        [_timeSlider setMaxFractionDigitsDisplayed:0];
        [_timeSlider addTarget:self action:@selector(timeValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        _timeSlider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        _timeSlider.font = [UIFont fontWithName:@"Menlo-Bold" size:22];
        _timeSlider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
        
    }
    return _timeSlider;
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
    // 时间滑块
    [self.timeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW - 120);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.top.equalTo(self.dampSlider.mas_bottom).offset(20);
    }];
    // 3个标签
    // 1.速度
    UILabel *speedLabel = [UILabel new];
    speedLabel.text = @"速度:";
    [self.view addSubview:speedLabel];
    [speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.speedSlider);
        make.left.equalTo(self.view.mas_left).offset(5);
    }];
    // 2.阻尼
    UILabel *dampLabel = [UILabel new];
    dampLabel.text = @"阻尼:";
    [self.view addSubview:dampLabel];
    [dampLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.dampSlider);
        make.left.equalTo(self.view.mas_left).offset(5);
    }];
    // 3.开门时间
    UILabel *timeLabel = [UILabel new];
    timeLabel.text = @"开门时间:";
    [self.view addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.timeSlider);
        make.left.equalTo(self.view.mas_left).offset(5);
    }];
}


@end
