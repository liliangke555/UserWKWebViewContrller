//
//  KYEWebViewMessageHandlerHelp.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/11/28.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "KYEWebViewMessageHandlerHelp.h"

@interface KYEWebViewMessageHandlerHelp ()

@end

@implementation KYEWebViewMessageHandlerHelp

#pragma mark - Methods

+ (instancetype)handlerHelpWithJSMethodsNameArr:(NSArray *)JSMethodsNameArr
{
    KYEWebViewMessageHandlerHelp *help = [[KYEWebViewMessageHandlerHelp alloc] init];
    [help setupMethodsArrayWithArr:JSMethodsNameArr];
    return help;
}

- (void)setupMethodsArrayWithArr:(NSArray *)JSMethodsNameArr
{
    _JSMethodsNameArr = JSMethodsNameArr.copy;
}

#pragma mark - WKScriptMessageHandler

- (void)webView:(WKWebView *)webView withUserContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.delegate respondsToSelector:@selector(messageHandlerHelp:webView:didReceiveScriptMessage:)]) {
        [self.delegate messageHandlerHelp:self webView:webView didReceiveScriptMessage:message];
    }
}

@end
