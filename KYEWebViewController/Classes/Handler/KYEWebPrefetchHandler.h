//
//  KYEWebPrefetchHandler.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "KYEWebOperation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KYEWebPrefetcherProtocol <KYEWebOperation>

/**
 数据预加载的URL
 */
@property (nonatomic, copy) NSString *webUrl;

/**
 是否加载完成标识
 */
@property (nonatomic, assign, readonly, getter=isCompleted) BOOL completed;

@end

@protocol KYEWebPrefetchHandler <NSObject>


/**
 执行数据预加载，一次生命周期内对同一个 url，只会预加载一次，除非已经被移除了

 @param webUrl URL
 @return 执行对象
 */
- (id<KYEWebPrefetcherProtocol>)prefetchWebUrl:(NSString *)webUrl;

/**
 取消全部预加载操作
 */
- (void)cancelAllPrefetcherLoading;

/**
 移除预加载对象

 @param webUrl 需要移除的对象URL
 */
- (void)removePrefetcherForWebUrl:(NSString *)webUrl;

@end

NS_ASSUME_NONNULL_END
