//
//  WRFL_on_the_iPhoneAppDelegate.m
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright TAO Agency 2009. All rights reserved.
//

#import "WRFL_on_the_iPhoneAppDelegate.h"


@implementation WRFL_on_the_iPhoneAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
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


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

