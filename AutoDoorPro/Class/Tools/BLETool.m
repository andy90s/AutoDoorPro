//
//  BLETool.m
//  AutoDoorPro
//
//  Created by 梁先华 on 2017/4/12.
//  Copyright © 2017年 梁先华. All rights reserved.
//

#import "BLETool.h"

@implementation BLETool

+ (NSString *)hardwareInfo:(NSString *)info {
    return [NSString stringWithFormat:@"V%@.%@",[info substringWithRange:NSMakeRange(6, 2)],[info substringWithRange:NSMakeRange(8, 2)]];
}

+ (NSString *)softwareInfo:(NSString *)info {
    return [NSString stringWithFormat:@"V%@.%@-%@",[info substringWithRange:NSMakeRange(10, 2)],[info substringWithRange:NSMakeRange(12, 2)],[info substringWithRange:NSMakeRange(14, 2)]];
}

+ (NSInteger)speed:(NSString *)value {
    NSString *speed = [value substringWithRange:NSMakeRange(6, 2)];
    NSLog(@"--速度:%@",speed);
    return [NSString stringWithFormat:@"%ld",strtoul([speed UTF8String], 0, 16)].integerValue;
}

+ (NSInteger)damp:(NSString *)value {
    NSString *speed = [value substringWithRange:NSMakeRange(8, 2)];
    NSLog(@"--阻尼:%@",speed);
    return [NSString stringWithFormat:@"%ld",strtoul([speed UTF8String], 0, 16)].integerValue;
}

+ (NSInteger)openTime:(NSString *)value {
    
    NSString *speed = [value substringWithRange:NSMakeRange(10, 2)];
    NSLog(@"--开门:%@",speed);
    return [NSString stringWithFormat:@"%ld",strtoul([speed UTF8String], 0, 16)].integerValue;
}

+ (NSInteger)closure:(NSString *)value {
    NSString *speed = [value substringWithRange:NSMakeRange(14, 2)];
    NSLog(@"--紧闭力:%@",speed);
    return [NSString stringWithFormat:@"%ld",strtoul([speed UTF8String], 0, 16)].integerValue;
}

+ (NSString *)switchStatus:(NSString *)value {
    NSString *speed = [value substringWithRange:NSMakeRange(12, 2)];
    NSLog(@"--状态:%@",speed);
    return [NSString stringWithFormat:@"%ld",strtoul([speed UTF8String], 0, 16)];
}

+ (NSString *)replaceString:(NSString *)value {
    NSMutableString *mStr = [NSMutableString stringWithString:value];
    NSString *temp = [mStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSMutableString *mTemp = [NSMutableString stringWithString:temp];
    NSString *result = [mTemp stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSMutableString *mTemp1 = [NSMutableString stringWithString:result];
    NSString *s = [mTemp1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    return s;
}

+ (NSString *)getSpecStatus:(NSString *)value {
    NSString *speed = [value substringWithRange:NSMakeRange(12, 2)];
    return [BLECode getBinaryByhex:[NSString stringWithFormat:@"%ld",strtoul([speed UTF8String], 0, 16)] binary:nil];
}

@end
