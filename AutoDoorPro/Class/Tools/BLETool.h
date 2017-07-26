//
//  BLETool.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/4/12.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLETool : NSObject

/** 硬件信息*/
+ (NSString *)hardwareInfo:(NSString *)info;
/** 软件信息*/
+ (NSString *)softwareInfo:(NSString *)info;
/** 速度*/
+ (NSInteger)speed:(NSString *)value;
/** 阻尼*/
+ (NSInteger)damp:(NSString *)value;
/** 开门时间*/
+ (NSInteger)openTime:(NSString *)value;
/** 紧闭力*/
+ (NSInteger)closure:(NSString *)value;
/** 开关和方向*/
+ (NSString *)switchStatus:(NSString *)value;
+ (NSString *)replaceString:(NSString *)value;
@end
