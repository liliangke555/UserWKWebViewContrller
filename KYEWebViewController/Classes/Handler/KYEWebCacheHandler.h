//
//  KYEWebCacheHandler.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KYEWebDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KYEWebCacheHandler <NSObject>

/**
 根据request生成缓存的key

 @param request reque
 @return 获取的key
 */
- (NSString *)cacheKeyForRequest:(NSURLRequest *)request;

/**
 传入key获取KYEWebDataModel

 @param key 缓存的key
 @return KYEWebDataModel
 */
- (nullable KYEWebDataModel *)dataForKey:(NSString *)key;

/**
 传入key值设置缓存

 @param data 缓存数据，KYEWebDataModel类型
 @param key 指定key
 */
- (void)setData:(nullable KYEWebDataModel *)data forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

