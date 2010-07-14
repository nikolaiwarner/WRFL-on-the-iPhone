//
//  WRFL_on_the_iPhoneAppDelegate.h
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright Jetpack Dance-Off 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

#define kSelectedTabDefaultsKey @"SelectedTab"

#define kLastfmUsername @"LastfmUsername"
#define kLastfmPassword @"LastfmPassword"

@class Reachability;

@interface WRFL_on_the_iPhoneAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
  UIWindow *window;
  UITabBarController *tabBarController;
  
  Reachability* hostReach;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;


- (void) updateInterfaceWithReachability: (Reachability*) curReach;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;


@end
