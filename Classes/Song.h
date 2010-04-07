//
//  Song.h
//  WRFL-on-the-iPhone
//
//  Created by Nick Warner on 3/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMEngine.h"
#import "JSON.h"

@interface Song : NSObject {

  
  NSString            *dj;
  NSString            *artist;
  NSString            *track;
  NSString            *album; 
  NSString            *time_start;
  NSString            *time_end;  
  UIImage             *artwork;
  
}


@property (nonatomic, retain) NSString            *dj;
@property (nonatomic, retain) NSString            *artist;
@property (nonatomic, retain) NSString            *track;
@property (nonatomic, retain) NSString            *album; 
@property (nonatomic, retain) NSString            *time_start;
@property (nonatomic, retain) NSString            *time_end;  
@property (nonatomic, retain) UIImage             *artwork;



@end
