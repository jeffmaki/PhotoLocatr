//
//  PointCollectionController.m
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/18/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LoggedPoint.h"
#import "PointCollectionController.h"

@implementation PointCollectionController

@synthesize locationManager;
@synthesize pointList;
@synthesize flickrPageController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	pointList = [[NSMutableArray alloc] initWithCapacity: 256];
	
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;

	[self restoreConfiguration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}


- (IBAction)clearPointList:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Points" message:@"Are you sure you want to erase all logged points?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != 1)
		return;
	
	for(int i = 0; i < [pointList count]; i++)
		[[pointList objectAtIndex:i] release];
	
	[pointList removeAllObjects];
	
	[averageAccuracyLabel setText:@"0.0"];
	[pointCountLabel setText:@"0"];		
	
	[self saveConfiguration];
}

- (IBAction)showFlickrPage:(id)sender {
	flickrPageController.pointList = pointList;
	
	[super.navigationController pushViewController:flickrPageController animated:YES];	
}

- (IBAction)beforeUpdateMovementFilter:(id)sender {
	temporaryLocationUpdateIgnore = YES;
}

- (IBAction)afterUpdateMovementFilter:(id)sender {
	temporaryLocationUpdateIgnore = NO;
}

- (IBAction)updateMovementFilter:(id)sender {
	locationManager.distanceFilter = (float)([(UISlider *)sender maximumValue] - [(UISlider *)sender value]);

	[self saveConfiguration];
}

- (IBAction)updateCollectPoints:(id)sender {
	if(! [collectPointsSwitch isOn])
		[locationManager stopUpdatingLocation];	
	else
		[locationManager startUpdatingLocation];	
	
	[self saveConfiguration];
}


- (void)restoreConfiguration {
	// update controllers
	if(flickrPageController.userAuthToken)
		[collectPointsSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"collectPoints"]];
	else
		[collectPointsSwitch setOn:NO];
	
	locationManager.distanceFilter = [[NSUserDefaults standardUserDefaults] floatForKey:@"distanceFilter"];

	NSArray *pointsFromSerialization = [[NSUserDefaults standardUserDefaults] arrayForKey:@"pointList"];
	
	for(int i = 0; i < [pointsFromSerialization count]; i++) {
		[pointList addObject:[[LoggedPoint alloc] initWithSerializedForm:[pointsFromSerialization objectAtIndex:i]]];

		NSLog([[pointList objectAtIndex:[pointList count] - 1] description]);
	}
	
	// update UI
	[averageAccuracyLabel setText: [NSString stringWithFormat:@"%3.1f", [[NSUserDefaults standardUserDefaults] floatForKey:@"pointListAverage"]]];
	[pointCountLabel setText: [NSString stringWithFormat:@"%d", [pointList count]]];		

	[movementFilterSlider setValue:movementFilterSlider.maximumValue - locationManager.distanceFilter];
	
	if([collectPointsSwitch isOn])
		[locationManager startUpdatingLocation];	
}

- (void)saveConfiguration {
	[[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%4.0f", locationManager.distanceFilter] forKey:@"distanceFilter"];
	[[NSUserDefaults standardUserDefaults] setObject:(([collectPointsSwitch isOn]) ? @"YES" : @"NO") forKey:@"collectPoints"];

	NSMutableArray *pointsForSerialization = [[NSMutableArray alloc] initWithCapacity:[pointList count]];
	
	for(int i = 0; i < [pointList count]; i++)
		[pointsForSerialization addObject:[((LoggedPoint *)[pointList objectAtIndex:i]) getSerializedForm]];
	
	[[NSUserDefaults standardUserDefaults] setObject:pointsForSerialization forKey:@"pointList"];
	[[NSUserDefaults standardUserDefaults] setObject:[averageAccuracyLabel text] forKey:@"pointListAverage"];
	
	[pointsForSerialization release];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSLog([NSString stringWithFormat:@"Got location update: %3.8f %3.8f %3.3f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, locationManager.distanceFilter]);
	
	if(newLocation.horizontalAccuracy > 0 && ([collectPointsSwitch isOn] && ! temporaryLocationUpdateIgnore)) {
		if([pointList count] > 0) {
			LoggedPoint *lastLoggedPoint = [pointList objectAtIndex:[pointList count] - 1];
			double duration = [[newLocation timestamp] timeIntervalSinceReferenceDate] - [[lastLoggedPoint timestamp] timeIntervalSinceReferenceDate];
			
			// if the last point came in < 5 seconds ago, discard. 
			if(duration < 5)
				return;			
		}
		
		
		[pointList addObject: [[LoggedPoint alloc] init:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude timestamp:newLocation.timestamp]];

		// update point count
		[pointCountLabel setText: [NSString stringWithFormat:@"%d", [pointList count]]];	
		
		// update accuracy average
		float currentAverage = [[averageAccuracyLabel text] floatValue];
		float newAverage = (newLocation.horizontalAccuracy + (currentAverage * ([pointList count] - 1))) / [pointList count];
		
		[averageAccuracyLabel setText: [NSString stringWithFormat:@"%3.1f", newAverage]];
		
		if([pointList count] % 2 == 0)
			[self saveConfiguration];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[UIApplication sharedApplication].proximitySensingEnabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[UIApplication sharedApplication].proximitySensingEnabled = NO;
}

- (void)dealloc {
	[flickrPageController release];

	[pointList release];
	 
	[locationManager stopUpdatingLocation];
	[locationManager release];

    [super dealloc];
}

@end
