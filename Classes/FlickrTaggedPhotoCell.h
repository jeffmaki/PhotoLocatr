//
//  FlickrTaggedPhotoCell.h
//  FlickrPathLogger
//
//  Created by Jeff Maki on 10/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlickrTaggedPhotoCell : UITableViewCell {
	UILabel *photoTitleLabel;
	UILabel *latitudeLabel;
	UILabel *longitudeLabel;
	UIView *photoMetadataView;
}

@property (nonatomic, retain) UILabel *photoTitleLabel;
@property (nonatomic, retain) UILabel *latitudeLabel;
@property (nonatomic, retain) UILabel *longitudeLabel;
@property (nonatomic, retain) UIView *photoMetadataView;

- (void)setCellMetadata:(NSString *)title latitude:(float)latitude longitude:(float)longitude;
- (void)setTaggedState:(BOOL)tagged;

@end
