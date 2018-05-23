//
//  NSURLRequest+Data.m
//  TiensClient
//
//  Created by wangfei on 2018/5/3.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "NSURLRequest+Data.h"

static char startTimeIdetifier;
@implementation NSURLRequest (Data)

- (void)setStartTime:(NSDate *)startTime {
    objc_setAssociatedObject(self, &startTimeIdetifier, startTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)startTime {
    return objc_getAssociatedObject(self, &startTimeIdetifier);
}

@end
