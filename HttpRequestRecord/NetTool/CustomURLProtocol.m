//
//  CustomURLProtocol.m
//  HttpRequestRecord
//
//  Created by wangfei on 2018/7/9.
//  Copyright © 2018年 wangfei. All rights reserved.
//

#import "CustomURLProtocol.h"
#import "HttpDataHandle.h"
#import "NSURLRequest+Data.h"
#import "HttpDebugTool.h"
#import "NSURLResponse+Data.h"

#define myProtocolKey   @"JxbHttpProtocol"

@interface CustomURLProtocol()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) NSTimeInterval  startTime;

@end

@implementation CustomURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    
    if ([NSURLProtocol propertyForKey:myProtocolKey inRequest:request] ) {
        return NO;
    }
    
//    if ([[JxbDebugTool shareInstance] arrOnlyHosts].count > 0) {
//        NSString* url = [request.URL.absoluteString lowercaseString];
//        for (NSString* _url in [JxbDebugTool shareInstance].arrOnlyHosts) {
//            if ([url rangeOfString:[_url lowercaseString]].location != NSNotFound)
//                return YES;
//        }
//        return NO;
//    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:myProtocolKey inRequest:mutableReqeust];
    return [mutableReqeust copy];
}

- (void)startLoading {
    self.data = [NSMutableData data];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [[NSURLConnection alloc] initWithRequest:[[self class] canonicalRequestForRequest:self.request] delegate:self startImmediately:YES];
#pragma clang diagnostic pop
    self.startTime = [[NSDate date] timeIntervalSince1970];
}

- (void)stopLoading {
    [self.connection cancel];
    
    @autoreleasepool {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)self.response;
        HttpModel *httpModel = [[HttpModel alloc]init];
        httpModel.host = self.request.URL.host;
        httpModel.path = self.request.URL.path;
        httpModel.absoluteUrl = self.request.URL.absoluteString;
        httpModel.startTime = [self.request.startTime timeIntervalSince1970];
        httpModel.duration = [[NSDate date] timeIntervalSince1970] - [self.request.startTime timeIntervalSince1970];
        httpModel.method = self.request.HTTPMethod;
        httpModel.MIMEType = self.response.MIMEType;
        httpModel.statusCode = [NSString stringWithFormat:@"%ld", httpResponse.statusCode];
        httpModel.requestHeaderFields = self.request.allHTTPHeaderFields;
        httpModel.responseHeaderFields = httpResponse.allHeaderFields;
        if (self.request.HTTPBody) {
            httpModel.requestBody = self.request.HTTPBody;
        }
        httpModel.responseBody = self.data;
        
        if ([HttpDebugTool shareInstance].hostOnlyArr.count > 0) {
            
            for (NSString *onlyHost in [HttpDebugTool shareInstance].hostOnlyArr) {
                if ([[self.request.URL.host lowercaseString] rangeOfString:[onlyHost lowercaseString]].location != NSNotFound) {
                    [[HttpDebugTool shareInstance].dataHandle addHttpData:httpModel];
                }
            }
            
        }else {
            [[HttpDebugTool shareInstance].dataHandle addHttpData:httpModel];
        }
        
    }
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[self client] URLProtocol:self didFailWithError:error];
    self.error = error;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    self.response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self client] URLProtocol:self didLoadData:data];
    [self.data appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[self client] URLProtocolDidFinishLoading:self];
}

@end
