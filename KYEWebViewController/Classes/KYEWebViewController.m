//
//  KYEWebViewController.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/11/28.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "KYEWebViewController.h"
#import "KYEWebViewMessageHandlerHelp.h"
#import "KYEURLProtocol.h"
//#import "WKUserContentController+KYEHookAjax.h"
#import "KYEWebLoader+Impl.h"

#define kScrenH [UIScreen mainScreen].bounds.size.height
#define kIsIphoneX (kScrenH == 812)
#define KColorValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static NSString * const KPageTitle = @"title";
static NSString * const KEstimatedProgress = @"estimatedProgress";

@interface KYEWebViewController ()<WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) WKWebView *currentWebView;
@property (nonatomic, strong) UIView *progress;
@property (nonatomic, strong) UIView *errorTipView;
@property (nonatomic, strong) CALayer *progressLayer;
@property (nonatomic, strong) WKWebViewConfiguration *configuration;
@property (nonatomic, strong) KYEWebViewMessageHandlerHelp *handleHelp;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat proportion;
@property (nonatomic, strong) NSMutableURLRequest *request;
@end

@implementation KYEWebViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.networkReachable = YES;
    [[NSUserDefaults standardUserDefaults] setBool:self.isNetworkReachable forKey:KYE_WebView_NetworkReachable_Key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setupViews];
    [self setupWebview];
}

- (void)viewWillAppear:(BOOL)animated
{
    //修复白屏-2
    if (!self.currentWebView.title) {
        [self.currentWebView reload];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.currentWebView.frame = self.view.bounds;
    self.errorTipView.frame = self.currentWebView.frame;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
    [self.currentWebView removeObserver:self forKeyPath:KEstimatedProgress];
    [self.currentWebView removeObserver:self forKeyPath:KPageTitle];
    [self.currentWebView.configuration.userContentController uninstallHookAjaxWithUrlKey:self.urlStr];
}

#pragma mark - Methods

+ (NSString *)getCurrentVersion
{
    return @"0.2.6";
}

- (void)setupViews
{
    //重置导航条按钮，符合业内webView样式
    [self setupBarButtonItems];
    //设置KYE标识
    CGFloat tempY = 0;
    CGFloat statusH = 0;
    if (![UIApplication sharedApplication].isStatusBarHidden) {
        statusH = 20;
    }
    if (self.navigationController.navigationBar &&!self.navigationController.navigationBarHidden) {
        tempY = kIsIphoneX ? 64 : 44;
    }
    tempY += statusH;
    //
    if (!self.navigationController.navigationBar.translucent) {
        tempY -= kIsIphoneX ? 84 : 64;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *infoLab = [[UILabel alloc] initWithFrame:CGRectMake(0, tempY, [UIScreen mainScreen].bounds.size.width, 30)];
    infoLab.text = @"网页由www.ky-express.com提供";
    infoLab.textAlignment = NSTextAlignmentCenter;
    infoLab.textColor = KColorValue(0x4D317C);
    infoLab.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:infoLab];
    //添加进度条
    UIView *progress = [[UIView alloc]initWithFrame:CGRectMake(0, tempY, CGRectGetWidth(self.view.frame), 3)];
    progress.backgroundColor = [UIColor clearColor];
    [self.view addSubview:progress];
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 0, 3);
    layer.backgroundColor = KColorValue(0x4D317C).CGColor;
    [progress.layer addSublayer:layer];
    self.progressLayer = layer;
    self.progress = progress;
    //出错提示
    self.errorTipView = [[UIView alloc] initWithFrame:CGRectMake(0, tempY, self.view.bounds.size.width, self.view.bounds.size.height - tempY)];
    self.errorTipView.backgroundColor = [UIColor whiteColor];
    self.errorTipView.hidden = YES;
    [self.view addSubview:self.errorTipView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadPage)];
    [self.errorTipView addGestureRecognizer:tap];
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.text = @"页面加载失败，请稍后再试\n   （轻触屏幕重新加载）";
    errorLabel.numberOfLines = 0;
    errorLabel.font = [UIFont systemFontOfSize:18];
    errorLabel.textColor = [UIColor grayColor];
    errorLabel.userInteractionEnabled = YES;
    [errorLabel sizeToFit];
    errorLabel.center = CGPointMake(self.errorTipView.center.x, self.errorTipView.center.y - 100);
    [self.errorTipView addSubview:errorLabel];
    //进度条默认80%
    [self addTimer];
}

- (void)addTimer
{
    self.progressLayer.opacity = 1;
    self.progressLayer.frame = CGRectMake(0, 0, 0, 3);
    self.proportion = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)timerAction
{
    self.proportion += 0.1;
    self.progressLayer.frame = CGRectMake(0, 0, self.view.frame.size.width * self.proportion, 3);
    if (self.progressLayer.frame.size.width >= self.view.frame.size.width * 0.8) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)setupBarButtonItems
{
    //避免在侧滑返回时设置barButtonItems导致导航栏混乱
    if (!self.navigationController) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf setupBarButtonItems];
        });
        return;
    }
    //重置导航左上角按钮，事件
    NSBundle *currentBundle = [NSBundle bundleForClass:NSClassFromString(@"KYEWebViewController")];
    NSURL *bundleURL = [currentBundle URLForResource:@"KYEWebViewController" withExtension:@"bundle"];
    if (!bundleURL) {
        return;
    }
    NSBundle *imageBundle = [NSBundle bundleWithURL:bundleURL];
    if ([self.currentWebView canGoBack]) {
        UIImage *image = [UIImage imageNamed:@"webView_back_white" inBundle:imageBundle compatibleWithTraitCollection:nil];
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemButton setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        [itemButton setImage:image forState:UIControlStateNormal];
        itemButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [itemButton addTarget:self action:@selector(btnBackTouchIn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithCustomView:itemButton];
        
        UIButton *clsoseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clsoseBtn setFrame:CGRectMake(0, 0, 40, 22)];
        UIImage *closeImage = [UIImage imageNamed:@"webView_close_white" inBundle:imageBundle compatibleWithTraitCollection:nil];
        [clsoseBtn setImage:closeImage forState:UIControlStateNormal];
        clsoseBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [clsoseBtn addTarget:self action:@selector(btnCloseTouchIn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc]initWithCustomView:clsoseBtn];
        NSArray *arrayBarButtonItems = nil;
        if (self.presentingViewController) {
            arrayBarButtonItems = @[backButton, closeButton];
        } else {
            arrayBarButtonItems = self.navigationController.viewControllers.count > 1 ? @[backButton, closeButton] : @[backButton];
        }
        [self.navigationItem setLeftBarButtonItems:arrayBarButtonItems];
    } else {
        UIImage *image = [UIImage imageNamed:@"webView_back_white" inBundle:imageBundle compatibleWithTraitCollection:nil];
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [itemButton setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        itemButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [itemButton setImage:image forState:UIControlStateNormal];
        [itemButton addTarget:self action:@selector(btnBackTouchIn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithCustomView:itemButton];
        NSArray *arrayBarButtonItems = nil;
        if (self.presentingViewController) {
            arrayBarButtonItems = @[backButton];
        } else {
            arrayBarButtonItems = self.navigationController.viewControllers.count > 1 ? @[backButton] : nil;
        }
        [self.navigationItem setLeftBarButtonItems:arrayBarButtonItems];
    }
}

- (void)setupWebview
{
    if (!self.currentWebView) {
        self.handleHelp = [KYEWebViewMessageHandlerHelp handlerHelpWithJSMethodsNameArr:self.JSMethodsNameArr];
        self.handleHelp.delegate = self.JSMessageHandleDelegate;
        self.configuration = [[WKWebViewConfiguration alloc] init];
        self.configuration.allowsInlineMediaPlayback = YES;
        self.currentWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:self.configuration];
        _webView = self.currentWebView;
        self.currentWebView.backgroundColor = [UIColor clearColor];
        self.currentWebView.scrollView.backgroundColor = [UIColor clearColor];
        self.currentWebView.opaque = NO;
        self.currentWebView.allowsBackForwardNavigationGestures = YES;
        if (@available(iOS 9.0, *)) {
            self.currentWebView.allowsLinkPreview = YES;
        }
        self.currentWebView.UIDelegate = self;
        self.currentWebView.navigationDelegate = self;
        //设置UA
        [self.currentWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            __block NSString *defaultUA = result;
            if (self.userAgentString && ![defaultUA containsString:self.userAgentString]) {
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@ %@",defaultUA,self.userAgentString] ?: defaultUA, @"UserAgent", nil];
                [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
            }
        }];
        [self.view insertSubview:self.currentWebView belowSubview:self.progress];
        //修复首次请求，cookie丢失问题
        NSURL *url = [NSURL URLWithString:self.urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain;
        if (url) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:self.HTTPCookieArray ? : @[] forURL:url mainDocumentURL:url];
        }
        NSMutableDictionary *requestHeaderFields = [NSMutableDictionary dictionaryWithDictionary:[NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies]];
        request.allHTTPHeaderFields = requestHeaderFields;
        [self.currentWebView loadRequest:request];
        self.request = request;
        
        //插入cookie到webview中
        WKUserScript *newCookieScript = [[WKUserScript alloc] initWithSource:[self getCookieStr] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self.configuration.userContentController addUserScript:newCookieScript];
        [self.currentWebView addObserver:self forKeyPath:KEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
        [self.currentWebView addObserver:self forKeyPath:KPageTitle options:NSKeyValueObservingOptionNew context:nil];
    }
    if (self.hookAjax) {
        [self.configuration.userContentController installHookAjaxWithandlerHelp:self.handleHelp urlKey:self.urlStr];
    }
}

- (NSString *)getCookieStr
{
    NSMutableString *script = [NSMutableString string];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        [script appendFormat:@"document.cookie='%@'; \n", [self appendCookieSecure:cookie]];
    }
    return script;
}

- (NSString *)appendCookieSecure:(NSHTTPCookie *)cookie
{
    NSString *cookies = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",cookie.name,cookie.value,cookie.domain,cookie.path?:@"/"];
    if (cookie.secure) {
        cookies = [cookies stringByAppendingString:@";secure=true"];
    }
    return cookies;
}

//修复重定向等时cookie丢失
- (NSURLRequest *)fixRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *fixedRequest;
    if ([request isKindOfClass:[NSMutableURLRequest class]]) {
        fixedRequest = (NSMutableURLRequest *)request;
    } else {
        fixedRequest = request.mutableCopy;
    }
    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:[NSHTTPCookieStorage sharedHTTPCookieStorage].cookies];
    if (dict.count) {
        NSMutableDictionary *mDict = request.allHTTPHeaderFields.mutableCopy;
        [mDict setValuesForKeysWithDictionary:dict];
        fixedRequest.allHTTPHeaderFields = mDict;
    }
    return fixedRequest;
}

#pragma mark - Events

- (void)btnBackTouchIn:(UIButton *)button
{
    if ([self.currentWebView canGoBack]) {
        [self.currentWebView goBack];
    } else {
        UIViewController *controller = [self.navigationController popViewControllerAnimated:YES];
        if (!controller) {
            [self dismissViewControllerAnimated:YES completion:^{
                if (self.popFinishBlock) {
                    self.popFinishBlock();
                }
            }];
        } else {
            if (self.popFinishBlock) {
                self.popFinishBlock();
            }
        }
    }
}

- (void)btnCloseTouchIn:(UIButton *)button
{
    UIViewController *controller = [self.navigationController popViewControllerAnimated:YES];
    if (!controller) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.popFinishBlock) {
                self.popFinishBlock();
            }
        }];
    } else {
        if (self.popFinishBlock) {
            self.popFinishBlock();
        }
    }
}

- (void)reloadPage
{
    self.errorTipView.hidden = YES;
    [self addTimer];
    [self.currentWebView loadRequest:self.request];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self setupBarButtonItems];
    [self setupWebview];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error.code == -1001) { //超时,设置15s
        self.errorTipView.hidden = NO;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    //修复白屏-1
    [self.currentWebView reload];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([[navigationAction.request.URL host] isEqualToString:@"itunes.apple.com"] &&
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else if ([[navigationAction.request.URL scheme] isEqualToString:@"tel"]) {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - WKUIDelegate

//webview有alert弹框时调用
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//webview有confirm弹框时调用
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//webview有prompt弹框时调用
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textFiled = alertController.textFields.firstObject;
        completionHandler(textFiled.text);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//在新的webview标签页打开
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    [webView loadRequest:[self fixRequest:navigationAction.request]];
    return nil;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //调整滚动速率
    scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:KEstimatedProgress]) {
        self.progressLayer.opacity = 1;
        if ([change[@"new"] floatValue] < [change[@"old"] floatValue]) {
            return;
        }
        if ([change[@"new"] floatValue] < 0.8) {
            return;
        }
        [self.timer invalidate];
        self.timer = nil;
        CGFloat width = self.view.bounds.size.width * [change[@"new"] floatValue];
        self.progressLayer.frame = CGRectMake(0, 0, width, 3);
        if ([change[@"new"] floatValue] == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.opacity = 0;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.frame = CGRectMake(0, 0, 0, 3);
            });
        }
    } else if([keyPath isEqualToString:KPageTitle]) {
        self.title = change[@"new"];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

