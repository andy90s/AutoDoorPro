//
//  Macro.h
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/3/17.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

/** 数据命令*/
typedef NS_ENUM(Byte,OrderCode) {
    OrderCodeRequest = 0x01, // 要求对方发送数据帧
    OrderCodeOpen = 0x02, // 开门
    OrderCodeClose = 0x03, // 关门
    OrderCodeStudy = 0x04, // 自学习
    OrderCodeClear = 0x05, // 遥控器清码
    OrderCodePair = 0x06, // 遥控器对码
    OrderCodeRecive = 0xff // 收到一帧合法的命令或数据
};
/** 数据类型*/
typedef NS_ENUM(Byte,DataStyle) {
    DataStyleData = 0x55, // 表示后续为数据
    DataStyleOrder = 0xAA, // 表示后续为命令
};

#endif /* Macro_h */
