//
// AppDelegate.m
// httpdns_ios_demo
//
// Created by ryan on 27/1/2016.
// Copyright © 2016 alibaba. All rights reserved.
//

#import "AppDelegate.h"
#import "NetworkManager.h"
#import <AlicloudHttpDNS/AlicloudHttpDNS.h>

@interface AppDelegate ()< HttpDNSDegradationDelegate >

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 初始化HTTPDNS
    // 设置AccoutID
    HttpDnsService *httpdns = [[HttpDnsService alloc] autoInit];
    //鉴权方式初始化
    //HttpDnsService *httpdns = [[HttpDnsService alloc] initWithAccountID:0000 secretKey:@"XXXX"];

    // 为HTTPDNS服务设置降级机制
    [httpdns setDelegateForDegradationFilter:self];
    // 允许返回过期的IP
    [httpdns setExpiredIPEnabled:YES];
    // 打开HTTPDNS Log，线上建议关闭
    [httpdns setLogEnabled:YES];
    /*
     *  设置HTTPDNS域名解析请求类型(HTTP/HTTPS)，若不调用该接口，默认为HTTP请求；
     *  SDK内部HTTP请求基于CFNetwork实现，不受ATS限制。
     */
    //[httpdns setHTTPSRequestEnabled:YES];
    // edited
    NSArray *preResolveHosts = @[ @"www.aliyun.com", @"www.taobao.com", @"gw.alicdn.com", @"www.tmall.com", @"dou.bz"];
    // NSArray* preResolveHosts = @[@"pic1cdn.igetget.com"];
    // 设置预解析域名列表
    [httpdns setPreResolveHosts:preResolveHosts];
    
    
    NSDictionary *IPRankingDatasource = @{
                                          @"www.aliyun.com" : @80,
                                          @"www.taobao.com" : @80,
                                          @"gw.alicdn.com" : @80,
                                          @"www.tmall.com" : @80,
                                          @"dou.bz" : @80
                                          };
    // IP 优选功能，设置后会自动对IP进行测速排序，可以在调用 `-getIpByHost` 等接口时返回最优IP。
    [httpdns setIPRankingDatasource:IPRankingDatasource];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
 * 降级过滤器，您可以自己定义HTTPDNS降级机制
 */
- (BOOL)shouldDegradeHTTPDNS:(NSString *)hostName {
    NSLog(@"Enters Degradation filter.");
    // 根据HTTPDNS使用说明，存在网络代理情况下需降级为Local DNS
    if ([NetworkManager configureProxies]) {
        NSLog(@"Proxy was set. Degrade!");
        return YES;
    }
    
    // 假设您禁止"www.taobao.com"域名通过HTTPDNS进行解析
    if ([hostName isEqualToString:@"www.taobao.com"]) {
        NSLog(@"The host is in blacklist. Degrade!");
        return YES;
    }
    
    return NO;
}

@end
