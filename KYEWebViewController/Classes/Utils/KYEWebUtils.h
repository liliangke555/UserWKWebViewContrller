//
//  KYEWebUtils.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYEWebUtils : NSObject

/**
 模拟网页的URL生成规则

 @param urlString URL字符串
 @param baseURL baseURL
 @return 生成的URL
 */
+ (NSURL *)URLWithString:(NSString *)urlString baseURL:(NSURL *)baseURL;

/**
 交换方法

 @param clazz 方法所属的类
 @param origSel_ 原始方法SEL
 @param altSel_ 交换方法的SEL
 @return 是否成功
 */
+ (BOOL)swizzleClass:(Class)clazz origMethod:(SEL)origSel_ withMethod:(SEL)altSel_;

@end
