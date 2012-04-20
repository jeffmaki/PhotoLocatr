//
//  FlickrPathLoggerAppDelegate.h
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/18/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPathLoggerAppDelegate : NSObject <UIApplicationDelegate> {
    IBOutlet UIWindow *window;
	IBOutlet UIViewController *mainPage;
	IBOutlet UINavigationController *navigationController;	
}

@property(nonatomic, retain) UIWindow *window;
@property(nonatomic, retain) UIViewController *mainPage;
@property(nonatomic, retain) UINavigationController *navigationController;

@end

