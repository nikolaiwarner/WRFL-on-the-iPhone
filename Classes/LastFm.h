//
//  LastFm.h
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 2/7/10.
//  Copyright 2010 Jetpack Dance-Off. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "FMEngine.h"

@interface LastFm : NSObject {
  
  FMEngine *fmEngine;
  
  NSString *username;
  NSString *password;
  
  NSString *session_key;
  
  NSString *session_id;
  NSString *now_playing_url;
  NSString *submission_url;
  
	BOOL      isLoggedIn;
  BOOL      isLoggingIn;
  
}


@property BOOL isLoggedIn;
@property BOOL isLoggingIn;
@property (nonatomic, retain) NSString * session_id;
@property (nonatomic, retain) NSString * now_playing_url;
@property (nonatomic, retain) NSString * submission_url;

- (void) login;
- (void) loginCallback:(NSString *)identifier data:(id)data;
- (void) handshakeCallback:(ASIHTTPRequest *)request;




- (void) updateLastfmNowPlayingWithArtist:(NSString*)artistName andTrack:(NSString*)trackName andAlbum:(NSString*)albumName;
- (void) updateLastfmNowPlayingCallback:(ASIHTTPRequest *)request;
- (void) scrobbleWithArtist:(NSString*)artistName andTrack:(NSString*)trackName andAlbum:(NSString*)albumName andStartTime:(NSString*)timestamp;
- (void) scrobbleCallback:(ASIHTTPRequest *)request;




- (void) requestLocalEvents;
- (void) localEventsCallback:(NSString *)identifier data:(id)data;





@end
