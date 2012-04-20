//
//  FlickrPageController.h
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/17/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "TouchXML.h"
#import "FlickrRequestBroker.h"
#import <UIKit/UIKit.h>

@interface FlickrPageController : UIViewController {
	IBOutlet UIProgressView *progressBar;
	IBOutlet UILabel *progressDescriptionLabel;
	IBOutlet UITableView *progressList;
	IBOutlet UIToolbar *progressToolbar;
	
	FlickrRequestBroker *flickrRequestBroker;
	NSMutableArray *photoList;
	NSMutableArray *pointList;

	NSString *userAuthToken;
	NSString *userNSID;
	NSString *userUsername;
}

- (IBAction)tagPhotos:(id)sender;
- (void)authenticateToFlickr;
- (void)restoreConfiguration;
- (void)saveConfiguration;

#ifdef __FLICKR_PAGE_CONTROLLER_H__
	UITextField *miniTokenInput;
	int taggedPhotoCount = 0;
#endif

@property (nonatomic, retain) FlickrRequestBroker *flickrRequestBroker;
@property (nonatomic, retain) NSMutableArray *photoList;
@property (nonatomic, retain) NSMutableArray *pointList;
@property (nonatomic, retain) NSString *userAuthToken;
@property (nonatomic, retain) NSString *userNSID;
@property (nonatomic, retain) NSString *userUsername;

@end
