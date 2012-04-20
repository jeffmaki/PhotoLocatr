//
//  FlickrAPIPhoto.m
//  FlickrPathLogger
//
//  Created by Jeff Maki on 10/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FlickrAPIPhoto.h"


@implementation FlickrAPIPhoto

@synthesize photoId;
@synthesize dateTaken;
@synthesize title;
@synthesize latitude;
@synthesize longitude;
@synthesize wasTagged;

- (id)init:(NSString *)_photoId dateTaken:(NSDate *)_dateTaken title:(NSString *)_title {
	self.photoId = _photoId;
	self.title = _title;
	
	// force time-zone-less time into current TZ
	NSCalendar *calendar = [NSCalendar currentCalendar];

	[calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:_dateTaken];
	
	[calendar setTimeZone:[NSTimeZone localTimeZone]];
	self.dateTaken = [calendar dateFromComponents:components];
	
	return self;
}

- (id)init:(NSString *)_photoId dateTaken:(NSDate *)_dateTaken title:(NSString *)_title latitude:(float)_latitude longitude:(float)_longitude {
	[self init:_photoId dateTaken:_dateTaken title:_title];
	
	self.latitude = _latitude;
	self.longitude = _longitude;
		
	return self;
}

@end
