//
//  hljAppDelegate.m
//  HLJNavigationBar
//
//  Created by bullet_wu on 08/29/2017.
//  Copyright (c) 2017 bullet_wu. All rights reserved.
//

#import "AppDelegate.h"
#import "HLJTestViewController.h"
#import "UIImage+HLJNavBarExtend.h"
#import "UINavigationBar+HLJNavigationItem.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    /**
     *  默认情况下tableview header和fooer颜色的设置
     */
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        // 去掉iOS11系统默认开启的self-sizing
        [UITableView appearance].estimatedRowHeight = 0;
        [UITableView appearance].estimatedSectionHeaderHeight = 0;
        [UITableView appearance].estimatedSectionFooterHeight = 0;
    }
    
    //配置一些ui信息（必须）
    [[UINavigationBar appearance] setHlj_backImage:[[UIImage imageNamed:@"icon_common_back_main"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [[UINavigationBar appearance] setHlj_shadowColor:[UIColor grayColor]];
    [[UINavigationBar appearance] setHlj_alpha:1];
    [[UINavigationBar appearance] setHlj_backgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setHlj_barButtonItemTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setHlj_barButtonItemFont:[UIFont systemFontOfSize:14.0]];
    [[UINavigationBar appearance] setHlj_titleColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setHlj_font:[UIFont boldSystemFontOfSize:17.0]];
 
    HLJTestViewController *viewController = [[HLJTestViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = nav;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
