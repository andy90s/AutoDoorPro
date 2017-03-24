//
//  XHNavView.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XHNavView;

typedef void(^LeftClick)();
typedef void(^RightClick)();

@interface XHNavView : UIView
/** 标题*/
@property (nonatomic,copy) NSString *navTitle;
/** 标题图标*/
@property (nonatomic,copy) NSString *iconName;
/** 左侧按钮图片名*/
@property (nonatomic,copy) NSString *leftName;
/** 右侧按钮图片名*/
@property (nonatomic,copy) NSString *rightName;
/** 右侧按钮文字显示*/
@property (nonatomic,copy) NSString *rightTitle;
/** 左侧按钮事件*/
@property (nonatomic,copy) LeftClick leftBlock;
/** 右侧按钮点击事件*/
@property (nonatomic,copy) RightClick rightBlock;

@end
