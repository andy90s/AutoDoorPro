//
//  SettingsController.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/2/28.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN BOOL isPopSettingViewController;
@interface SettingsController : UIViewController {
@public
    BabyBluetooth *baby;
    NSMutableArray *sect;
    __block  NSMutableArray *readValueArray;
    __block  NSMutableArray *descriptors;
}

// 写入的特征
@property (nonatomic,strong)CBCharacteristic *writeCharacteristic;
// 通知的特征
@property (nonatomic,strong) CBCharacteristic *notifyCharacteristic;

//@property (nonatomic,strong)CBCharacteristic *characteristic;
@property (nonatomic,strong)CBPeripheral *currPeripheral;

@end
