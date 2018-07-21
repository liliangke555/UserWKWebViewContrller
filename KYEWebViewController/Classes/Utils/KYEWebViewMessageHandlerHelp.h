//
//  KYEWebViewMessageHandlerHelp.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/11/28.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KYEWebViewMessageHandlerHelp;
@protocol KYEWebViewMessageHandlerHelpDlegate<NSObject>
@required

/**
 代理方法，接收到h5消息后调用

 @param help KYEWebViewMessageHandlerHelp对象
 @param webView 当前webView对象
 @param message h5消息体
 */
- (void)messageHandlerHelp:(KYEWebViewMessageHandlerHelp *)help webView:(WKWebView *)webView didReceiveScriptMessage:(WKScriptMessage *)message;
@end

@interface KYEWebViewMessageHandlerHelp : NSObject

/**
 代理
 */
@property (nonatomic, weak) id<KYEWebViewMessageHandlerHelpDlegate> delegate;

/**
 所有的JS方法名，字符串形式
 */
@property (nonatomic, strong, readonly) NSArray *JSMethodsNameArr;

/**
 快速创建help对象

 @param JSMethodsNameArr JS方法
 @return help对象
 */
+ (instancetype)handlerHelpWithJSMethodsNameArr:(NSArray *)JSMethodsNameArr;

/**
 接收到系统消息后，调用此方法处理

 @param webView 当前的webview
 @param userContentController WKUserContentController
 @param message WKScriptMessage
 */
- (void)webView:(WKWebView *)webView withUserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

NS_ASSUME_NONNULL_END
