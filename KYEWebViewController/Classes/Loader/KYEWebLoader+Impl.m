//
//  KYEWebLoader+KYEWebLoader_Impl.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "KYEWebLoader+Impl.h"
#import <pthread.h>
#import "KYEWebCacheHandlerImpl.h"
#import "KYEWebNetworkHandlerImpl.h"
#import "KYEWebPrefetchHandlerImpl.h"
#import "KYEWebAjaxHandlerImpl.h"
#import "KYEWebRequestHandleManagerImpl.h"

static pthread_mutex_t _lock;
static NSMutableDictionary *_instanceMap = nil;
static NSMutableDictionary *_classMap = nil;

@implementation KYEWebLoader

+ (void)setHandlerClass:(Class)handlerClass forProtocol:(Protocol *)protocol
{
    if (!handlerClass || !protocol) {
        NSAssert(NO, @"handlerClass/protocol can't nil !");
        return;
    }
    NSString *key = NSStringFromProtocol(protocol);
    pthread_mutex_lock(&_lock);
    [_instanceMap removeObjectForKey:key];
    [_classMap setObject:handlerClass forKey:key];
    pthread_mutex_unlock(&_lock);
}

+ (id)handlerForProtocol:(Protocol *)protocol
{
    if (!protocol) {
        NSAssert(NO, @"protocol can't nil !");
        return nil;
    }
    NSString *key = NSStringFromProtocol(protocol);
    pthread_mutex_lock(&_lock);
    id handler = [_instanceMap objectForKey:key];
    if (!handler) {
        Class clazz = [_classMap objectForKey:key];
        handler = [[clazz alloc] init];
        if (handler) {
            [_instanceMap setObject:handler forKey:key];
        } else {
            NSAssert(NO, @"not found handler with %@ protocol !", key);
        }
    }
    pthread_mutex_unlock(&_lock);
    return handler;
}

+ (void)initialize
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_lock, NULL);
        _instanceMap = [NSMutableDictionary dictionary];
        _classMap = [NSMutableDictionary dictionary];
        
        [self setHandlerClass:[KYEWebCacheHandlerImpl class] forProtocol:@protocol(KYEWebCacheHandler)];
        [self setHandlerClass:[KYEWebPrefetchHandlerImpl class] forProtocol:@protocol(KYEWebPrefetchHandler)];
        [self setHandlerClass:[KYEWebNetworkHandlerImpl class] forProtocol:@protocol(KYEWebNetworkHandler)];
        [self setHandlerClass:[KYEWebAjaxHandlerImpl class] forProtocol:@protocol(KYEWebAjaxHandler)];
        [self setHandlerClass:[KYEWebRequestHandleManagerImpl class] forProtocol:@protocol(KYEWebRequestHandleManager)];
    });
}

@end

@implementation KYEWebLoader (Guest)

+ (id<KYEWebRequestHandleManager>)defaultRequestManager
{
    return [self handlerForProtocol:@protocol(KYEWebRequestHandleManager)];
}

+ (id<KYEWebAjaxHandler>)defaultAjaxHandler
{
    return [self handlerForProtocol:@protocol(KYEWebAjaxHandler)];
}

+ (id<KYEWebCacheHandler>)defaultCacheHandler
{
    return [self handlerForProtocol:@protocol(KYEWebCacheHandler)];
}

+ (id<KYEWebNetworkHandler>)defaultNetworkHandler
{
    return [self handlerForProtocol:@protocol(KYEWebNetworkHandler)];
}

+ (id<KYEWebPrefetchHandler>)defaultPrefetchHandler
{
    return [self handlerForProtocol:@protocol(KYEWebPrefetchHandler)];
}

@end
