// OFHTTPRequest.m
// 
// Copyright (c) 2004-2006 Lukhnos D. Liu (lukhnos {at} gmail.com)
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. Neither the name of ObjectiveFlickr nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "OFHTTPRequest.h"

@interface OFHTTPRequest(OFHTTPRequestInternals)
- (void)dealloc;
- (void)reset;
- (void)internalCancel;
- (void)handleTimeout:(NSTimer*)timer;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
@end

@implementation OFHTTPRequest
+ (OFHTTPRequest*)requestWithDelegate:(id)aDelegate timeoutInterval:(NSTimeInterval)interval
{
	return [[[OFHTTPRequest alloc] initWithDelegate:aDelegate timeoutInterval:interval] autorelease];
}
- (OFHTTPRequest*)initWithDelegate:(id)aDelegate timeoutInterval:(NSTimeInterval)interval
{
	if ((self = [super init])) {
		_delegate = [aDelegate retain];
		_timeoutInterval = (interval > 0) ? interval : OFHTTPDefaultTimeoutInterval;
		
		_closed = YES;
		_connection = nil;
		_timer = nil;
		_userInfo = nil;
		_expectedLength = 0;
		_receivedData = nil;
	}
	return self;
}
- (BOOL)isClosed {
	return _closed;
}
- (void)cancel {
	if (!_closed) return;
	[self internalCancel];
	
	if ([_delegate respondsToSelector:@selector(HTTPRequest:didCancel:)]) {
		[_delegate HTTPRequest:self didCancel:_userInfo];
	}
}
- (BOOL)GET:(NSString*)url userInfo:(id)info {
	if (!_closed) return NO;

	[self reset];
	_userInfo = [info retain];
	_receivedData = [[NSMutableData data] retain];
	
	
	NSString *fixedURL = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
	NSURL *URL = [NSURL URLWithString:fixedURL];
	[fixedURL release];
	
	NSURLRequest *req=[NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_timeoutInterval];
	_connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	if (!_connection) {
		[self reset];
		return NO;
	}
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:_timeoutInterval target:self selector:@selector(handleTimeout:) userInfo:nil repeats:NO];
	[_timer retain];

	return YES;

}
- (BOOL)POST:(NSString*)url data:(NSData*)data separator:(NSString*)separator userInfo:(id)info
{
	if (!_closed) return NO;

	[self reset];
	_userInfo = [info retain];
	_receivedData = [[NSMutableData data] retain];

	NSMutableURLRequest *req=[[[NSMutableURLRequest alloc] init] autorelease];
	[req setURL:[NSURL URLWithString:url]];
	[req setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	[req setTimeoutInterval:_timeoutInterval];
	[req setHTTPMethod:@"POST"];
	
	NSString *header=[NSString stringWithFormat:@"multipart/form-data; boundary=%@", separator];
	[req setValue:header forHTTPHeaderField:@"Content-Type"];
	[req setHTTPBody:data];
	
	_connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	if (!_connection) {
		[self reset];
		return NO;
	}
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:_timeoutInterval target:self selector:@selector(handleTimeout:) userInfo:nil repeats:NO];
	
	// fixed thanks to Cam Stevenson
	[_timer retain];

	return YES;
}
@end

@implementation OFHTTPRequest(OFHTTPRequestInternals)
- (void)dealloc {
	if (!_closed) [self internalCancel];
	
	if (_delegate) [_delegate release];
	if (_connection) [_connection release];
	if (_timer) [_timer release];
	if (_userInfo) [_userInfo release];
	if (_receivedData) [_receivedData release];
	[super dealloc];
}
- (void)internalCancel
{
	[_connection cancel];
	[_timer invalidate];
	_closed = YES;	
}
- (void)reset {
	if (!_closed) [self cancel];
	
	_closed = YES;
	_expectedLength = 0;

	if (_connection) {
		[_connection release];
		_connection = nil;
	}
	if (_timer) {
		if ([_timer isValid]) {
			[_timer invalidate];
		}
		[_timer release];
		_timer = nil;
	}
	if (_userInfo) {
		[_userInfo release];
		_userInfo = nil;
	}
	if (_receivedData) {
		[_receivedData release];
		_receivedData = nil;
	}
}
- (void)handleTimeout:(NSTimer*)timer
{
	if ([_delegate respondsToSelector:@selector(HTTPRequest:didTimeout:)]) {
		[_delegate HTTPRequest:self didTimeout:_userInfo];
	}
	
	[self internalCancel];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[_receivedData setLength:0];
	_expectedLength = (size_t)[response expectedContentLength];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
	[_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_timeoutInterval]];	
	if ([_delegate respondsToSelector:@selector(HTTPRequest:progress:expectedTotal:userInfo:)]) {
		[_delegate HTTPRequest:self progress:[_receivedData length] expectedTotal:_expectedLength userInfo:_userInfo];
	}
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (_timer) [_timer invalidate];
	_closed = YES;

	if ([_delegate respondsToSelector:@selector(HTTPRequest:didFetchData:userInfo:)]) {
		[_delegate HTTPRequest:self didFetchData:_receivedData userInfo:_userInfo];
	}
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (_timer) [_timer invalidate];
	_closed = YES;

	if ([_delegate respondsToSelector:@selector(HTTPRequest:error:userInfo:)]) {
		[_delegate HTTPRequest:self error:error userInfo:_userInfo];
	}
}
@end
