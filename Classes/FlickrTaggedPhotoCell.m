//
//  FlickrTaggedPhotoCell.m
//  FlickrPathLogger
//
//  Created by Jeff Maki on 10/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FlickrAPIPhoto.h"
#import "FlickrTaggedPhotoCell.h"


@implementation FlickrTaggedPhotoCell

@synthesize photoTitleLabel;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize photoMetadataView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		photoTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 190, 30)];
		photoTitleLabel.font = [UIFont boldSystemFontOfSize:20.0];
		photoTitleLabel.text = @"";
		[self.contentView addSubview:photoTitleLabel];
		
		photoMetadataView = [[UIView alloc] initWithFrame:CGRectMake(170, 3, 160, 30)];
		photoMetadataView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		
		UILabel *latitudeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 50, 12)];
		latitudeNameLabel.textAlignment = UITextAlignmentRight;
		latitudeNameLabel.textColor = [UIColor grayColor];
		latitudeNameLabel.text = @"latitude:";
		latitudeNameLabel.font = [UIFont systemFontOfSize:10.0];
		[photoMetadataView addSubview:latitudeNameLabel];
		
		latitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 70, 10)];
		latitudeLabel.textColor = [UIColor grayColor];
		latitudeLabel.text = @"";
		latitudeLabel.font = [UIFont systemFontOfSize:10.0];
		[photoMetadataView addSubview:latitudeLabel];

		UILabel *longitudeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 50, 12)];
		longitudeNameLabel.textAlignment = UITextAlignmentRight;
		longitudeNameLabel.textColor = [UIColor grayColor];
		longitudeNameLabel.text = @"longitude:";
		longitudeNameLabel.font = [UIFont systemFontOfSize:10.0];
		[photoMetadataView addSubview:longitudeNameLabel];
		
		longitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 20, 70, 10)];
		longitudeLabel.textColor = [UIColor grayColor];
		longitudeLabel.text = @"";
		longitudeLabel.font = [UIFont systemFontOfSize:10.0];
		[photoMetadataView addSubview:longitudeLabel];
		
		[self.contentView addSubview:photoMetadataView];
	
		self.userInteractionEnabled = NO;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	return self;
}

- (void)setCellMetadata:(NSString *)title latitude:(float)latitude longitude:(float)longitude {
	photoTitleLabel.text = title;		
	latitudeLabel.text = [NSString stringWithFormat:@"%3.6f", latitude];
	longitudeLabel.text = [NSString stringWithFormat:@"%3.6f", longitude];
}

- (void)setTaggedState:(BOOL)tagged {
	if(tagged)
		self.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	[self setTaggedState:NO];	
	[self setCellMetadata:@"" latitude:0.00 longitude:0.00];
}

- (void)dealloc {
    [super dealloc];
}

@end
