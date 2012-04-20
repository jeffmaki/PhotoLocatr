//
//  FlickrAPIPhoto.h
//  FlickrPathLogger
//
//  Created by Jeff Maki on 10/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlickrAPIPhoto : NSObject {
	NSString *photoId;
	NSString *title;
	NSDate *dateTaken;
	float latitude;
	float longitude;
	BOOL wasTagged;
}

@property (nonatomic,retain) NSString *photoId;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSDate *dateTaken;
@property (assign) float latitude;
@property (assign) float longitude;
@property (assign) BOOL wasTagged;

- (id)init:(NSString *)_photoId dateTaken:(NSDate *)_dateTaken title:(NSString *)_title latitude:(float)_latitude longitude:(float)_longitude;
- (id)init:(NSString *)_photoId dateTaken:(NSDate *)_dateTaken title:(NSString *)_title;

@end

