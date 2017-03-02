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

@property (nonatomic,copy) NSString *navTitle;
@property (nonatomic,copy) NSString *iconName;
@property (nonatomic,copy) NSString *leftName;
@property (nonatomic,copy) NSString *rightName;
@property (nonatomic,copy) NSString *rightTitle;
@property (nonatomic,copy) LeftClick leftBlock;
@property (nonatomic,copy) RightClick rightBlock;

@end
