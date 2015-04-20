//
//  AppDelegate.m
//  SignIn
//
//  Created by 諶俭 on 15/4/4.
//  Copyright (c) 2015年 諶俭. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import "SignController.h"
#import "NSDate+Help.h"

@interface AppDelegate ()
@property(nonatomic, strong) UINavigationController *naviController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.naviController = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    self.naviController.navigationBar.translucent = NO;
    self.window.rootViewController = self.naviController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uniqueId = (__bridge NSString *)uuidStringRef;
    CFRelease(uuidStringRef);
    
    NSLog(@"xxx : %@", uniqueId);
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *path = @"signtodayextension://action=";
    if ([[url absoluteString] rangeOfString:path].location != NSNotFound) {
        SignController *controller = [[SignController alloc]init];
        NSDictionary *todayInfo = [[NSDate date] seperateComponent];
        controller.year = [todayInfo[COMPONENT_YEAR] integerValue];
        controller.month = [todayInfo[COMPONENT_MONTH] integerValue];
        [self.naviController pushViewController:controller animated:YES];
    }
    return YES;
}

@end
