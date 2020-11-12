//
//  AppDelegate.m
//  SimplePingDemo
//
//  Created by wanghe on 2017/5/15.
//  Copyright © 2017年 wanghe. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    // 获取网络信息
    [self getNetworkReachability];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




/**
 * 获取网络
 */
- (void) getNetworkReachability {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:{
                NSLog(@"------>>未知");
                [defaults setObject:@"未知" forKey:@"CurrentNetworkStatus"];
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:{
                NSLog(@"------>>没有网络");
                [defaults setObject:@"没有网络" forKey:@"CurrentNetworkStatus"];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                NSLog(@"------>>3G/4G");
                [defaults setObject:@"3G/4G" forKey:@"CurrentNetworkStatus"];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"------>>WIFI网络");
                [defaults setObject:@"WIFI网络" forKey:@"CurrentNetworkStatus"];
            }
                break;
            default:
                break;
        }
    }];
}


@end