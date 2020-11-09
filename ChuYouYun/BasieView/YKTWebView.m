//
//  YKTWebView.m
//  YunKeTang
//
//  Created by smelltime on 2020/5/8.
//  Copyright © 2020 ZhiYiForMac. All rights reserved.
//

#import "YKTWebView.h"

@implementation YKTWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    wkWebConfig.userContentController = wkUController;
    self = [super initWithFrame:frame configuration:wkWebConfig];
    if (self) {

    }
    return self;
}

@end
