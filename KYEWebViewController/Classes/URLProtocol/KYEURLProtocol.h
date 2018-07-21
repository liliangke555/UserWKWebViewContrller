//
//  KYEURLProtocol.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/11/30.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KYEURLProtocol : NSURLProtocol

@end

@interface KYEURLProtocol (WKCustomProtocol)

/**
 是否开启 WKWebView Custom Protocol 拦截 http、https
 default：YES
 */
@property (class, nonatomic) BOOL enableWKCustomProtocol;
@end
