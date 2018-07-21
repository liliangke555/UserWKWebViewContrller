//
//  KYECommonWebViewController.m
//  KYEWebViewController_Example
//
//  Created by kye_zzp on 08/01/2018.
//  Copyright © 2018 zouzhipeng. All rights reserved.
//

#import "KYECommonWebViewController.h"
#import <KYEWebViewController/KYEWebViewMessageHandlerHelp.h>

static NSString * const KYEJSTestFunc0 = @"KYEJSTestFunc0";
static NSString * const KYEJSTestFunc1 = @"KYEJSTestFunc1";

@interface KYECommonWebViewController ()<KYEWebViewMessageHandlerHelpDlegate>

@end

@implementation KYECommonWebViewController

- (void)viewDidLoad {
    self.hookAjax = YES;
    self.userAgentString = @"I am UA";
    self.JSMessageHandleDelegate = self;
    NSHTTPCookie *newCookie1 = [NSHTTPCookie cookieWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   @"https://test.com",NSHTTPCookieDomain,
                                                                   @"/",NSHTTPCookiePath,
                                                                   @"userId",NSHTTPCookieName,
                                                                   @"12345",NSHTTPCookieValue,
                                                                   @"TRUE",NSHTTPCookieSecure,
                                                                   nil]];
    self.HTTPCookieArray = @[newCookie1];
    [super viewDidLoad];
}

/*
 需与h5约定，所有交互方法，建议参数格式如下：
 {
 key1 : value1,
 key2 : value2,
 ...
 callback : funcStr //固定保留字段，表示h5回调方法,返回值由此传递
 }
 */
- (void)messageHandlerHelp:(KYEWebViewMessageHandlerHelp *)help webView:(WKWebView *)webView didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"%s",__FUNCTION__);
    NSDictionary *params = message.body;
    if (!params || ![params isKindOfClass:[NSDictionary class]]) return;
    __block NSString *callBack = params[@"callback"];
    if ([message.name isEqual:KYEJSTestFunc0]) {
        /*
         ...
         ...
         */
        [webView evaluateJavaScript:callBack completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (error) {
                //error handle
            }
        }];
    }else if ([message.name isEqual:KYEJSTestFunc1]) {
        //同上
    }
}

@end
