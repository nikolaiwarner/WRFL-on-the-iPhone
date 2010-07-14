//
//  WRFL_on_the_iPhoneAppDelegate.m
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright Jetpack Dance-Off 2009. All rights reserved.
//

#import "WRFL_on_the_iPhoneAppDelegate.h"
#import "Reachability.h"

@implementation WRFL_on_the_iPhoneAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
  
  // Check reachability:
  [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
  hostReach = [[Reachability reachabilityWithHostName: @"wrfl.fm"] retain];
  [hostReach startNotifier];
  //[self updateInterfaceWithReachability: hostReach];
 
  // Add the tab bar controller's current view as a subview of the window
  [window addSubview:tabBarController.view];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
  
  // Check reachability:
  [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
  hostReach = [[Reachability reachabilityWithHostName: @"wrfl.fm"] retain];
  [hostReach startNotifier];
  //[self updateInterfaceWithReachability: hostReach];
  
  // Add the tab bar controller's current view as a subview of the window
  [window addSubview:tabBarController.view];
  return TRUE;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

- (void) reachabilityChanged: (NSNotification* )note {
  Reachability* curReach = [note object];
  NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
  [self updateInterfaceWithReachability: curReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach {
  if (curReach == hostReach) {
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if (netStatus == NotReachable) { // Fail!
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connectivity Required" message:@"A connection to the Internet could not be found.\n \n This application requires an internet connection. It appears your device may not be connected to a WiFi / carrier data network or a connection to our servers cannot be properly established at this time. \n \n Please attempt to re-establish your internet connection to continue fully using this application." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
      [alert release];
    }
  }
}



- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

