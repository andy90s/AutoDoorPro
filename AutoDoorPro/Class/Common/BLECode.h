//
//  BLECode.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/3/17.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 发送*/
UIKIT_EXTERN NSString *const BLE_ORDER_REQUEST;
/** 开门*/
UIKIT_EXTERN NSString *const BLE_ORDER_OPEN;
/** 关门*/
UIKIT_EXTERN NSString *const BLE_ORDER_CLOSE;
/** 自学习*/
UIKIT_EXTERN NSString *const BLE_ORDER_STUDY;
/** 清码*/
UIKIT_EXTERN NSString *const BLE_ORDER_CLEAR;
/** 对码*/
UIKIT_EXTERN NSString *const BLE_ORDER_PAIR;
/** 接收*/
UIKIT_EXTERN NSString *const BLE_ORDER_RECIVE;


@interface BLECode : NSObject

+ (NSData *)getCheckSum:(NSString *)byteStr;

/**
 将十进制转换十六进制

 @param tmpid 十进制int
 @return 十六进制字符串
 */
+ (NSString *)ToHex:(int)tmpid;

@end
