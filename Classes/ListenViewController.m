//
//  FirstViewController.m
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright Jetpack Dance-Off 2009. All rights reserved.
//

#import "ListenViewController.h"
#import "AudioStreamer.h"
#import "QuartzCore/QuartzCore.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation ListenViewController

@synthesize artwork, artist_label, album_label, track_label, dj_label, nowPlayingInfoView;



- (void)viewDidLoad {
	[super viewDidLoad];
  
  
  fmEngine = [[FMEngine alloc] init];
  lastfm = [[LastFm alloc] init];
  nowplaying = [[Song alloc] init];
  previous_song = [[Song alloc] init];
  
  // Resest the info displays
  [self setTitle:@"Listen"];
  nowPlayingInfoView.alpha = 0;
  [self updateNowPlayingArtworkViewWithImage:[UIImage imageNamed:@"album_bg"]];
	[self setButtonImage:[UIImage imageNamed:@"playbutton"]];
  
	// Add the volume control
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volume.bounds] autorelease];
	[volume addSubview:volumeView];
	[volumeView sizeToFit];
	

  // Start track data request loop
  [self refreshNowPlayingData:self];
}





- (void)setButtonImage:(UIImage *)image {
	[button_play setImage:image forState:0];
}

- (IBAction)buttonPressed:(id)sender {
	if (!audioStreamer) {    
    NSURL *url = [NSURL URLWithString:(NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)@"http://wrfl.uky.edu:9000/", NULL, NULL, kCFStringEncodingUTF8)];
		audioStreamer = [[AudioStreamer alloc] initWithURL:url];    
		[audioStreamer addObserver:self forKeyPath:@"isPlaying" options:0 context:nil];
		[audioStreamer start];   
	} else {
		[audioStreamer stop];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"isPlaying"]) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
		if ([(AudioStreamer *)object isPlaying]) {
			[self performSelector:@selector(setButtonImage:) onThread:[NSThread mainThread] withObject:[UIImage imageNamed:@"stopbutton"] waitUntilDone:NO];
		}
		else
		{
			[audioStreamer removeObserver:self forKeyPath:@"isPlaying"];
			[audioStreamer release];
			audioStreamer = nil;      
			[self performSelector:@selector(setButtonImage:) onThread:[NSThread mainThread] withObject:[UIImage imageNamed:@"playbutton"] waitUntilDone:NO];
		}
    
		[pool release];
		return;
	}	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}










- (void) refreshNowPlayingData:(id)sender {
  NSURL *url = [NSURL URLWithString:@"http://wrfl.fm/index.cgi?m=nowplayajax"];
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(refreshNowPlayingDataRequestDone:)];
  [request setDidFailSelector:@selector(refreshNowPlayingDataRequestFail:)];
  [request startAsynchronous];
  
  trackTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self	selector:@selector(refreshNowPlayingData:)	userInfo:nil repeats:NO];
}



- (void)refreshNowPlayingDataRequestDone:(ASIHTTPRequest *)request {
  NSString *responseString = [request responseString];
  

  // Parse the HTML ... it sucks to do it this way, but it's currently the only public source for this data.
  NSScanner* scanner = [[NSScanner alloc] initWithString:responseString];
  
  NSString * djName = @"";
  NSString * trackName = @"";
  NSString * artistName = @"";
  NSString * albumName = @"";
  
  [scanner scanUpToString:@"<td nowrap=\"nowrap\">" intoString: nil];
  [scanner setScanLocation:[scanner scanLocation] + 20];
  [scanner scanUpToString:@"\">" intoString: nil];
  [scanner setScanLocation:[scanner scanLocation] + 2];
  [scanner scanUpToString:@"</a><br />" intoString: &djName];
  [scanner setScanLocation:[scanner scanLocation] + 10];
  if ([[responseString lowercaseString] rangeOfString:[@"track" lowercaseString]].location != NSNotFound){
    [scanner scanUpToString:@"<br />" intoString: &trackName];
    [scanner setScanLocation:[scanner scanLocation] + 6];
  }
  if ([[responseString lowercaseString] rangeOfString:[@"artist" lowercaseString]].location != NSNotFound){
    [scanner scanUpToString:@"<br />" intoString: &artistName];
    [scanner setScanLocation:[scanner scanLocation] + 6];
  }
  if ([[responseString lowercaseString] rangeOfString:[@"album" lowercaseString]].location != NSNotFound){
    [scanner scanUpToString:@"<br/>" intoString: &albumName];
  }
  //  NSLog([NSString stringWithFormat:@"dj: %@ \n track: %@ \n artist: %@ \n album: %@", djName, trackName, artistName, albumName] );

  
  if (![nowplaying.track isEqualToString:trackName]) {
    
    nowplaying.time_end = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
    previous_song = nowplaying;
    
    nowplaying.artist = artistName;
    nowplaying.album = albumName;
    nowplaying.track = trackName;
    nowplaying.dj = djName;
    nowplaying.time_start = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
    

    // scrobble track, if desired
    if (lastfm.isLoggedIn && ![previous_song.artist isEqualToString:@""]) {
      //[lastfm updateLastfmNowPlayingWithArtist:previous_song.artist andTrack:previous_song.track andAlbum:previous_song.album];
      [lastfm scrobbleWithArtist:previous_song.artist andTrack:previous_song.track andAlbum:previous_song.album andStartTime:previous_song.time_start];
    } else {
      // Log into lastfm, if desired
      [lastfm login];
    }
    
    
    [self updateNowPlayingView];
  }
}


- (void)refreshNowPlayingDataRequestFail:(ASIHTTPRequest *)request {
  //NSError *error = [request error];
}








- (void) updateNowPlayingView {
  //Hide View
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  nowPlayingInfoView.alpha = 0;
  artwork.alpha = 0;
  artwork_reflection.alpha = 0;
  [UIView commitAnimations];
  
  
  // get image for track  
  if (![nowplaying.album isEqualToString:@""]) {
    NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:nowplaying.artist, @"artist", nowplaying.album, @"album", _LASTFM_API_KEY_, @"api_key", nil, nil];
    [fmEngine performMethod:@"album.getInfo" withTarget:self withParameters:urlDict andAction:@selector(updateNowPlayingArtworkByArtistAlbumCallback:data:) useSignature:YES httpMethod:POST_TYPE];  
  } else if (![nowplaying.track isEqualToString:@""]) {
    NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:nowplaying.artist, @"artist", nowplaying.track, @"track", _LASTFM_API_KEY_, @"api_key", nil, nil];
    [fmEngine performMethod:@"track.getInfo" withTarget:self withParameters:urlDict andAction:@selector(updateNowPlayingArtworkByArtistAlbumCallback:data:) useSignature:YES httpMethod:POST_TYPE];
  } else {
    NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:nowplaying.artist, @"artist", _LASTFM_API_KEY_, @"api_key", nil, nil];
    [fmEngine performMethod:@"artist.getInfo" withTarget:self withParameters:urlDict andAction:@selector(updateNowPlayingArtworkByArtistAlbumCallback:data:) useSignature:YES httpMethod:POST_TYPE];  
  }


  
  // update labels
  artist_label.text = nowplaying.artist;
  album_label.text = nowplaying.album;
  track_label.text = nowplaying.track;
  dj_label.text = nowplaying.dj;

  // Show View
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  nowPlayingInfoView.alpha = 1;
  [UIView commitAnimations];
}









- (void) updateNowPlayingArtworkByArtistAlbumCallback:(NSString *)identifier data:(id)data {
  
  if ([data isKindOfClass:[NSData class]]) {
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    id response = [dataString JSONValue];
    NSDictionary *json = (NSDictionary *)response;
    
    NSArray *images = (NSArray *)[(NSDictionary*)[json valueForKey:@"album"] valueForKey:@"image"];
    // loop over all the image results
    int i;
    if ([images count] > 0) {
      NSDictionary *image;
      for (i = 0; i < [images count]; i++) {
        image = (NSDictionary *)[images objectAtIndex:i];
      }

      // Get remote image
      ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[image valueForKey:@"#text"]]];
      [request setDelegate:self];
      [request setDidFinishSelector:@selector(loadRemoteImageForNowPlayingArtwork:)];
      //[request startAsynchronous];

    } else {
      // No Images
      nowplaying.artwork = [UIImage imageNamed: @"album_bg"];
      [self updateNowPlayingArtworkViewWithImage:nowplaying.artwork];
    }    
    
  } else {
    // Fail
    nowplaying.artwork = [UIImage imageNamed: @"album_bg"];
    [self updateNowPlayingArtworkViewWithImage:nowplaying.artwork];
  }

}



- (void) loadRemoteImageForNowPlayingArtwork:(ASIHTTPRequest *)request {
  nowplaying.artwork = [UIImage imageWithData:[request responseData]];
  [self updateNowPlayingArtworkViewWithImage:nowplaying.artwork];
}




- (void) updateNowPlayingArtworkViewWithImage:(UIImage*)image {
  artwork.alpha = 0;
  artwork_reflection.alpha = 0;
  
  // Set image
  artwork.image = image;

  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  artwork.alpha = 1;
  [UIView commitAnimations];
  
  // Set reflection
  artwork_reflection.image = [self reflectedImage:artwork];
  
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  artwork_reflection.alpha = 0.6;
  [UIView commitAnimations];

}




- (UIImage *)reflectedImage:(UIImageView *)fromImage {
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef mainViewContentContext = CGBitmapContextCreate (nil, fromImage.bounds.size.width, artwork_reflection.bounds.size.height, 8, 0, colorSpace, (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
	
	CGFloat translateVertical= fromImage.bounds.size.height - artwork_reflection.bounds.size.height;
	CGContextTranslateCTM(mainViewContentContext, 0, -translateVertical);
	CALayer *layer = fromImage.layer;
	[layer renderInContext:mainViewContentContext];
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
  
  CGImageRef gradientMaskImage = NULL;
  CGColorSpaceRef colorSpaceGray = CGColorSpaceCreateDeviceGray();
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(nil, 1, artwork_reflection.bounds.size.height, 8, 0, colorSpaceGray, kCGImageAlphaNone);
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpaceGray, colors, NULL, 2);
	CGColorSpaceRelease(colorSpaceGray);
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, artwork_reflection.bounds.size.height);
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint, gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	gradientMaskImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
  
	CGImageRef reflectionImage = CGImageCreateWithMask(mainViewContentBitmapContext, gradientMaskImage);
	CGImageRelease(mainViewContentBitmapContext);
	CGImageRelease(gradientMaskImage);
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	CGImageRelease(reflectionImage);
	return theImage;
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
	if (trackTimer) {
		[trackTimer invalidate];
		trackTimer = nil;
	}
    [super dealloc];
}

@end
