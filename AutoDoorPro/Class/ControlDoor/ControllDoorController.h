//
//  ControllDoorController.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeripheralInfo.h"

@interface ControllDoorController : UIViewController {
    @public
    BabyBluetooth *baby;
}

// __block对象在block中是可以被修改、重新赋值的
@property __block NSMutableArray *services;
@property(strong,nonatomic)CBPeripheral *currPeripheral;

@end
