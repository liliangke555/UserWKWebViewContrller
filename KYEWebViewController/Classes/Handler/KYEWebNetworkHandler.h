//
//  KYEWebNetworkHandler.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "KYEWebOperation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KYEWebNetworkHandler <NSObject>

/**
 生成发起请求的request

 @param urlString 请求URL
 @return 生成的request
 */
- (NSURLRequest *)requestWithString:(NSString *)urlString;

/**
 发起网络请求

 @param request 请求的request
 @param completionHandler 完成后的回调
 @return 当前的KYEWebOperation
 */
- (id<KYEWebOperation>)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/**
 获取子线程

 @return 子线程，用于后续网络请求
 */
- (NSThread *)networkRequestThread;
@end

NS_ASSUME_NONNULL_END

