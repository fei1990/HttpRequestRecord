//
//  ViewController.m
//  HttpRequestRecord
//
//  Created by wangfei on 2018/5/23.
//  Copyright © 2018年 wangfei. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(id)sender {
    
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//
//    AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
//    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
//
//    manager.responseSerializer = serializer;
//
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://developer.qiniu.com/docs/v6/api/overview/up/response/img/upload-with-callback.png"]] completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"response : %@", response);
//    }];
//    [dataTask resume];
    
    NSString *url = @"https://open.qyer.com/qyer/bbs/forum_thread_list?client_id=qyer_android&client_secret=9fcaae8aefc4f9ac4915&forum_id=1&type=1&count=10&page=1&delcache=0";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:configuration];
    // 基本网络请求
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", data);
        if (!error) {

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

            if (httpResponse.statusCode == 200) {

                NSString *string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
                NSLog(@"%@",string);
            }
        }
    }];
    
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        NSLog(@"%@", data);
//        if (!error) {
//
//            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//
//            if (httpResponse.statusCode == 200) {
//
//                NSString *string = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
//                NSLog(@"%@",string);
//            }
//        }
//    }];
    
    [dataTask resume];
    
}

@end
