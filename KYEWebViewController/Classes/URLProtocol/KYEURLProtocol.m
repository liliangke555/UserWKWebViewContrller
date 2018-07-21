//
//  KYEURLProtocol.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/11/30.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "KYEURLProtocol.h"
#import "KYEWebLoader+Impl.h"
#import "KYEWebRequestHandleManager.h"
#import <objc/runtime.h>

@interface KYEURLProtocol () <KYEWebRequestDelegate>

@property (nonatomic, assign) BOOL receivedResponse;
@property (nonatomic, assign) BOOL stoppedLoading;

@property (nonatomic, strong) id<KYEWebRequestHandler> requestHandler;
@end

@implementation KYEURLProtocol

#pragma mark --------------------
#pragma mark - CycLife

+ (void)load
{
    [NSURLProtocol registerClass:self];
}

#pragma mark --------------------
#pragma mark - KYEWebRequestDelegate

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    return [self canInitWithRequest:task.currentRequest];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSArray *requestHandlerClass = [KYEWebLoader defaultRequestManager].requestHandlerClass;
    if (!requestHandlerClass.count) {
        return NO;
    }
    BOOL shouldHook = NO;
    BOOL cancelHook = NO;
    
    for (Class<KYEWebRequestHandler> handlerClass in requestHandlerClass) {
        shouldHook = [handlerClass shouldHookWithRequest:request];
        if (shouldHook) {
            break;
        }
    }
    for (Class<KYEWebRequestHandler> handlerClass in requestHandlerClass) {
        cancelHook = [handlerClass cancelHookWithRequest:request];
        if (cancelHook) {
            break;
        }
    }
    
    return shouldHook && !cancelHook;
}

- (void)startLoading
{
    NSURLRequest *request = self.request;
    id<KYEWebRequestHandler> requestHandler = nil;
    NSArray *requestHandlerClass = [KYEWebLoader defaultRequestManager].requestHandlerClass;
    for (Class<KYEWebRequestHandler> handlerClass in requestHandlerClass) {
        requestHandler = [handlerClass requestHandlerWithRequest:request];
        if (requestHandler) {
            break;
        }
    }
    if (!requestHandler) {
        NSError *error = [NSError errorWithDomain:@"no request handler !" code:-999 userInfo:nil];
        [self callbackRequestDidFailWithError:error];
    } else {
        self.requestHandler = requestHandler;
        [self.requestHandler startLoadingWithDelegate:self];
    }
}

- (void)stopLoading
{
    self.stoppedLoading = YES;
    [self.requestHandler stopLoading];
}

/// 保证 Response URL 跟请求时一致
- (NSURLResponse *)callbackResponseWithResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (id)response;
    if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        if (![httpResponse.URL isEqual:self.request.URL]) {
            httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL statusCode:httpResponse.statusCode HTTPVersion:@"HTTP/1.1" headerFields:httpResponse.allHeaderFields];
        }
    }
    return httpResponse;
}

- (void)callbackRequestWasRedirectedToRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (self.receivedResponse) {
        NSError *error = [NSError errorWithDomain:@"only return first received response !!" code:-999 userInfo:nil];
        NSAssert(NO, error.domain);
        return;
    }
    if (self.stoppedLoading) {
        return;
    }
    response = [self callbackResponseWithResponse:response];
    if (!response) {
        NSError *error = [NSError errorWithDomain:@"wasRedirectedToRequest redirectResponse not found !!" code:-999 userInfo:nil];
        [self callbackRequestDidFailWithError:error];
    } else {
        self.receivedResponse = YES;
        [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
}

- (void)callbackRequestDidReceiveResponse:(NSURLResponse *)response
{
    if (self.receivedResponse) {
        NSError *error = [NSError errorWithDomain:@"only return first received response !!" code:-999 userInfo:nil];
        NSAssert(NO, error.domain);
        return;
    }
    if (self.stoppedLoading) {
        return;
    }
    response = [self callbackResponseWithResponse:response];
    if (!response) {
        NSError *error = [NSError errorWithDomain:@"response not found !!" code:-999 userInfo:nil];
        NSLog(@"%@", error.domain);
    } else {
        self.receivedResponse = YES;
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
}

- (void)callbackRequestDidLoadData:(NSData *)data
{
    if (self.stoppedLoading) {
        return;
    }
    if (!self.receivedResponse) {
        NSError *error = [NSError errorWithDomain:@"didReceiveData to be scheduled before didReceiveResponse !!" code:-999 userInfo:nil];
        NSLog(@"%@", error.domain);
    } else if (data.length > 0) {
        [self.client URLProtocol:self didLoadData:data];
    }
}

- (void)callbackRequestDidFailWithError:(NSError *)error
{
    if (self.stoppedLoading) {
        return;
    }
    NSLog(@"%@", error.domain);
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)callbackRequestDidFinishLoading
{
    if (self.stoppedLoading) {
        return;
    }
    if (!self.receivedResponse) {
        NSError *error = [NSError errorWithDomain:@"didFinishLoading to be scheduled before didReceiveResponse !!" code:-999 userInfo:nil];
        [self callbackRequestDidFailWithError:error];
    } else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

#pragma mark --------------------
#pragma mark - request delegate

- (void)request:(id<KYEWebRequestHandler>)request wasRedirectedToRequest:(NSURLRequest *)redirectRequest redirectResponse:(NSURLResponse *)redirectResponse
{
    [self callbackRequestWasRedirectedToRequest:redirectRequest redirectResponse:redirectResponse];
}

- (void)request:(id<KYEWebRequestHandler>)request didReceiveResponse:(NSURLResponse *)response
{
    [self callbackRequestDidReceiveResponse:response];
}

- (void)request:(id<KYEWebRequestHandler>)request didReceiveData:(NSData *)data
{
    [self callbackRequestDidLoadData:data];
}

- (void)requestDidFinishLoading:(id<KYEWebRequestHandler>)request
{
    [self callbackRequestDidFinishLoading];
}

- (void)request:(id<KYEWebRequestHandler>)request didFailWithError:(NSError *)error
{
    [self callbackRequestDidFailWithError:error];
}

@end

@implementation KYEURLProtocol (WKCustomProtocol)

#pragma mark --------------------
#pragma mark - Method
static BOOL kKYEEnableWKCustomProtocol = NO;
+ (void)setEnableWKCustomProtocol:(BOOL)enableWKCustomProtocol
{
    kKYEEnableWKCustomProtocol = enableWKCustomProtocol;
    id contextController = NSClassFromString([NSString stringWithFormat:@"%@%@%@",@"WK",@"Browsing",@"ContextController"]);
    if (!contextController) {
        return;
    }
    SEL performSEL = nil;
    if (enableWKCustomProtocol) {
        performSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@",@"register",@"SchemeForCustomProtocol:"]);
    } else {
        performSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@",@"unregister",@"SchemeForCustomProtocol:"]);
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([contextController respondsToSelector:performSEL]) {
        [contextController performSelector:performSEL withObject:@"http"];
        [contextController performSelector:performSEL withObject:@"https"];
    }
#pragma clang diagnostic pop
}

+ (BOOL)enableWKCustomProtocol
{
    return kKYEEnableWKCustomProtocol;
}

@end

