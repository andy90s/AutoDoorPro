//
//  PeripheralInfo.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/3/16.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "PeripheralInfo.h"

@implementation PeripheralInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _characteristics = [[NSMutableArray alloc]init];
    }
    return self;
}

@end
