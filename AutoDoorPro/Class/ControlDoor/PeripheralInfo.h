//
//  PeripheralInfo.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/3/16.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralInfo : NSObject

@property (nonatomic,strong) CBUUID *serviceUUID;
@property (nonatomic,strong) NSMutableArray *characteristics;

@end
