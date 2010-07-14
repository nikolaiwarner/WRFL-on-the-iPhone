//
//  LastFm.m
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 2/7/10.
//  Copyright 2010 Jetpack Dance-Off. All rights reserved.
//

#import "LastFm.h"

@implementation LastFm

@synthesize isLoggedIn;
@synthesize session_id, now_playing_url, submission_url;


- init {
  if((self = [super init])) {
    
    isLoggedIn =  FALSE;
    isLoggingIn = FALSE;
    
  }
  return self;
}



- (void) saveLoginWithUsername:(NSString*) lastfmUsername andPassword:(NSString*) lastfmPassword {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:lastfmUsername forKey:@"LastfmUsername"];
  [defaults setValue:lastfmPassword forKey:@"kLastfmPassword"];
}



- (void) login {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  username = [defaults valueForKey:@"kLastfmUsername"];
  password = [defaults valueForKey:@"kLastfmPassword"];
  
  if (isLoggedIn){
    NSLog(@"Logged IN: YES");
  } else {
    NSLog(@"Logged IN: NO");
  }

  
  if (!isLoggedIn && !isLoggingIn) {
    isLoggingIn = TRUE;
    fmEngine = [[FMEngine alloc] init];
    NSString *authToken = [fmEngine generateAuthTokenFromUsername:username password:password];
    NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", authToken, @"authToken", _LASTFM_API_KEY_, @"api_key", nil, nil];
    [fmEngine performMethod:@"auth.getMobileSession" withTarget:self withParameters:urlDict andAction:@selector(loginCallback:data:) useSignature:YES httpMethod:POST_TYPE];  
  }
}
 
- (void) loginCallback:(NSString *)identifier data:(id)data {
  if ([data isKindOfClass:[NSData class]]) {
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    id response = [dataString JSONValue];
    NSDictionary *json = (NSDictionary *)response;
    NSDictionary *session = (NSDictionary*)[json valueForKey:@"session"];    
    session_key = [session objectForKey:@"key"];

    // Begin handshake 
    NSString *timestamp = [NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]];
    NSString *authToken = [fmEngine generateAuthTokenFromSecretKeyAndTimestamp:timestamp];  
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://post.audioscrobbler.com/?hs=true&p=1.2.1&c=%@&v=%@&u=%@&t=%@&a=%@&api_key=%@&sk=%@", _LASTFM_CLIENT_ID_, _LASTFM_CLIENT_VERSION_, username, timestamp, authToken, _LASTFM_API_KEY_, session_key]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(handshakeCallback:)];
    [request setDidFailSelector:@selector(handshakeCallback:)];
    [request startAsynchronous];
  }
}

- (void)handshakeCallback:(ASIHTTPRequest *)request {
  NSString *responseString = [request responseString];
  
  NSArray *responseArray = [responseString componentsSeparatedByString:@"\n"];  
  if ([[responseArray objectAtIndex:0] isEqual:@"OK"]) {    
    session_id =      [[responseArray objectAtIndex:1] retain];
    now_playing_url = [[responseArray objectAtIndex:2] retain];
    submission_url =  [[responseArray objectAtIndex:3] retain];
    
    isLoggedIn = TRUE;
    NSLog(@"LOGIN");
  } else {
    // FAIL
    isLoggedIn = FALSE;
    NSLog(@"LOGIN FAILS");
  }
  isLoggingIn = FALSE;
}







- (void) updateLastfmNowPlayingWithArtist:(NSString*)artistName andTrack:(NSString*)trackName andAlbum:(NSString*)albumName {
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:now_playing_url]];
  [request setPostValue:session_id  forKey:@"s"];
  [request setPostValue:artistName  forKey:@"a"];
  [request setPostValue:trackName   forKey:@"t"];
  [request setPostValue:albumName   forKey:@"b"];
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(updateLastfmNowPlayingCallback:)];
  [request setDidFailSelector:@selector(updateLastfmNowPlayingCallback:)];
  [request startAsynchronous];
}

- (void) updateLastfmNowPlayingCallback:(ASIHTTPRequest *)request {
  NSString *responseString = [request responseString];
  
  NSLog(@"updateLastfmNowPlayingCallback:");
}




- (void) scrobbleWithArtist:(NSString*)artistName andTrack:(NSString*)trackName andAlbum:(NSString*)albumName andStartTime:(NSString*)timestamp  { 
  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:submission_url]];
  [request setPostValue:artistName  forKey:@"a[0]"];
  [request setPostValue:trackName   forKey:@"t[0]"];
  [request setPostValue:albumName   forKey:@"b[0]"];
  [request setPostValue:@"R"        forKey:@"o[0]"];
  [request setPostValue:timestamp   forKey:@"i[0]"];  
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(scrobbleCallback:)];
  [request setDidFailSelector:@selector(scrobbleCallback:)];
  [request startAsynchronous];
}

- (void) scrobbleCallback:(ASIHTTPRequest *)request{
  NSString *responseString = [request responseString];
  
  NSLog(@"scrobbleCallback:");
}















- (void) requestLocalEvents {
  NSDictionary *urlDict = [NSDictionary dictionaryWithObjectsAndKeys:@"lexington-fayette", @"location", _LASTFM_API_KEY_, @"api_key", nil, nil];
  [fmEngine performMethod:@"geo.getevents" withTarget:self withParameters:urlDict andAction:@selector(localEventsCallback:data:) useSignature:YES httpMethod:GET_TYPE]; 
}

- (void) localEventsCallback:(NSString *)identifier data:(id)data {
  
  if ([data isKindOfClass:[NSData class]]) {
    NSString* dataString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    id response = [dataString JSONValue];
    NSDictionary *json = (NSDictionary *)response;
    
    
    NSArray *events = (NSArray *)[(NSDictionary*)[json valueForKey:@"events"] valueForKey:@"event"];
    
    // loop over all the stream objects and print their titles
    int i;
    //NSDictionary *stream;
    if ([events count] > 0) {
      for (i = 0; i < [events count]; i++) {
        NSDictionary *event = (NSDictionary *)[events objectAtIndex:i];
        NSLog(@"Event Title: %@", [event valueForKey:@"title"]);
        
      }
    } else {
      NSLog(@"No Events");
    }
  } else {
    //NSLog([data localizedDescription]);
  }
  
}






@end
