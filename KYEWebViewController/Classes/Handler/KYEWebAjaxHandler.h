//
//  KYEWebAjaxHandler.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KYEWebAjaxHandler <NSObject>

/**
 处理，转发被拦截的请求

 @param method 请求方法
 @param urlString URL
 @param baseURL baseURL
 @param headers 请求header
 @param body 请求body
 @param completedBlock 完成回调
 */
- (void)startWithMethod:(NSString *)method
                    url:(NSString *)urlString
                baseURL:(nullable NSURL *)baseURL
                headers:(nullable NSDictionary *)headers
                   body:(nullable id)body
         completedBlock:(void (^)(NSInteger httpCode, NSDictionary * _Nullable headers, NSString * _Nullable data))completedBlock;

@end

NS_ASSUME_NONNULL_END
