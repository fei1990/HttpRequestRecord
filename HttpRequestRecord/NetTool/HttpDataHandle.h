//
//  HttpDataHandle.h
//  TiensClient
//
//  Created by wangfei on 2018/5/7.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpModel : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *absoluteUrl;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *MIMEType;
@property (nonatomic, copy) NSString *statusCode;
@property (nonatomic, strong) NSDictionary *requestHeaderFields;
@property (nonatomic, strong) NSDictionary *responseHeaderFields;
@property (nonatomic, strong) NSData *requestBody;
@property (nonatomic, strong) NSData *responseBody;

@end

@interface HttpDataHandle : NSObject

@property (nonatomic, strong) NSMutableArray *httpDataArr;

- (void)addHttpData:(HttpModel *)httpModel;

- (void)clear;

- (NSString *)parseDataToString:(NSData *)data;

- (NSString *)parseDicToString:(NSDictionary *)dic;

@end
