//
//  KYEWebRequestHandlerImpl.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "KYEWebRequestHandlerImpl.h"
#import "KYEWebLoader+Impl.h"
#import "KYEWebViewController.h"

static NSString * const KYEWebDXP = @"KYEWebDXP";
@interface KYEWebRequestHandlerImpl ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, weak) id<KYEWebOperation> operation;
@end

@implementation KYEWebRequestHandlerImpl

+ (BOOL)shouldHookWithRequest:(NSURLRequest *)request
{
    ///只缓存get请求
    if (request.HTTPMethod && ![request.HTTPMethod.uppercaseString isEqualToString:@"GET"]) {
        return NO;
    }
    
    ///通过UA 来判断是否UIWebView发起的请求
    NSString *UA = [request valueForHTTPHeaderField:@"User-Agent"];
    if ([UA containsString:@" AppleWebKit/"] == NO) {
        return NO;
    }
    
    /// 不缓存 ajax 请求
    NSString *hasAjax = [request valueForHTTPHeaderField:@"X-Requested-With"];
    if (hasAjax != nil) {
        return NO;
    }
    
    NSString *pathExtension = [request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject.pathExtension.lowercaseString;
    NSArray *validExtension = @[ @"jpg", @"jpeg", @"gif", @"png", @"webp", @"bmp", @"tif", @"ico", @"js", @"css", @"html", @"htm", @"ttf", @"svg"];
    if (pathExtension && [validExtension containsObject:pathExtension]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)cancelHookWithRequest:(NSURLRequest *)request
{
    ///已被拦截
    if ([request valueForHTTPHeaderField:KYEWebDXP]) {
        return YES;
    }
    return NO;
}

+ (id<KYEWebRequestHandler>)requestHandlerWithRequest:(NSURLRequest *)request
{
    KYEWebRequestHandlerImpl *handler = [KYEWebRequestHandlerImpl new];
    handler.request = request;
    return handler;
}

- (void)startLoadingWithDelegate:(id<KYEWebRequestDelegate>)delegate
{
    NSString *cacheKey = [[KYEWebLoader defaultCacheHandler] cacheKeyForRequest:self.request];
    KYEWebDataModel *webData = [[KYEWebLoader defaultCacheHandler] dataForKey:cacheKey];
    BOOL networkReachable = [[NSUserDefaults standardUserDefaults] boolForKey:KYE_WebView_NetworkReachable_Key];
    //当缓存有效期或者网络不可用时候，使用缓存
//    NSLog(@"取出请求：%@，取出时间：%@",self.request,[NSDate date]);
    if ((webData && [self timeDifference:webData.createDate] < 10 * 60) || !networkReachable) {
        [delegate request:self didReceiveResponse:webData.response];
        [delegate request:self didReceiveData:webData.data];
        [delegate requestDidFinishLoading:self];
        return;
    }
    
    NSThread *thread = [NSThread currentThread];
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    [request setValue:@"1" forHTTPHeaderField:KYEWebDXP];
    
    __weak id wself = self;
    self.operation = [[KYEWebLoader defaultNetworkHandler] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong KYEWebRequestHandlerImpl *self = wself;
        [self performSelector:@selector(performBlock:) onThread:thread withObject:^{
            __strong KYEWebRequestHandlerImpl *self = wself;
            if (response) {
                [delegate request:self didReceiveResponse:response];
            }
            if (error) {
                [delegate request:self didFailWithError:error];
            } else {
                [delegate request:self didReceiveData:data];
                [delegate requestDidFinishLoading:self];
                
                KYEWebDataModel *webData = [KYEWebDataModel new];
                webData.data = data;
                webData.response = response;
                webData.request = self.request;
                webData.createDate = [NSDate date];
//                NSLog(@"存入请求：%@，存入时间：%@",self.request,[NSDate date]);
                [[KYEWebLoader defaultCacheHandler] setData:webData forKey:cacheKey];
            }
        } waitUntilDone:NO];
    }];
}

- (void)performBlock:(dispatch_block_t)block
{
    if (block) {
        block();
    }
}

- (void)stopLoading
{
    [self.operation cancel];
}

- (long)timeDifference:(NSDate *)date
{
    NSDate *localeDate = [NSDate date];
    long difference = fabs([localeDate timeIntervalSinceDate:date]);
    return difference;
}

@end
