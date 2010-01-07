//
//  FirstViewController.h
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright Jetpack Dance-Off 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface ListenViewController : UIViewController <UIWebViewDelegate> {

	IBOutlet UIButton	*button_play;
	IBOutlet UIView		*volume;
	IBOutlet UIWebView	*webview;
	AudioStreamer		*audioStreamer;
	NSTimer				*trackTimer;
	
}

@property (nonatomic, retain) UIWebView *webview;

- (IBAction) buttonPressed:(id)sender;
- (void) updateWebview:(NSTimer *)aNotification;



@end