//
//  XHNavView.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "XHNavView.h"

@interface XHNavView()

@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UIButton *leftButton;
@property (nonatomic,strong) UIButton *rightButton;
@property (nonatomic,strong) UIImageView *icon;
@end

@implementation XHNavView

//  MARK: - <----------Init---------->
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}



- (instancetype)init {
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}
//  MARK: - <----------Private---------->
// Actions
- (void)rightButtonClick {
    if (_rightBlock) {
        _rightBlock();
    }
}

- (void)leftButtonClick {
    if (_leftBlock) {
        _leftBlock();
    }
}


//  MARK: - <----------Accosses---------->
- (void)setIconName:(NSString *)iconName {
    _iconName = iconName;
    self.icon.image = [UIImage imageNamed:iconName];
}

- (void)setLeftName:(NSString *)leftName {
    [self.leftButton setImage:[UIImage imageNamed:leftName] forState:UIControlStateNormal];
}

- (void)setRightName:(NSString *)rightName {
    [self.rightButton setImage:[UIImage imageNamed:rightName] forState:UIControlStateNormal];
}

- (void)setRightTitle:(NSString *)rightTitle {
    [self.rightButton setTitle:rightTitle forState:UIControlStateNormal];
}

- (void)setNavTitle:(NSString *)navTitle {
    self.titleLab.text = navTitle;
}

//  MARK: - <----------CommonInit---------->

- (void)commonInit {
    self.backgroundColor = [UIColor colorWithRed:0.44 green:0.72 blue:0.22 alpha:1.00];
    // 标题
    
    [self addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
    // 右侧按键
    [self addSubview:self.rightButton];
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(40);
        make.centerY.equalTo(self.titleLab);
        make.right.equalTo(self.mas_right).offset(-20);
    }];
#if 1
    // icon图标
    [self addSubview:self.icon];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(35);
        make.centerY.equalTo(self.titleLab);
        make.right.equalTo(self.titleLab.mas_left).offset(-5);
    }];
#elif 0
    
#endif
    // 左侧按键

    [self addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(40);
        make.centerY.equalTo(self.titleLab);
        make.left.equalTo(self.mas_left).offset(20);
    }];
}

//  MARK: - <----------lazy---------->
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
        _titleLab.textColor = [UIColor whiteColor];

    }
    return _titleLab;
}
- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton new];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}
- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton =  [UIButton new];
        [_leftButton addTarget:self action:@selector(leftButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView new];
    }
    return _icon;
}

@end
