//
//  NSURLSession+NetHook.m
//  TiensClient
//
//  Created by wangfei on 2018/4/26.
//  Copyright © 2018年 fei.wang. All rights reserved.
//

#import "NSURLSession+NetHook.h"
#import <objc/runtime.h>
#import "NSURLRequest+Data.h"
#import "NSURLResponse+Data.h"
#import "HttpDataHandle.h"
#import "HttpDebugTool.h"

@implementation NSURLSession (NetHook)

void swizzled_BlockMethod(Class cls, SEL originSel, SEL swizzledSel) {
    
    Method originMethod = class_getInstanceMethod(cls, originSel);
    
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    
    BOOL succes = class_addMethod(cls, originSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (succes) {
        class_replaceMethod(cls, swizzledSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    }else {
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
    
}

static void swizzled_Method(Class originalClass, SEL originalSel, Class replaceClass, SEL replaceSel) {

    Method originalMethod = NULL;
    Method replaceMethod = NULL;

    originalMethod = class_getClassMethod(originalClass, originalSel);
    replaceMethod = class_getClassMethod(replaceClass, replaceSel);

    if (!originalMethod || !replaceMethod) {
        return;
    }
    IMP originalIMP = method_getImplementation(originalMethod);
    IMP replaceIMP = method_getImplementation(replaceMethod);

    const char *originalType = method_getTypeEncoding(originalMethod);
    const char *replaceType = method_getTypeEncoding(replaceMethod);

    //注意这里的class_replaceMethod方法，一定要先将替换方法的实现指向原实现，然后再将原实现指向替换方法，否则如果先替换原方法指向替换实现，那么如果在执行完这一句瞬间，原方法被调用，这时候，替换方法的实现还没有指向原实现，那么现在就造成了死循环
    Class originalMetaClass = objc_getMetaClass(class_getName(originalClass));
    Class replaceMetaClass = objc_getMetaClass(class_getName(replaceClass));
    class_replaceMethod(replaceMetaClass,replaceSel,originalIMP,originalType);
    class_replaceMethod(originalMetaClass,originalSel,replaceIMP,replaceType);
}

+ (NSURLSession *)swizzled_sessionWithConfiguration: (NSURLSessionConfiguration *)configuration delegate: (id<NSURLSessionDelegate>)delegate delegateQueue: (NSOperationQueue *)queue {
//    configuration.protocolClasses = @[[WFUrlProtocol class]];
    if (delegate) {
        
        //hook NSURLSessionTaskDelegate
        swizzled_Delegate_Method([delegate class], @selector(URLSession: task:
                                                             didSendBodyData:
                                                             totalBytesSent:
                                                             totalBytesExpectedToSend:), [self class], @selector(swizzled_URLSession: task:
                                                                                                                 didSendBodyData:
                                                                                                                 totalBytesSent:
                                                                                                                 totalBytesExpectedToSend:));
        swizzled_Delegate_Method([delegate class], @selector(URLSession: task: didCompleteWithError:), [self class], @selector(swizzled_URLSession: task: didCompleteWithError:));
        
        
        //hook NSURLSessionDataDelegate
        swizzled_Delegate_Method([delegate class], @selector(URLSession:dataTask:didReceiveResponse:completionHandler:), [self class], @selector(swizzled_URLSession:dataTask:didReceiveResponse:completionHandler:));
        swizzled_Delegate_Method([delegate class], @selector(URLSession:dataTask:didReceiveData:), [self class], @selector(swizzled_URLSession:dataTask:didReceiveData:));
//        swizzled_Delegate_Method([delegate class], @selector(URLSession:dataTask:didBecomeDownloadTask:), [self class], @selector(swizzled_URLSession:dataTask:didBecomeDownloadTask:));
//        swizzled_Delegate_Method([delegate class], @selector(URLSession:dataTask:didBecomeStreamTask:), [self class], @selector(swizzled_URLSession:dataTask:didBecomeStreamTask:));
        
        //hook NSURLSessionDownloadDelegate
        
    }

    return [self swizzled_sessionWithConfiguration: configuration delegate: delegate delegateQueue: queue];
}

//hook delegate方法
static void swizzled_Delegate_Method(Class originalClass, SEL originalSel, Class replaceClass, SEL replaceSel) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    Method replaceMethod = class_getInstanceMethod(replaceClass, replaceSel);
    if (!originalMethod) {//没有实现delegate 方法
        return;
    }
    BOOL didAddReplaceMethod = class_addMethod(originalClass, replaceSel, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod));

    if (didAddReplaceMethod) {
        Method newMethod = class_getInstanceMethod(originalClass, replaceSel);
        method_exchangeImplementations(originalMethod, newMethod);
//        class_replaceMethod(replaceClass, replaceSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    }else {
        
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        Class cls = [self class];

        //hook NSURLSession 代理方法
        swizzled_Method(cls, @selector(sessionWithConfiguration:delegate:delegateQueue:), cls, @selector(swizzled_sessionWithConfiguration:delegate:delegateQueue:));
        
        //hook NSURLSession block
        swizzled_BlockMethod(cls, @selector(dataTaskWithRequest: completionHandler:), @selector(swizzled_dataTaskWithRequest: completionHandler:));
        

    });
}

#pragma mark - NSURLSession block
- (NSURLSessionDataTask *)swizzled_dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    
    //记录开始请求时间
    request.startTime = [NSDate date];
    
    return [self swizzled_dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)response;
        
        httpURLResponse.responseData = (NSMutableData *)data;
        
        [self handleResponse:httpURLResponse withRequest:request];
        
        if (completionHandler) {
            completionHandler(data, response, error);
        }
        
    }];
}

#pragma mark - NSURLSessionDelegate

#pragma mark - NSURLSessionTaskDelegate
- (void)swizzled_URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
            didSendBodyData:(int64_t)bytesSent
             totalBytesSent:(int64_t)totalBytesSent
   totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    //记录开始请求时间
    task.originalRequest.startTime = [NSDate date];
    
    [self swizzled_URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    
}

/*
 3.当请求完成之后调用该方法
 不论是请求成功还是请求失败都调用该方法，如果请求失败，那么error对象有值，否则那么error对象为空
 */
- (void)swizzled_URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    
    [self swizzled_URLSession:session task:task didCompleteWithError:error];
    
    NSURLRequest *request = task.originalRequest;
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    
    [self handleResponse:response withRequest:request];
    
}

#pragma mark - NSURLSessionDataDelegate
//- (void)swizzled_URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
//    [self swizzled_URLSession:session dataTask:dataTask didBecomeStreamTask:streamTask];
//}
//
//- (void)swizzled_URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//      didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
//    [self swizzled_URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask];
//}

/*
 2.当接收到服务器返回的数据时调用
 该方法可能会被调用多次
 */
- (void)swizzled_URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    [self swizzled_URLSession:session dataTask:dataTask didReceiveData:data];
    
    if (dataTask.response.responseData == nil) {
        dataTask.response.responseData = [[NSMutableData alloc]init];
    }
    
    if (data) {
        [dataTask.response.responseData appendData:data];
    }
    
}

/*
 1.当接收到服务器响应的时候调用
 session：发送请求的session对象
 dataTask：根据NSURLSession创建的task任务
 response:服务器响应信息（响应头）
 completionHandler：通过该block回调，告诉服务器端是否接收返回的数据
 */
- (void)swizzled_URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
         didReceiveResponse:(NSURLResponse *)response
          completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [self swizzled_URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

#pragma mark - NSURLSessionDownloadDelegate

#pragma mark - NSURLSessionStreamDelegate

#pragma mark - handle response data
- (void)handleResponse:(NSHTTPURLResponse *)response withRequest:(NSURLRequest *)request {
    
    @autoreleasepool {
        
        HttpModel *httpModel = [[HttpModel alloc]init];
        httpModel.host = request.URL.host;
        httpModel.path = request.URL.path;
        httpModel.absoluteUrl = request.URL.absoluteString;
        httpModel.startTime = [request.startTime timeIntervalSince1970];
        httpModel.duration = [[NSDate date] timeIntervalSince1970] - [request.startTime timeIntervalSince1970];
        httpModel.method = request.HTTPMethod;
        httpModel.MIMEType = response.MIMEType;
        httpModel.statusCode = [NSString stringWithFormat:@"%ld", response.statusCode];
        httpModel.requestHeaderFields = request.allHTTPHeaderFields;
        httpModel.responseHeaderFields = response.allHeaderFields;
        if (request.HTTPBody) {
            httpModel.requestBody = request.HTTPBody;
        }
        httpModel.responseBody = response.responseData;
        
        if ([HttpDebugTool shareInstance].hostOnlyArr.count > 0) {
            
            for (NSString *onlyHost in [HttpDebugTool shareInstance].hostOnlyArr) {
                if ([[request.URL.host lowercaseString] rangeOfString:[onlyHost lowercaseString]].location != NSNotFound) {
                    [[HttpDebugTool shareInstance].dataHandle addHttpData:httpModel];
                }
            }
            
        }else {
            [[HttpDebugTool shareInstance].dataHandle addHttpData:httpModel];
        }
        
    }
    
}

@end
