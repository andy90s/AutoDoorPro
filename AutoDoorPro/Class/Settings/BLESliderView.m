//
//  BLESliderView.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/3/20.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "BLESliderView.h"
#import "ASValueTrackingSlider.h"

@interface BLESliderView()

@property(nonatomic,strong) ASValueTrackingSlider *bleSlider;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) UILabel *leftLab;
@property (nonatomic,strong) UILabel *rightLab;

@end

@implementation BLESliderView

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
//  MARK: - <----------CommonInit---------->

- (void)commonInit {
    [self addSubview:self.titleLab];
    [self addSubview:self.leftLab];
    [self addSubview:self.rightLab];
    [self addSubview:self.bleSlider];
    [self setMasonry];
}

- (void)setMasonry {
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20 * APPP);
//        make.height.offset(20 * APPP);
        make.top.equalTo(self.mas_top).offset(3 * APPP);
    }];
    [self.bleSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20 * APPP);
        make.height.offset(30 * APPP);
        make.width.offset(APPW - 40 * APPP);
        make.centerY.equalTo(self);
    }];
    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20 * APPP);
        make.bottom.equalTo(self.mas_bottom).offset(-3 * APPP);
    }];
    [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-20 * APPP);
        make.centerY.equalTo(self.leftLab);
    }];
}

//  MARK: - <----------Accosse---------->

- (void)setBleMaxValue:(CGFloat)bleMaxValue {
    _bleMaxValue = bleMaxValue;
    self.bleSlider.maximumValue = _bleMaxValue;
}

- (void)setTips:(NSArray *)tips {
    if (tips.count<2) {
        return;
    }
    self.leftLab.text = tips[0];
    self.rightLab.text = tips[1];
}

- (void)setSliderTitle:(NSString *)sliderTitle {
    _sliderTitle = sliderTitle;
    self.titleLab.text = _sliderTitle;
}

//- (void)setTag:(NSInteger)tag {
//    self.tag
//}

//  MARK: - <----------Private---------->
- (void)sliderValueChanged:(ASValueTrackingSlider *)sender {
    if ([self.delegate respondsToSelector:@selector(sliderValueChanged: tag:)]) {
        [self.delegate sliderValueChanged:sender.value tag:self.tag];
    }
}

//  MARK: - <----------Lazy---------->

- (ASValueTrackingSlider *)bleSlider {
    if (!_bleSlider) {
        _bleSlider = [[ASValueTrackingSlider alloc]initWithFrame:CGRectMake(20 * APPP, 20, APPW - 40, 30)];
        [_bleSlider setMaxFractionDigitsDisplayed:0];
        _bleSlider.continuous = NO;
        [_bleSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _bleSlider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
        _bleSlider.font = [UIFont fontWithName:@"Menlo-Bold" size:22];
        _bleSlider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    }
    return _bleSlider;
}
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
    }
    return _titleLab;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [UILabel new];
        _leftLab.textColor = [UIColor lightGrayColor];
    }
    return _leftLab;
}

- (UILabel *)rightLab {
    if (!_rightLab) {
        _rightLab = [UILabel new];
        _rightLab.textColor = [UIColor lightGrayColor];
    }
    return _rightLab;
}


@end
