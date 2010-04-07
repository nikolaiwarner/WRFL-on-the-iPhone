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


@interface WRFL_on_the_iPhoneAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
  UIWindow *window;
  UITabBarController *tabBarController;
  
  NetworkStatus remoteHostStatus;
	NetworkStatus internetConnectionStatus;
	NetworkStatus localWiFiConnectionStatus;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property NetworkStatus remoteHostStatus;
@property NetworkStatus internetConnectionStatus;
@property NetworkStatus localWiFiConnectionStatus;


- (void)reachabilityChanged:(NSNotification *)note;
- (void)updateNetworkStatus;
- (BOOL)isCarrierDataNetworkActive;
- (BOOL)isWifiDataNetworkActive;
- (void) displayNetworkConnectionStatus;

@end
