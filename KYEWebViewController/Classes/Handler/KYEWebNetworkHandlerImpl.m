//
//  KYEWebNetworkHandlerImpl.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "KYEWebNetworkHandlerImpl.h"

@implementation KYEWebNetworkHandlerImpl

- (NSURLRequest *)requestWithString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    request.HTTPMethod = @"GET";
    return request;
}

- (id<KYEWebOperation>)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler
{
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
    return (id)task;
}

+ (void)networkRequestThreadEntryPoint
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"KYEWebNetworkThread"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

- (NSThread *)networkRequestThread
{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:[KYEWebNetworkHandlerImpl class] selector:@selector(networkRequestThreadEntryPoint) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

@end
