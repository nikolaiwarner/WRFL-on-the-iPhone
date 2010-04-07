//
//  WRFL_on_the_iPhoneAppDelegate.m
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright Jetpack Dance-Off 2009. All rights reserved.
//

#import "WRFL_on_the_iPhoneAppDelegate.h"


@implementation WRFL_on_the_iPhoneAppDelegate

@synthesize window;
@synthesize tabBarController;

@synthesize remoteHostStatus;
@synthesize internetConnectionStatus;
@synthesize localWiFiConnectionStatus;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque];
  
  [[Reachability sharedReachability] setHostName:@"wrfl.fm"];
	[self updateNetworkStatus];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
	
  
  
  
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

- (void)reachabilityChanged:(NSNotification *)note {
  [self updateNetworkStatus];
}

- (void)updateNetworkStatus {
	// Query the SystemConfiguration framework for the state of the device's network connections.
	self.remoteHostStatus           = [[Reachability sharedReachability] remoteHostStatus];
	self.internetConnectionStatus	= [[Reachability sharedReachability] internetConnectionStatus];
	self.localWiFiConnectionStatus	= [[Reachability sharedReachability] localWiFiConnectionStatus];
	
	[self displayNetworkConnectionStatus];
}

- (BOOL)isCarrierDataNetworkActive {
	return (self.remoteHostStatus == ReachableViaCarrierDataNetwork);
}

- (BOOL)isWifiDataNetworkActive {
	return (self.remoteHostStatus == ReachableViaWiFiNetwork);
}

- (void) displayNetworkConnectionStatus {
	if ([self isWifiDataNetworkActive] || [self isCarrierDataNetworkActive]) {
    
	} else { //Fail
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connectivity Required" message:@"A connection to the Internet could not be found.\n \n This application requires an internet connection. It appears your device may not be connected to a WiFi / carrier data network or a connection to our servers cannot be properly established at this time. \n \n Please attempt to re-establish your internet connection to continue fully using this application." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

