//
//  FlickrPathLoggerAppDelegate.m
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/18/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "FlickrPathLoggerAppDelegate.h"

@implementation FlickrPathLoggerAppDelegate

@synthesize window;
@synthesize mainPage;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	navigationController = [[UINavigationController alloc] initWithRootViewController: mainPage];
	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[navigationController release];
	[mainPage release];
    [window release];
    [super dealloc];
}

@end
