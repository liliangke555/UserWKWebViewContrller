//
//  KYEWebRequestHandleManagerImpl.m
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import "KYEWebRequestHandleManagerImpl.h"
#import "KYEURLProtocol.h"
#import "KYEWebRequestHandlerImpl.h"

@interface KYEWebRequestHandleManagerImpl (){
    NSArray *_requestHandlerClass;
}
@end

@implementation KYEWebRequestHandleManagerImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enableWKCustomProtocol = NO;
        [self addRequestHandlerClass:[KYEWebRequestHandlerImpl class]];
    }
    return self;
}

- (void)addRequestHandlerClass:(Class)handlerClass
{
    NSArray *array = _requestHandlerClass ?: [NSArray array];
    const NSInteger index = [array indexOfObject:handlerClass];
    if (index != NSNotFound) {
        return;
    }
    @synchronized (self) {
        array = [array arrayByAddingObject:handlerClass];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(id<KYEWebRequestHandler> _Nonnull obj1, id<KYEWebRequestHandler> _Nonnull obj2) {
            NSInteger priority1 = [obj1 respondsToSelector:@selector(priority)] ? [obj1 priority] : 0;
            NSInteger priority2 = [obj2 respondsToSelector:@selector(priority)] ? [obj2 priority] : 0;
            if (priority1 < priority2) {
                return NSOrderedDescending;
            } else if (priority1 > priority2) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        id holdArray = _requestHandlerClass;
        dispatch_async(dispatch_get_main_queue(), ^{
            [holdArray description];
        });
        
        _requestHandlerClass = array;
    }
}

- (void)removeRequestHandlerClass:(Class)handlerClass
{
    NSArray *array = _requestHandlerClass ?: [NSArray array];
    const NSInteger index = [array indexOfObject:handlerClass];
    if (index == NSNotFound) {
        return;
    }
    @synchronized (self) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
        [mutableArray removeObjectAtIndex:index];
        
        id holdArray = _requestHandlerClass;
        dispatch_async(dispatch_get_main_queue(), ^{
            [holdArray description];
        });
        _requestHandlerClass = [mutableArray copy];
    }
}

- (NSArray<Class<KYEWebRequestHandler>> *)requestHandlerClass
{
    NSArray *array = _requestHandlerClass;
    return array;
}

- (void)setEnableWKCustomProtocol:(BOOL)enableWKCustomProtocol
{
    [KYEURLProtocol setEnableWKCustomProtocol:enableWKCustomProtocol];
}

- (BOOL)enableWKCustomProtocol
{
    return [KYEURLProtocol enableWKCustomProtocol];
}

@synthesize enableWKCustomProtocol;

@end
