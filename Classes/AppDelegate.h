//
//  AppDelegate.h
//  Test2
//
//  Created by heng chengfei on 13-12-20.
//  Copyright (c) 2013年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WxSdk/WXApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIScrollViewDelegate,WXApiDelegate,WeiboSDKDelegate>
{
    UIPageControl *_pageControl;
    UIScrollView *_currentScro;
}
@property (strong, nonatomic) UIWindow *window;

@end
