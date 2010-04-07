//
//  FirstViewController.h
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 9/9/09.
//  Copyright Jetpack Dance-Off 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LastFm.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "FMEngine.h"

#import "Song.h"



@class AudioStreamer;

@interface ListenViewController : UIViewController <UIWebViewDelegate> {

	IBOutlet UIButton     *button_play;
	IBOutlet UIView       *volume;
	IBOutlet UIImageView  *artwork;
  IBOutlet UIImageView  *artwork_reflection;
  IBOutlet UILabel      *artist_label;
  IBOutlet UILabel      *track_label;
  IBOutlet UILabel      *album_label;
  IBOutlet UILabel      *dj_label;
  IBOutlet UIView       *nowPlayingInfoView;
  
	AudioStreamer         *audioStreamer;
  
	NSTimer               *trackTimer;
	FMEngine              *fmEngine;
  LastFm                *lastfm;
  
  Song                  *nowplaying;
  Song                  *previous_song;
  
  
}

@property (nonatomic, retain) UIImageView   *artwork;
@property (nonatomic, retain) UILabel       *artist_label;
@property (nonatomic, retain) UILabel       *track_label;
@property (nonatomic, retain) UILabel       *album_label;
@property (nonatomic, retain) UILabel       *dj_label;
@property (nonatomic, retain) UIView        *nowPlayingInfoView;



- (void) setButtonImage:(UIImage *)image;
- (IBAction) buttonPressed:(id)sender;
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;



- (void) updateNowPlayingArtworkByArtistAlbumCallback:(NSString *)identifier data:(id)data;
- (void) updateNowPlayingArtworkViewWithImage:(UIImage*)image;
- (void) loadRemoteImageForNowPlayingArtwork:(ASIHTTPRequest *)request;
- (void) updateNowPlayingView;

- (UIImage *)reflectedImage:(UIImageView *)fromImage;

- (void) refreshNowPlayingData:(id)sender;
- (void) refreshNowPlayingDataRequestDone:(ASIHTTPRequest *)request;
- (void) refreshNowPlayingDataRequestFail:(ASIHTTPRequest *)request;


@end