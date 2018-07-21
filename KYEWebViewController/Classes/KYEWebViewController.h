//
//  KYEWebViewController.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/11/28.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^OperationBlock)();
#pragma clang diagnostic pop

static NSString * const KYE_WebView_NetworkReachable_Key = @"KYE_WebView_NetworkReachable_Key";
@protocol KYEWebViewMessageHandlerHelpDlegate;
@interface KYEWebViewController : UIViewController

/**
 是否需要hookAjax，如果拦截protocol，目前WKWebView中loadRequest发起的ajax的post请求默认会丢失body，需要hook
 不拦截则不需要
 */
@property (nonatomic, assign, getter=isHookAjax) BOOL hookAjax;

/**
 当前网络是否可用
 */
@property (nonatomic, assign, getter=isNetworkReachable) BOOL networkReachable;

/**
 当前的webview对象
 */
@property (nonatomic, strong, readonly) WKWebView *webView;

/**
 webView的URL
 */
@property (nonatomic, copy) NSString *urlStr;

/**
 自定义http请求头数组，用于解决首次请求cookie丢失问题,eg:
 NSHTTPCookie *newCookie1 = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         [url host]?:@"",NSHTTPCookieDomain,
                                                                         @"/",NSHTTPCookiePath,
                                                                         @"userId",NSHTTPCookieName,
                                                                         @"12345",NSHTTPCookieValue,
                                                                         @"TRUE",NSHTTPCookieSecure,
                                                                         nil]];
 */
@property (nonatomic, strong) NSArray<NSHTTPCookie *> *HTTPCookieArray;

/**
 UA
 */
@property (nonatomic, copy) NSString *userAgentString;

/**
 所有的JS方法名数组，字符串形式
 */
@property (nonatomic, strong) NSArray *JSMethodsNameArr;

/**
 当webView控制器pop出栈时回调的block，使用时注意不要引起循环引用，导致webViewController不能释放
 */
@property (nonatomic, copy) OperationBlock popFinishBlock;

/**
 指定JS消息处理对象，当接收到JS Message时调用
 */
@property (nonatomic, weak) id<KYEWebViewMessageHandlerHelpDlegate> JSMessageHandleDelegate;

/**
 获取当前版本号

 @return 版本号
 */
+ (NSString *)getCurrentVersion;
@end

NS_ASSUME_NONNULL_END
