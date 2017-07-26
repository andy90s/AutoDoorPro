//
//  BLESliderView.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/3/20.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASValueTrackingSlider;

@protocol BLESliderViewDelegate <NSObject>

@optional

- (void)sliderValueChanged:(NSNumberFormatter*)value tag:(NSInteger)tag value:(CGFloat)cvalue ;

@end

@interface BLESliderView : UIView

@property (weak, nonatomic) id <BLESliderViewDelegate> delegate;
/** 滑块标题*/
@property (nonatomic,copy) NSString *sliderTitle;
/** 左右提示*/
@property (nonatomic,copy) NSArray *tips;
/** 最大值*/
@property (nonatomic,assign) CGFloat bleMaxValue;
/** 设置当前值*/
@property (nonatomic,assign) NSInteger currentValue;
@end
