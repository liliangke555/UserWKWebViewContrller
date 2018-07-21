//
//  WKUserContentController+KYEHookAjax.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "WKUserContentController+KYEHookAjax.h"
#import <objc/runtime.h>
#import "KYEWebUtils.h"
#import "KYEWebLoader+Impl.h"
#import "KYEWebViewMessageHandlerHelp.h"

NSMutableDictionary *_handleHelpDict;
@interface _KYEWKHookAjaxHandler : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) WKWebView *webView;
@end

@implementation _KYEWKHookAjaxHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    self.webView = message.webView;
    //处理http请求，包括修复post丢失body等
    //    [self requestWithBody:message.body];
    //处理js交互
    KYEWebViewMessageHandlerHelp *handHelp = [_handleHelpDict objectForKey:self.webView.URL.absoluteString];
    [handHelp webView:self.webView withUserContentController:userContentController didReceiveScriptMessage:message];
}

//- (void)requestWithBody:(NSDictionary *)body
//{
//    id requestID = body[@"id"];
//    NSString *method = body[@"method"];
//    id requestData = body[@"data"];
//    NSDictionary *requestHeaders = body[@"headers"];
//    NSString *urlString = body[@"url"];
//
//    [[KYEWebLoader defaultAjaxHandler] startWithMethod:method
//                                                   url:urlString
//                                               baseURL:self.webView.URL
//                                               headers:requestHeaders
//                                                  body:requestData
//                                        completedBlock:^(NSInteger httpCode, NSDictionary * _Nullable headers, NSString * _Nullable data) {
//                                            [self requestCallback:requestID httpCode:httpCode headers:headers data:data];
//                                        }];
//}
//
//- (void)requestCallback:(id)requestId httpCode:(NSInteger)httpCode headers:(NSDictionary *)headers data:(NSString *)data
//{
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"status"] = @(httpCode);
//    dict[@"headers"] = headers;
//    if (data.length > 0) {
//        dict[@"data"] = data;
//    }
//    NSString *jsonString = nil;
//    NSError *err = nil;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
//    if (jsonData.length > 0) {
//        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    }
//    NSString *jsScript = [NSString stringWithFormat:@"window.kye_realxhr_callback(%@, %@);", requestId, jsonString?:@"{}"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.webView evaluateJavaScript:jsScript completionHandler:^(id result, NSError *error) {
//        }];
//    });
//}

@end

@implementation WKUserContentController (KYEHookAjax)

static const void *KYEHookAjaxKey = &KYEHookAjaxKey;
- (void)uninstallHookAjaxWithUrlKey:(NSString *)urlKey
{
    //remove js methods
    KYEWebViewMessageHandlerHelp *handHelp = [_handleHelpDict objectForKey:urlKey];
    NSMutableArray *methodsArr = [NSMutableArray arrayWithArray:handHelp.JSMethodsNameArr];
    //    [methodsArr addObject:@"KYEXHR"];
    [methodsArr enumerateObjectsUsingBlock:^(NSString *  _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeScriptMessageHandlerForName:name];
    }];
    objc_setAssociatedObject(self, KYEHookAjaxKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [_handleHelpDict removeObjectForKey:urlKey];
}

- (void)installHookAjaxWithandlerHelp:(KYEWebViewMessageHandlerHelp *)handlerHelp urlKey:(NSString *)urlKey
{
    BOOL installed = [objc_getAssociatedObject(self, KYEHookAjaxKey) boolValue];
    if (installed || !handlerHelp) {
        [_handleHelpDict setObject:handlerHelp forKey:urlKey];
        return;
    }
    if (!_handleHelpDict) {
        _handleHelpDict = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    objc_setAssociatedObject(self, KYEHookAjaxKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [_handleHelpDict setObject:handlerHelp forKey:urlKey];
    _KYEWKHookAjaxHandler *handler = [_KYEWKHookAjaxHandler new];
    //add js methods
    NSMutableArray *methodsArr = [NSMutableArray arrayWithArray:handlerHelp.JSMethodsNameArr];
    //    [methodsArr addObject:@"KYEXHR"];
    [methodsArr enumerateObjectsUsingBlock:^(NSString *  _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addScriptMessageHandler:handler name:name];
    }];
    // add hook
    //    {
    //        NSBundle *currentBundle = [NSBundle bundleForClass:NSClassFromString(@"KYEWebViewController")];
    //        NSURL *bundleURL = [currentBundle URLForResource:@"KYEWebViewController" withExtension:@"bundle"];
    //        NSBundle *jsBundle = [NSBundle bundleWithURL:bundleURL];
    //        NSString *path = [jsBundle pathForResource:@"KYEHookAjax" ofType:@"js"];
    //        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    //        [self addUserScript:userScript];
    //    }
}

@end

