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
#import "IntroductionViewController.h"
#import "MALTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIScrollViewDelegate,WXApiDelegate,WeiboSDKDelegate,UIScrollViewDelegate>
{
    MALTabBarViewController *tabBarController;
    
    UIScrollView *_scrollView;
    int currentPage;
    int currentOffsetX;
    int imageCount;
    

}
@property (strong, nonatomic) UIWindow *window;

@end
