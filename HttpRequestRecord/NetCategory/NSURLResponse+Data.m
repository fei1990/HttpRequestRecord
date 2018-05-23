//
//  NSURLResponse+Data.m
//  TiensClient
//
//  Created by wangfei on 2018/5/7.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "NSURLResponse+Data.h"
#import <objc/runtime.h>

static char responseDataKey;
@implementation NSURLResponse (Data)

- (NSMutableData *)responseData {
    return objc_getAssociatedObject(self, &responseDataKey);
}

- (void)setResponseData:(NSMutableData *)responseData {
    objc_setAssociatedObject(self, &responseDataKey, responseData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
