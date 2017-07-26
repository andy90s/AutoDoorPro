//
//  BLECode.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/3/17.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "BLECode.h"

NSString *const BLE_ORDER_REQUEST = @"AA0104";
NSString *const BLE_ORDER_OPEN = @"AA0204";
NSString *const BLE_ORDER_CLOSE = @"AA0304";
NSString *const BLE_ORDER_STUDY = @"AA0404";
NSString *const BLE_ORDER_CLEAR = @"AA0504";
NSString *const BLE_ORDER_PAIR = @"AA0604";
NSString *const BLE_ORDER_RECIVE = @"AAFF04";
NSString *const BLE_ORDER_FENGMING = @"AA0704";
NSString *const BLE_ORDER_GETVERSION = @"AA010448";
NSString *const BLE_ORDER_GETSTATUS = @"AA010450";
NSString *const BLE_ORDER_RESET = @"AAFD04";
NSString *const BLE_ORDER_FACTORY_RESET = @"AA0804";
@implementation BLECode

+ (NSData *)bluetooth_request {
    Byte value[4] = {};
    value[0] = DataStyleOrder;
    value[1] = OrderCodeRequest;
    value[2] = 0x04;
    value[3] = DataStyleOrder + OrderCodeRequest + 0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

+ (NSData *)bluetooth_open {
    Byte value[4] = {};
    value[0] = DataStyleOrder;
    value[1] = OrderCodeOpen;
    value[2] = 0x04;
    value[3] = DataStyleOrder + OrderCodeOpen + 0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

+ (NSData *)bluetooth_close {
    Byte value[4] = {};
    value[0] = DataStyleOrder;
    value[1] = OrderCodeClose;
    value[2] = 0x04;
    value[3] = DataStyleOrder + OrderCodeClose + 0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

+ (NSData *)bluetooth_study {
    Byte value[4] = {};
    value[0] = DataStyleOrder;
    value[1] = OrderCodeStudy;
    value[2] = 0x04;
    value[3] = DataStyleOrder + OrderCodeStudy + 0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

+ (NSData *)bluetooth_clear {
    Byte value[4] = {};
    value[0] = DataStyleOrder;
    value[1] = OrderCodeClear;
    value[2] = 0x04;
    value[3] = DataStyleOrder + OrderCodeClear + 0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

+ (NSData *)bluetooth_pair {
    Byte value[4] = {};
    value[0] = DataStyleOrder;
    value[1] = OrderCodePair;
    value[2] = 0x04;
    value[3] = DataStyleOrder + OrderCodePair + 0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

+ (NSData *)bluetooth_recive {
    Byte value[4] = {};
    value[0] = DataStyleOrder;
    value[1] = OrderCodeRecive;
    value[2] = 0x04;
    value[3] = DataStyleOrder + OrderCodeRecive + 0x04;
    NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
    return data;
}

+ (NSData *)getCheckSum:(NSString *)byteStr{
    int length = (int)byteStr.length/2;
    NSData *data = [BLECode hexToBytes:byteStr];
    Byte *bytes = (unsigned char *)[data bytes];
    Byte sum = 0;
    for (int i = 0; i<length; i++) {
        sum += bytes[i];
    }
    int sumT = sum;
    int at = 255 -  sumT;
    // 此处算到sum就可以
    printf("校验和：%d===%d",sum,at);
    if (at == 255) {
        at = 0;
    }
    NSString *str = [NSString stringWithFormat:@"%@%@",byteStr,[BLECode ToHex:at]];
    NSLog(@"最后结果:%@",str);
    return [BLECode hexToBytes:str];
}

//将十进制转化为十六进制
+ (NSString *)ToHex:(int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    //不够一个字节凑0
    if(str.length == 1){
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
}

+ (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

@end
