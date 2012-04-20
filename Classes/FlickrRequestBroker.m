//
//  FlickrRequestBroker.m
//  FlickrPathLogger
//
//  Created by Jeff Maki on 9/19/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FlickrAPIPhoto.h"
#import "FlickrRequestBroker.h"

@interface FlickrAPICall : NSObject {
	NSString *method;
	NSDictionary *params;
}

@property (nonatomic,retain) NSString *method;
@property (nonatomic,retain) NSDictionary *params;
@end

@implementation FlickrAPICall
@synthesize method;
@synthesize params;
@end

@implementation FlickrRequestBroker

@synthesize delegate;

- (id)init {
	apiKey = @"b6f5f515a35bcf946dd093f108069ec7";
	sharedSecret = @"89893b859daa687a";

	return self;
}

- (void)authenticateWithMiniToken:(NSString *)mini_token {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	[params setObject:mini_token forKey:@"mini_token"];
	
	[self sendRequestToAPI: @"flickr.auth.getFullToken" params:params];
}

- (void)getPhotosTakenWithinDateRange:(NSString *)authToken userId:(NSString *)userId  start:(NSDate *)start end:(NSDate *)end {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	[params setObject:authToken forKey:@"auth_token"];
	[params setObject:userId forKey:@"user_id"];
	[params setObject:@"date-taken-asc" forKey:@"sort"];
	[params setObject:@"date_taken,geo" forKey:@"extras"];

	NSDateFormatter *mysqlDateFormat = [[NSDateFormatter alloc] init];
	[mysqlDateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	[params setObject:[mysqlDateFormat stringFromDate:start] forKey:@"min_taken_date"];
	[params setObject:[mysqlDateFormat stringFromDate:end] forKey:@"max_taken_date"];
	
	[self sendRequestToAPI: @"flickr.photos.search" params:params];	

	[mysqlDateFormat release];
}

- (void)setGeoLocation:(NSString *)authToken photoId:(NSString *)photoId latitude:(float)latitude longitude:(float)longitude {	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	[params setObject:authToken forKey:@"auth_token"];
	[params setObject:photoId forKey:@"photo_id"];
	[params setObject:[NSString stringWithFormat:@"%3.8f", latitude] forKey:@"lat"];
	[params setObject:[NSString stringWithFormat:@"%3.8f", longitude] forKey:@"lon"];

	NSLog([NSString stringWithFormat:@"Tagging photo %@ with location: %3.8f %3.8f", photoId, latitude, longitude]);	

	[self sendRequestToAPI: @"flickr.photos.geo.setLocation" params:params];
}


- (BOOL)responseContainsError:(CXMLElement *)rootElement {
	if(rootElement && [[rootElement nodesForXPath:@"//err" error:nil] count] > 0)
		return true;
	else
		return false;
}


- (void)HTTPRequest:(OFHTTPRequest*)request didFetchData:(NSData*)data userInfo:(id)userinfo {
	NSString *serverResponse = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

	FlickrAPICall *callInfo = (FlickrAPICall *)userinfo;
	NSString *method = callInfo.method;
	NSDictionary *params = callInfo.params;	
	
	NSLog(serverResponse);
	
	CXMLDocument *responseXML = [[CXMLDocument alloc] initWithXMLString:serverResponse options:0 error:nil];

	// check for errors
	if([self responseContainsError:[responseXML rootElement]]) {
		NSArray *errorElement = [responseXML nodesForXPath:@"//err" error:nil];
		NSString *message = [[[errorElement objectAtIndex:0] attributeForName:@"msg"] stringValue];

		if ([delegate respondsToSelector:@selector(FlickrRequestBroker:error:)])
			[delegate FlickrRequestBroker:self error:[message lowercaseString]];
		
		return;
	}
	
	// parse methods, call handler on delegate
	if([method isEqualToString:@"flickr.auth.getFullToken"]) {
		NSArray *tokenElement = [responseXML nodesForXPath:@"//token" error:nil];
		NSString *token = [[tokenElement objectAtIndex:0] stringValue];
			
		NSArray *userElement = [responseXML nodesForXPath:@"//user" error:nil];
		NSString *nsid = [[[userElement objectAtIndex:0] attributeForName:@"nsid"] stringValue];
		NSString *username = [[[userElement objectAtIndex:0] attributeForName:@"username"] stringValue];
				
		if ([delegate respondsToSelector:@selector(FlickrRequestBroker:receivedFullToken:nsid:username:)])
			[delegate FlickrRequestBroker:self receivedFullToken:token nsid:nsid username:username];
			
			
	} else if([method isEqualToString:@"flickr.photos.search"]) {
		NSArray *photoElements = [responseXML nodesForXPath:@"//photo" error:nil];
		NSMutableArray *photosOut = [[NSMutableArray alloc] init];
		
		for(int i = 0; i < [photoElements count]; i++) {
			NSString *photoId = [[[photoElements objectAtIndex:i] attributeForName:@"id"] stringValue];
			NSString *title = [[[photoElements objectAtIndex:i] attributeForName:@"title"] stringValue];
			NSDate *dateTaken = [NSDate dateWithNaturalLanguageString:(NSString *)[[[photoElements objectAtIndex:i] attributeForName:@"datetaken"] stringValue]];

			NSString *latitude = [[[photoElements objectAtIndex:i] attributeForName:@"latitude"] stringValue];
			NSString *longitude = [[[photoElements objectAtIndex:i] attributeForName:@"longitude"] stringValue];
			NSString *accuracy = [[[photoElements objectAtIndex:i] attributeForName:@"accuracy"] stringValue];
			
			// only add if there's no geolocation information already set
			if([latitude isEqualToString:@"0"] && [longitude isEqualToString:@"0"] && [accuracy isEqualToString:@"0"])
				[photosOut addObject:[[FlickrAPIPhoto alloc] init:photoId dateTaken:dateTaken title:title]];
		}
		
		if ([delegate respondsToSelector:@selector(FlickrRequestBroker:receivedPhotoSearchResults:)])
			[delegate FlickrRequestBroker:self receivedPhotoSearchResults:photosOut];
		
		
	} else if([method isEqualToString:@"flickr.photos.geo.setLocation"]) {
		if ([delegate respondsToSelector:@selector(FlickrRequestBroker:photoWasGeoTagged:)])
			[delegate FlickrRequestBroker:self photoWasGeoTagged:[params objectForKey:@"photo_id"]];

	
	}

	[callInfo release];
}

- (void)HTTPRequest:(OFHTTPRequest*)request didTimeout:(id)userinfo {
	if ([delegate respondsToSelector:@selector(FlickrRequestBroker:error:)])
		[delegate FlickrRequestBroker:self error:@"request timed out"];
	
	[request release];
}

- (void)HTTPRequest:(OFHTTPRequest*)request didCancel:(id)userinfo {
	[request release];	
}

- (void)HTTPRequest:(OFHTTPRequest*)request error:(NSError*)err userInfo:(id)userinfo {
	if ([delegate respondsToSelector:@selector(FlickrRequestBroker:error:)])
		[delegate FlickrRequestBroker:self error:[err localizedDescription]];
	
	[request release];	
}

- (void)HTTPRequest:(OFHTTPRequest*)request progress:(size_t)receivedBytes expectedTotal:(size_t)total userInfo:(id)userinfo {
}

- (NSString *)getAPIRequestURL:(NSString *)endpoint method:(NSString *)method params:(NSDictionary *)params {
	NSMutableDictionary *hashMembers = [[NSMutableDictionary alloc] init];
	
	[hashMembers setObject:apiKey forKey:@"api_key"];

	if(method)
		[hashMembers setObject:method forKey:@"method"];
	
	[hashMembers addEntriesFromDictionary:params];
	
	NSString *requestURL = endpoint;
	NSString *signature = [sharedSecret copy];
	
	NSArray *sortedKeys = [[NSMutableArray arrayWithArray:[hashMembers allKeys]] sortedArrayUsingFunction:(NSInteger (*)(id, id, void *))alphabeticSort context:nil];
	
	for(int i = 0; i < [sortedKeys count]; i++) {
		NSString *key = [sortedKeys objectAtIndex:i];
		NSString *value = [hashMembers objectForKey:key];
		
		signature = [signature stringByAppendingFormat:@"%@%@", key, value];
		
		if(i == 0)
			requestURL = [requestURL stringByAppendingFormat:@"?%@=%@", key, value];
		else
			requestURL = [requestURL stringByAppendingFormat:@"&%@=%@", key, value];
	}
	
	requestURL = [requestURL stringByAppendingFormat:@"&api_sig=%@", [signature md5HexHash]];

	NSLog(requestURL);
	
	return requestURL;
}

- (void)sendRequestToAPI:(NSString *)method params:(NSDictionary *)params {
	NSString *requestURL = [self getAPIRequestURL:@"http://api.flickr.com/services/rest/" method:method params:params];
	
	FlickrAPICall *callInfo = [[FlickrAPICall alloc] init];
	callInfo.method = method;
	callInfo.params = params;
	
	OFHTTPRequest *apiRequest = [[OFHTTPRequest alloc] initWithDelegate:self timeoutInterval:120];
	[apiRequest GET: requestURL userInfo:callInfo];
}	

NSInteger alphabeticSort(id s1, id s2, void *context) {
	return [s1 localizedCaseInsensitiveCompare:s2];	
}

@end
