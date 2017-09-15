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
 
    //配置一些ui信息（必须）
    [[UINavigationBar appearance] setShadowImage:[UIImage hlj_imageWithColor:[UIColor lightGrayColor]]];
    [[UINavigationBar appearance] setHlj_backImage:[[UIImage imageNamed:@"icon_common_back_main"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [[UINavigationBar appearance] setHlj_backgroundColor:[UIColor redColor]];
    UIImage *image = [UIImage hlj_imageWithColor:[UINavigationBar appearance].hlj_backgroundColor];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setHlj_buttonItemColor:[UIColor whiteColor]];
    
    NSMutableDictionary *titleTextAttributes = [NSMutableDictionary dictionary];
    titleTextAttributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    titleTextAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:17.0];
    [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
    
    UIBarButtonItem *appearance = [UIBarButtonItem appearance];
    [appearance setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    
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
