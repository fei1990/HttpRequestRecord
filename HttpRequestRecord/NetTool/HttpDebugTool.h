//
//  HttpDebugTool.h
//  TiensClient
//
//  Created by wangfei on 2018/5/7.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HttpDataHandle.h"
#import "HttpURLVC.h"
#import "MemoryHelper.h"

#define kDefaultMainColor [UIColor redColor]

@protocol HttpDebugDelegate<NSObject>

- (NSData *)decriptData:(NSData *)data;

@end

@interface HttpDebugTool : NSObject

@property (nonatomic, strong) HttpDataHandle *dataHandle;

+ (instancetype)shareInstance;

/**
 只处理允许的host，默认处理所有URL
 */
@property (nonatomic, strong) NSArray *hostOnlyArr;

/**
 主色调
 */
@property (nonatomic, strong) UIColor *mainColor;

@property (nonatomic, weak) id<HttpDebugDelegate>delegate;

/**
 打开debug工具
 */
- (void)debugToolEnabled;

@end


@interface HttpDebugWindow : UIWindow

@end
