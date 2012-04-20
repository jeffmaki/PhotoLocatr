//
//  PointCollectionController.h
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FlickrPageController.h"
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface PointCollectionController : UIViewController <CLLocationManagerDelegate> {
	IBOutlet UILabel *pointCountLabel;
	IBOutlet UILabel *averageAccuracyLabel;
	IBOutlet UISwitch *collectPointsSwitch;
	IBOutlet UISlider *movementFilterSlider;
	IBOutlet FlickrPageController *flickrPageController;
	
	CLLocationManager *locationManager;
	NSMutableArray *pointList;
}

BOOL temporaryLocationUpdateIgnore = NO;

- (IBAction)showFlickrPage:(id)sender;
- (IBAction)clearPointList:(id)sender;
- (IBAction)beforeUpdateMovementFilter:(id)sender;
- (IBAction)afterUpdateMovementFilter:(id)sender;
- (IBAction)updateMovementFilter:(id)sender;
- (IBAction)updateCollectPoints:(id)sender;
- (void)restoreConfiguration;
- (void)saveConfiguration;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error; 
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *pointList;
@property (nonatomic, retain) FlickrPageController *flickrPageController;

@end
