//
//  HttpDataHandle.m
//  TiensClient
//
//  Created by wangfei on 2018/5/7.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "HttpDataHandle.h"

@implementation HttpModel

@end

@implementation HttpDataHandle

- (instancetype)init {
    if (self = [super init]) {
        self.httpDataArr = [NSMutableArray array];
    }
    return self;
}

- (void)addHttpData:(HttpModel *)httpModel {
    
    @synchronized(self.httpDataArr){
        if (httpModel) {
            [self.httpDataArr insertObject:httpModel atIndex:0];
        }
    }
    
}

- (void)clear {
    @synchronized(self.httpDataArr) {
        [self.httpDataArr removeAllObjects];
    }
}

- (NSString *)parseDataToString:(NSData *)data {
    NSString *prettyString = nil;
    
    if (!data || data.length == 0) {
        return @"Empty";
    }else {
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([NSJSONSerialization isValidJSONObject:jsonObject]) {
            prettyString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:NULL] encoding:NSUTF8StringEncoding];
            // NSJSONSerialization escapes forward slashes. We want pretty json, so run through and unescape the slashes.
            prettyString = [prettyString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        } else {
            prettyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
        return prettyString;
    }

}

- (NSString *)parseDicToString:(NSDictionary *)dic {
    NSError *parseError = nil;
    if (!dic) {
        return @"Empty";
    }else {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
        if (parseError) {
            return @"error happened";
        }else {
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSString *prettyStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            return prettyStr;
        }
    }
}

@end
