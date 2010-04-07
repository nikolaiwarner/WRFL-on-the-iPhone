//
//  Song.m
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Song.h"


@implementation Song

@synthesize dj, artist, album, track, artwork, time_start, time_end;


- init {
  if((self = [super init])) {    
    dj = @"";
    artist = @"";
    album = @"";
    track = @"";
    time_start = @"";
    time_end = @"";
    artwork = [UIImage imageNamed:@"album_bg.png"];
  }
  return self;
}





@end
