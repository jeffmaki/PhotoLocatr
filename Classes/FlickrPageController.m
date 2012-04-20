//
//  FlickrPageController.m
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#define __FLICKR_PAGE_CONTROLLER_H__

#import "FlickrTaggedPhotoCell.h"
#import "LoggedPoint.h"
#import "FlickrPageController.h"
#import "FlickrAPIPhoto.h"


@implementation FlickrPageController

@synthesize pointList;
@synthesize photoList;
@synthesize flickrRequestBroker;
@synthesize userAuthToken;
@synthesize userNSID;
@synthesize userUsername;

- (void)viewDidLoad {
    [super viewDidLoad];

	flickrRequestBroker = [[FlickrRequestBroker alloc] init];
	flickrRequestBroker.delegate = self;	

	[self restoreConfiguration];

	if(! userNSID || ! userAuthToken || ! userUsername)
		[self authenticateToFlickr];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)authenticateToFlickr {
	UIAlertView *miniTokenAlert = [[UIAlertView alloc] initWithTitle:@"Authenticate To Flickr" message:@"Enter your Flickr mini token below:\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Authenticate", nil];
	miniTokenAlert.tag = 2;
	
	UIButton *urlLabel = [[UIButton alloc] initWithFrame:CGRectMake(172.0, 76.0, 100.0, 25.0)];
	[urlLabel setImage:[UIImage imageNamed:@"Get-Token.png"] forState:UIControlStateNormal];
	[miniTokenAlert addSubview:urlLabel];

	[urlLabel addTarget:self action:@selector(getTokenButtonPress:) forControlEvents:UIControlEventTouchUpInside];
	
	miniTokenInput = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 75.0, 155.0, 25.0)];
	[miniTokenInput setBackgroundColor:[UIColor whiteColor]];
	[miniTokenInput setBorderStyle:UITextBorderStyleLine];
	miniTokenInput.keyboardAppearance = UIKeyboardAppearanceAlert;
	miniTokenInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	miniTokenInput.tag = 31337;
	miniTokenInput.placeholder = @"XXX-XXX-XXX";
	[miniTokenAlert addSubview:miniTokenInput];

	CGAffineTransform alertTransform = CGAffineTransformMakeTranslation(0.0, 120.0);
	[miniTokenAlert setTransform:alertTransform];	

	[miniTokenAlert show];
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	[miniTokenInput becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex != 1)
		return;
	
	if(alertView.tag == 2) // auth token accept
		[flickrRequestBroker authenticateWithMiniToken:[miniTokenInput text]];
	else if(alertView.tag == 1) // reauth yes/no
		[self authenticateToFlickr];
}


- (void)restoreConfiguration {
	// update controllers
	userAuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"userAuthToken"];
	userNSID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userNSID"];
	userUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"userUsername"];
}

- (void)saveConfiguration {
	[[NSUserDefaults standardUserDefaults] setObject:userAuthToken forKey:@"userAuthToken"];
	[[NSUserDefaults standardUserDefaults] setObject:userNSID forKey:@"userNSID"];
	[[NSUserDefaults standardUserDefaults] setObject:userUsername forKey:@"userUsername"];
}

- (void)hideProgressUI {
	if(progressToolbar.hidden != YES) {
		CGRect newFrame = progressList.frame;
		
		newFrame.size.height += progressToolbar.frame.size.height;
		[progressList setFrame:newFrame];
	
		progressToolbar.hidden = YES;
	}
}

- (void)showProgressUI:(NSString *)message progress:(float)progress {
	if(progressToolbar.hidden != NO) {
		CGRect newFrame = progressList.frame;
	
		newFrame.size.height -= progressToolbar.frame.size.height;
		[progressList setFrame:newFrame];
	
		progressToolbar.hidden = NO;
	}
	
	[progressBar setProgress:progress];

	progressDescriptionLabel.font = [UIFont systemFontOfSize:11.00];
	[progressDescriptionLabel setText:message];
}


- (IBAction)tagPhotos:(id)sender {	
	if(! userNSID || ! userAuthToken || ! userUsername) {
		[self authenticateToFlickr];
		
		return;
	}

	if([pointList count] < 2) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Tagging Error" message:@"You must have at least two points logged before you can tag photos." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
		[alert show];

		return;
	}
	
	taggedPhotoCount = 0;
	photoList = [[NSMutableDictionary alloc] initWithCapacity:256];
	
	[self showProgressUI:@"Querying Flickr for photos..." progress:0.1];
	
	NSDate *startDate = [(CLLocation *)[pointList objectAtIndex:0] timestamp];
	NSDate *endDate = [(CLLocation *)[pointList objectAtIndex:[pointList count] - 1] timestamp];

	[flickrRequestBroker getPhotosTakenWithinDateRange:userAuthToken userId:userNSID start:startDate end:endDate];	
}

- (IBAction)getTokenButtonPress:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://photolocatr.jeffmaki.com/auth"]]; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
		return [photoList count];
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FlickrAPIPhoto *p = [photoList objectAtIndex:indexPath.row];
	
	if(! p)
		return nil;

	FlickrTaggedPhotoCell *cell = (FlickrTaggedPhotoCell *)[progressList dequeueReusableCellWithIdentifier:@"flickrTaggedPhotoCell"];
	
	if (cell == nil)
		 cell = [[[FlickrTaggedPhotoCell alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 75) reuseIdentifier:@"flickrTaggedPhotoCell"] autorelease];
		
	[cell setCellMetadata:p.title latitude:p.latitude longitude:p.longitude];
	
	if(p.wasTagged)
		[cell setTaggedState:YES];

	return cell;
}


- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker receivedFullToken:(NSString*)token nsid:(NSString *)nsid username:(NSString *)username {
	self.userAuthToken = token;
	self.userNSID = nsid;
	self.userUsername = username;
		
	[self saveConfiguration];
}

- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker photoWasGeoTagged:(NSString *)photoId {
	[self showProgressUI:@"Geotaging photos..." progress:[progressBar progress] + (.5 / [photoList count])];

	FlickrAPIPhoto *p = nil;
	int p_i = 0;
	
	for(p_i = 0; p_i < [photoList count]; p_i++) {
		p = [photoList objectAtIndex:p_i];

		if(p.photoId == photoId)
			break;
	}
	
	if(! p)
		return;
	
	p.wasTagged = YES;
	taggedPhotoCount++;
	

	NSIndexPath *cellPath = [NSIndexPath indexPathForRow:p_i inSection:0];
	FlickrTaggedPhotoCell *c = (FlickrTaggedPhotoCell *)[progressList cellForRowAtIndexPath:cellPath];

	if(c)
		[c setTaggedState:YES];

	
	// perform actions when all photos have been tagged
	if(taggedPhotoCount == [photoList count]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Tagging Result" message:[NSString stringWithFormat:@"%d photo(s) were tagged on Flickr.", taggedPhotoCount] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
		[alert show];

		[self hideProgressUI];
	}
}

- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker receivedPhotoSearchResults:(NSMutableArray *)photos {
	photoList = photos;

	// update table
	[progressList reloadData];
	
	[self showProgressUI:@"Calculating photo locations..." progress:0.5];

	int photoListKeys_i = 0;		
	for(int i = 1; i < [pointList count]; i++) {
		LoggedPoint *locationBefore = [pointList objectAtIndex:i - 1];
		LoggedPoint *locationAfter = [pointList objectAtIndex:i];

		// locations that are the same should be skipped
		if([locationBefore.timestamp timeIntervalSinceReferenceDate] == [locationAfter.timestamp timeIntervalSinceReferenceDate])
			continue;
		
		// if points in the database are > 20 min. apart, skip them--the user probably turned his/her phone off and now it's back on somewhere else (we should have received a GPS location update within that period)
		if(abs([locationAfter.timestamp timeIntervalSinceReferenceDate] - [locationBefore.timestamp timeIntervalSinceReferenceDate]) > 60 * 20)
			continue;

		
		NSLog([NSString stringWithFormat:@"POINT RANGE: %@ => %@", [locationBefore.timestamp description], [locationAfter.timestamp description]]);
		

		while(photoListKeys_i < [photoList count]) {
			FlickrAPIPhoto *p = [photoList objectAtIndex:photoListKeys_i];

			NSString *photoID = p.photoId;
			NSDate *dateTaken = p.dateTaken;
			
			// next range--outer loop advances to next range
			if([dateTaken timeIntervalSinceReferenceDate] >= [[locationAfter timestamp] timeIntervalSinceReferenceDate])
				break;
			
			float latitudeChange = locationAfter.latitude - locationBefore.latitude;
			float longitudeChange = locationAfter.longitude - locationBefore.longitude;
			double timeChange = [locationAfter.timestamp timeIntervalSinceReferenceDate] - [locationBefore.timestamp timeIntervalSinceReferenceDate];
			
			float ratio = ([dateTaken timeIntervalSinceReferenceDate] - [locationBefore.timestamp timeIntervalSinceReferenceDate]) / timeChange;
					
			float photoLatitude = locationBefore.latitude + (latitudeChange * ratio);
			float photoLongitude = locationBefore.longitude + (longitudeChange * ratio);

			
			NSLog([NSString stringWithFormat:@"PHOTO RATIO CALC: %@ %d: %@ <= %@ => %@", photoID, photoListKeys_i, locationBefore.timestamp, dateTaken, locationAfter.timestamp]);

			
			// save in object for use by progressList UITableView data rendering function
			p.latitude = photoLatitude;
			p.longitude = photoLongitude;
			
			[flickrRequestBroker setGeoLocation:userAuthToken photoId:photoID latitude:photoLatitude longitude:photoLongitude];
			
			usleep(1000);
			
			photoListKeys_i++;
		}
		
	}
	
	// if we had zero photos returned from Flickr
	if([photos count] <= 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tagging Status" message:@"No photos without a geolocation were found on Flickr." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self hideProgressUI];
	}
}

- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker error:(NSString *)error {
	[self hideProgressUI];

	UIAlertView *alert = nil;
	
	if([error compare:@"invalid auth token"] == 0) {
		alert = [[[UIAlertView alloc] initWithTitle:@"Authentication Error" message:[NSString stringWithFormat:@"Your Flickr credentials were rejected. Would you like to re-enter them?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes, re-enter", nil] autorelease];
		alert.tag = 1;
	} else
		alert = [[[UIAlertView alloc] initWithTitle:@"Network Error" message:[NSString stringWithFormat:@"An error occured while processing your request (%@). Please try your request again.", error] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] autorelease];
	
	[alert show];
}


- (void)dealloc {
	[photoList release];
	[flickrRequestBroker release];
	[userAuthToken release];
	[userNSID release];
	[userUsername release];
	
    [super dealloc];
}

@end
