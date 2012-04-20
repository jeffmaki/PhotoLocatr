//
//  LoggedPoint.h
//  FlickrPathLogger
//
//  Created by Jeff Maki on 10/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


@interface LoggedPoint : NSObject {
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	NSDate *timestamp;
}

@property (assign) CLLocationDegrees latitude;
@property (assign) CLLocationDegrees longitude;
@property (nonatomic, retain) NSDate *timestamp;

- (id)init:(CLLocationDegrees)_latitude longitude:(CLLocationDegrees)_longitude timestamp:(NSDate *)_timestamp;
- (id)initWithSerializedForm:(NSString *)serializedForm;
- (NSString *)getSerializedForm;
- (NSString *)description;

@end
