//
//  KYEWebDataModel.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYEWebDataModel : NSObject

/**
 请求链接
 */
@property (nullable, nonatomic, copy) NSURLRequest *request;

/**
 重定向链接
 */
@property (nullable, nonatomic, copy) NSURLRequest *redirectRequest;

/**
 服务器返回的response
 */
@property (nullable, nonatomic, copy) NSURLResponse *response;

/**
 服务器返回的数据
 */
@property (nullable, nonatomic, copy) NSData *data;

/**
 error对象
 */
@property (nullable, nonatomic, copy) NSError *error;

/**
 创建时间
 */
@property (nullable, nonatomic, copy) NSDate *createDate;

/**
 用户数据
 */
@property (nullable, nonatomic, copy) NSDictionary *userInfo;
@end

NS_ASSUME_NONNULL_END
