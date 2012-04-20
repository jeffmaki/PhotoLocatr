//
//  FlickrRequestBroker.h
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OFHTTPRequest.h"
#import "CocoaCryptoHashing.h"
#import "TouchXML.h"
#import <UIKit/UIKit.h>

@interface FlickrRequestBroker : NSObject {
	NSString *apiKey;
	NSString *sharedSecret;

	id delegate;
}

@property (nonatomic, retain) id delegate;

- (id)init;
- (void)authenticateWithMiniToken:(NSString *)mini_token;
- (void)getPhotosTakenWithinDateRange:(NSString *)authToken userId:(NSString *)userId  start:(NSDate *)start end:(NSDate *)end;
- (void)setGeoLocation:(NSString *)authToken photoId:(NSString *)photoId latitude:(float)latitude longitude:(float)longitude;
- (BOOL)responseContainsError:(CXMLElement *)rootElement;
- (void)HTTPRequest:(OFHTTPRequest*)request didCancel:(id)userinfo;
- (void)HTTPRequest:(OFHTTPRequest*)request didFetchData:(NSData*)data userInfo:(id)userinfo;
- (void)HTTPRequest:(OFHTTPRequest*)request didTimeout:(id)userinfo;
- (void)HTTPRequest:(OFHTTPRequest*)request error:(NSError*)err userInfo:(id)userinfo;
- (void)HTTPRequest:(OFHTTPRequest*)request progress:(size_t)receivedBytes expectedTotal:(size_t)total userInfo:(id)userinfo;
- (NSString *)getAPIRequestURL:(NSString *)endpoint method:(NSString *)method params:(NSDictionary *)params;
- (void)sendRequestToAPI:(NSString *)method params:(NSDictionary *)params;
NSInteger alphabeticSort(id s1, id s2, void *context);
@end

@interface NSObject (FlickrRequestBrokerDelegate)
- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker receivedFullToken:(NSString*)token nsid:(NSString *)nsid username:(NSString *)username;
- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker receivedPhotoSearchResults:(NSMutableArray *)photos;
- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker photoWasGeoTagged:(NSString *)photoId;
- (void)FlickrRequestBroker:(FlickrRequestBroker *)broker error:(NSString *)error;
@end
