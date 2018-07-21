//
//  KYEViewController.m
//  KYEWebViewController
//
//  Created by zouzhipeng on 12/25/2017.
//  Copyright (c) 2017 zouzhipeng. All rights reserved.
//

#import "KYEViewController.h"
#import "KYEWebViewController-Prefix.pch"
#import "KYECommonWebViewController.h"

@interface KYEViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation KYEViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.dataArray = @[@{@"id":@0, @"title":@"正常WKWebView,post请求body丢失"},
                       @{@"id":@1, @"title":@"HookAjaxPost请求，转发body"},
                       @{@"id":@2, @"title":@"正常加载，有缓存"},
                       @{@"id":@3, @"title":@"预加载"},
                       @{@"id":@4, @"title":@"播放爱奇艺视频"}];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *dict = self.dataArray[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.dataArray[indexPath.row];
    switch ([dict[@"id"] integerValue]) {
        case 0: {
            KYECommonWebViewController *vc = [KYECommonWebViewController new];
            vc.urlStr = @"https://res.ky-express.com/webserver/wapp/test.html";
            vc.hookAjax = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: {
            KYECommonWebViewController *vc = [KYECommonWebViewController new];
            vc.urlStr = @"https://m.jumi18.com";
            vc.hookAjax = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2: {
            KYECommonWebViewController *vc = [KYECommonWebViewController new];
            vc.urlStr = @"https://news-node.seeyouyima.com/article?news_id=842947";
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3: {
            [self prefetchWebVC];
            break;
        }
        case 4: {
            KYECommonWebViewController *vc = [KYECommonWebViewController new];
            vc.urlStr = @"http://m.iqiyi.com/v_19rrdu8le0.html";
//            vc.hookAjax = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
}

- (void)prefetchWebVC
{
    NSString *urlString = @"https://news-node.seeyouyima.com/article?news_id=842947";
    id data = [[KYEWebLoader defaultCacheHandler] dataForKey:urlString];
    if (data) {
        KYECommonWebViewController *vc = [KYECommonWebViewController new];
        vc.urlStr = urlString;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        id<KYEWebPrefetcherProtocol> prefetcher = [[KYEWebLoader defaultPrefetchHandler] prefetchWebUrl:urlString];
        /// kvo completed ...
        if (![(id)prefetcher observationInfo]) {
            [(id)prefetcher addObserver:self forKeyPath:@"completed" options:NSKeyValueObservingOptionNew context:nil];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([change[NSKeyValueChangeNewKey] boolValue]) {
        NSLog(@"预加载完成!");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self prefetchWebVC];
        });
    }
    [object removeObserver:self forKeyPath:@"completed"];
}

@end
