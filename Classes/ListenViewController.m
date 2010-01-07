//
//  FirstViewController.m
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright Jetpack Dance-Off 2009. All rights reserved.
//

#import "ListenViewController.h"
#import "AudioStreamer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation ListenViewController

@synthesize webview;



- (void)viewDidLoad {
	[super viewDidLoad];
	
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volume.bounds] autorelease];
	[volume addSubview:volumeView];
	[volumeView sizeToFit];
	
	[self setTitle:@"Play"];
	
	// Webview shows the currently playing track info ..... for now
	[self updateWebview:nil];
	trackTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self	selector:@selector(updateWebview:)	userInfo:nil repeats:YES];
}



- (void) stopAudioStreamer {
	if (audioStreamer) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:audioStreamer];
		
		[audioStreamer stop];
		[audioStreamer release];
		audioStreamer = nil;
	}
}


- (void) startAudioStreamer {
	if (audioStreamer) {
		return;
	}

	// Tune In
	[self stopAudioStreamer];
	NSURL *url = [NSURL URLWithString:(NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)@"http://wrfl.uky.edu:9000/", NULL, NULL, kCFStringEncodingUTF8)];
	audioStreamer = [[AudioStreamer alloc] initWithURL:url];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:audioStreamer];
}








- (IBAction)buttonPressed:(id)sender {
	if ([[button_play titleForState:UIControlStateNormal] isEqual:@"Play"]) {		
		[self startAudioStreamer];

		[button_play setTitle:@"Loading..." forState:UIControlStateNormal];
		[audioStreamer start];
	} else 	{
		[audioStreamer stop];
	}
}


- (void)playbackStateChanged:(NSNotification *)aNotification {
	if ([audioStreamer isWaiting]){
		[button_play setTitle:@"Loading..." forState:UIControlStateNormal];
	}
	else if ([audioStreamer isPlaying]){
		[button_play setTitle:@"Stop" forState:UIControlStateNormal];
	}
	else if ([audioStreamer isIdle]){
		[self stopAudioStreamer];
		[button_play setTitle:@"Play" forState:UIControlStateNormal];
	}
}









- (void) updateWebview:(NSTimer *)updatedTimer {
	[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wrfl.fm/index.cgi?m=nowplayajax"]]];
	//NSLog(@"here");
	//[webview reload];
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[self stopAudioStreamer];
	if (trackTimer) {
		[trackTimer invalidate];
		trackTimer = nil;
	}
    [super dealloc];
}

@end
