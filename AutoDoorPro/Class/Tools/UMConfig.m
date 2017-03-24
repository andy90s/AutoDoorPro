//
//  UMConfig.m
//  YONGMIN2.0
//
//  Created by 梁先华 on 16/8/29.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "UMConfig.h"
#import <UMengAnalytics/UMMobClick/MobClick.h>

static NSString *const UMAppKey = @"58d0fe4704e205811d0006c5";

@implementation UMConfig

//+ (void)umsocialInitial
//{
//    [UMSocialData setAppKey:UMAppKey];
//    //设置微信AppId、appSecret，分享url
//    [UMSocialWechatHandler setWXAppId:@"wxd930ea5d5a258f4f" appSecret:@"db426a9829e4b49a0dcac7b4162da6b6" url:@"http://www.umeng.com/social"];
//    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
//    [UMSocialQQHandler setQQWithAppId:@"100424468" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
//    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
//    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"3921700954"
//                                        secret:@"04b48b094faeb16683c32669824ebdad"
//                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
//}


+ (void)umeiUmAnalyticsInitial {
    UMConfigInstance.appKey = UMAppKey;
    UMConfigInstance.channelId = @"App Store";//平台 预先设置为AppStore
    NSString *version = [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    //[MobClick startWithAppkey:@"你应用的AppKey" reportPolicy:BATCH   channelId:@"渠道，设置nil是App Store"];
    
    [MobClick startWithConfigure:UMConfigInstance];
}
@end
