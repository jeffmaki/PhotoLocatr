//
//  LoggedPoint.m
//  FlickrPathLogger
//
//  Created by Jeff Maki on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LoggedPoint.h"


@implementation LoggedPoint

@synthesize latitude;
@synthesize longitude;
@synthesize timestamp;

- (id)init:(CLLocationDegrees)_latitude longitude:(CLLocationDegrees)_longitude timestamp:(NSDate *)_timestamp {
	self.latitude = _latitude;
	self.longitude = _longitude;
	self.timestamp = _timestamp;
	
	return self;
}

- (id)initWithSerializedForm:(NSString *)serializedForm {
	NSArray *parts = [serializedForm componentsSeparatedByString:@"|"];

	if([parts count] < 3)
		return nil;
	
	return [self init:[((NSString *)[parts objectAtIndex:0]) floatValue] longitude:[((NSString *)[parts objectAtIndex:1]) floatValue] timestamp:[NSDate dateWithTimeIntervalSinceReferenceDate:[((NSString *)[parts objectAtIndex:2]) floatValue]]];
}

- (NSString *)getSerializedForm {
	return [NSString stringWithFormat:@"%3.8f|%3.8f|%f", self.latitude, self.longitude, [self.timestamp timeIntervalSinceReferenceDate]];	
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%3.8f, %3.8f %@", latitude, longitude, [timestamp description]];
}

@end
