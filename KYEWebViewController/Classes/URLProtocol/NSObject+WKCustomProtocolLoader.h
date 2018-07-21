//
//  NSObject+WKCustomProtocolLoader.h
//  WKWebView_Unit
//
//  Created by kye_zzp on 2017/12/8.
//  Copyright © 2017年 kye_zzp. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 原始 WKCustomProtocolLoader 是在主线程进行网络请求，这边进行 hook 改为在子线程请求
 */
@interface NSObject (WKCustomProtocolLoader)

@end
