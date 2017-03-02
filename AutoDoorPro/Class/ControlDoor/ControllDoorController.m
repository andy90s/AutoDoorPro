//
//  ControllDoorController.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "ControllDoorController.h"
#import "SettingsController.h"

@interface ControllDoorController ()

/** 假导航*/
@property (nonatomic,strong) XHNavView *navBar;

@end

@implementation ControllDoorController
//  MARK: - <----------LifyCycle---------->
- (void)viewDidLoad {
    [super viewDidLoad];
    [self preparUserInterface];
    [self setMasonry];
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
    WEAK_SELF(weakSelf);
    self.navBar.leftBlock = ^() {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    self.navBar.rightBlock = ^() {
        [weakSelf.navigationController pushViewController:[SettingsController new] animated:YES];
    };
}

//  MARK: - <----------Lazy---------->
- (XHNavView *)navBar {
    if (!_navBar) {
        _navBar = [XHNavView new];
        _navBar.navTitle = @"Demo";
        _navBar.iconName = @"brandIcon";
        _navBar.rightTitle = @"设置";
        _navBar.leftName = @"back";
    }
    return _navBar;
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
    // 开门
    CGFloat distance = 5;// 两个按键之间的距离/2
    CGFloat topDistance = 100;// 两个按键距离顶部距离
    UIButton *openButton = [UIButton new];
    openButton.backgroundColor = [UIColor colorWithRed:0.28 green:0.61 blue:0.29 alpha:1.00];
    [openButton setTitle:@"开门" forState:UIControlStateNormal];
    openButton.layer.cornerRadius = 5;
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
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(80 * APPP);
        make.height.offset(40 * APPP);
        make.left.equalTo(tempLine).offset(distance * APPP);
        make.top.equalTo(self.view.mas_top).offset(topDistance * APPP);
    }];
    
    // 导航
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(APPW);
        make.height.offset(64);
        make.top.left.right.equalTo(self.view);
    }];
}



@end
