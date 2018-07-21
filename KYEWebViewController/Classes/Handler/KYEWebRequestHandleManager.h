//
//  KYEWebRequestHandleManager.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KYEWebRequestHandler,KYEWebCacheHandler;

@protocol KYEWebRequestDelegate <NSObject>
@required

/**
 请求发生重定向时执行

 @param request 请求request
 @param redirectRequest 重定向request
 @param redirectResponse 重定向response
 */
- (void)request:(id<KYEWebRequestHandler>)request wasRedirectedToRequest:(NSURLRequest *)redirectRequest redirectResponse:(nullable NSURLResponse *)redirectResponse;

/**
 请求接收到response时执行

 @param request 请求request
 @param response 请求response
 */
- (void)request:(id<KYEWebRequestHandler>)request didReceiveResponse:(NSURLResponse *)response;

/**
 请求接收到data时执行
 
 @param request 请求request
 @param data 请求data
 */
- (void)request:(id<KYEWebRequestHandler>)request didReceiveData:(NSData *)data;

/**
 请求完成结束时执行

 @param request 请求request
 */
- (void)requestDidFinishLoading:(id<KYEWebRequestHandler>)request;

/**
 请求出现错误时执行

 @param request 请求request
 @param error 错误对象
 */
- (void)request:(id<KYEWebRequestHandler>)request didFailWithError:(NSError *)error;

@end

@protocol KYEWebRequestHandler <NSObject>
@required

/**
 指定是否要拦截该request

 @param request 请求request
 @return 是否拦截
 */
+ (BOOL)shouldHookWithRequest:(NSURLRequest *)request;

/**
 取消该request的拦截，只要有一个class返回YES，则不拦截该请求

 @param request 请求request
 @return 是否取消拦截
 */
+ (BOOL)cancelHookWithRequest:(NSURLRequest *)request;

/**
 根据request返回具体的请求实例, 会使用第一个返回的请求对象，因为在manager内部会有多个不同的类型请求对象

 @param request 请求request
 @return 请求对象
 */
+ (nullable id<KYEWebRequestHandler>)requestHandlerWithRequest:(NSURLRequest *)request;

/**
 开始加载

 @param delegate delegate
 */
- (void)startLoadingWithDelegate:(id<KYEWebRequestDelegate>)delegate;

/**
 停止加载
 */
- (void)stopLoading;

@optional

/**
 获取的缓存控制器，default：[KYEWebLoader defaultCacheHandler]

 @return 缓存控制器
 */
+ (id<KYEWebCacheHandler>)cacheHandler;

/**
 获取拦截器优先级，默认0，越大排序越前

 @return 拦截器优先级
 */
+ (NSInteger)priority;

@end

@protocol KYEWebRequestHandleManager <NSObject>

/**
 添加请求class到manager中

 @param handlerClass 请求class
 */
- (void)addRequestHandlerClass:(Class<KYEWebRequestHandler>)handlerClass;

/**
 添加请求class到manager中
 
 @param handlerClass 请求class
 */
- (void)removeRequestHandlerClass:(Class<KYEWebRequestHandler>)handlerClass;

/**
 获取所有的请求class

 @return requestHandler数组
 */
- (NSArray<Class<KYEWebRequestHandler>> *)requestHandlerClass;

/**
 是否开启 WKWebView Custom Protocol 拦截 http、https
 default：YES
 */
@property (nonatomic, assign) BOOL enableWKCustomProtocol;

@end

NS_ASSUME_NONNULL_END

