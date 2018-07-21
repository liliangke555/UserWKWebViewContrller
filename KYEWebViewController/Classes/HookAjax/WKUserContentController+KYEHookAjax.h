//
//  WKUserContentController+KYEHookAjax.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//
#import <WebKit/WebKit.h>

@class KYEWebViewMessageHandlerHelp;
@interface WKUserContentController (KYEHookAjax)

/**
 绑定ajaxHook，处理ajax请求丢失body问题
 【注意】当WebView释放的时候，必须手动调用uninstall来移除ajaxHook对象,否则该对象永远不会释放
 
 @param handlerHelp 用于处理原生与js交互的KYEWebViewMessageHandlerHelp对象
 */
- (void)installHookAjaxWithandlerHelp:(KYEWebViewMessageHandlerHelp *)handlerHelp urlKey:(NSString *)urlKey;

/**
 移除ajaxHook
 */
- (void)uninstallHookAjaxWithUrlKey:(NSString *)urlKey;
@end
