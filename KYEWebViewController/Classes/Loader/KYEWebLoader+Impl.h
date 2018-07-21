//
//  KYEWebLoader+KYEWebLoader_Impl.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KYEWebDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface KYEWebLoader : NSObject

/**
 根据protocol获取拦截器

 @param protocol 自定义protocol
 @return 请求拦截器
 */
+ (id)handlerForProtocol:(Protocol *)protocol;

/**
 根据类和协议，设置拦截器

 @param handlerClass 关联的类
 @param protocol 关联的协议
 */
+ (void)setHandlerClass:(Class)handlerClass forProtocol:(Protocol *)protocol;
@end

@interface KYEWebLoader (Guest)

/**
 请求拦截控制器
 */
@property (class, readonly, nonatomic) id<KYEWebRequestHandleManager> defaultRequestManager;

/**
 缓存控制器
 */
@property (class, readonly, nonatomic) id<KYEWebCacheHandler> defaultCacheHandler;

/**
 预加载控制器
 */
@property (class, readonly, nonatomic) id<KYEWebPrefetchHandler> defaultPrefetchHandler;

/**
 数据请求handler
 */
@property (class, readonly, nonatomic) id<KYEWebNetworkHandler> defaultNetworkHandler;

/**
 Ajax请求处理对象
 */
@property (class, readonly, nonatomic) id<KYEWebAjaxHandler> defaultAjaxHandler;
@end

NS_ASSUME_NONNULL_END
