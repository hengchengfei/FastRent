//
//  AppDelegate.m
//  Test2
//
//  Created by heng chengfei on 13-12-20.
//  Copyright (c) 2013年 cf. All rights reserved.
//

#import "AppDelegate.h"
#import "MobClick.h"
#import "LTUpdate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //友盟
    [MobClick setCrashReportEnabled:YES];
    [MobClick setLogEnabled:NO];
    [MobClick startWithAppkey:__UmAppKey__ reportPolicy:BATCH channelId:nil];

    //微博
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:__WeiboAppKey__];
    
    //微信
    [WXApi registerApp:@"wxe21eaa4dc541c522" withDescription:@"1.0.0"];
    
    //设置为IOS7风格
    if (ISOS7==NO) {
        //设置导航背景色为IOS7风格
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:IOS7_Nav_Color];
    
        [[UIToolbar appearance] setBackgroundImage:[[UIImage alloc]init] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        [[UIToolbar appearance] setBackgroundColor:IOS7_Nav_Color];
    }

    
//    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
//    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
//    NSString *launchedKey = @"isFirstLaunched";
//    if ([userDefaults boolForKey:launchedKey]==NO) {
//        [userDefaults setBool:YES forKey:launchedKey];
//        [self showGuideView];
//    }else{
//        [self gotoMainStoryboard];
//    }
//    [userDefaults synchronize];
    
    
    
    return YES;
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    //检测版本
    [[LTUpdate shared] update:LTUpdateDaily
                     complete:^(BOOL isNewVersionAvailable, LTUpdateVersionDetails *versionDetails) {
                         
                         //*// [TIP] Remove the first slash to toggle block comments if you'd like to use MBAlertView.
                         if (isNewVersionAvailable) {
                             //                             DLog(@"New version %@ released on %@.", versionDetails.version, versionDetails.releaseDate);
                             //                             DLog(@"The app is about %@", humanReadableFileSize(versionDetails.fileSizeBytes));
                             //                             DLog(@"Release notes:\n%@", versionDetails.releaseNotes);
                             [[LTUpdate shared] alertLatestVersion:LTUpdateOption | LTUpdateSkip];
                         } else {
                             // DLog(@"You App is up to date.");
                         }
                     }];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *scheme = [url scheme];
    
    if ([scheme isEqualToString:@"wxe21eaa4dc541c522"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else if([scheme isEqualToString:@"tencent101127138"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if ([scheme isEqualToString:@"wb3591795453"]){
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString *scheme = [url scheme];
    
    if ([scheme isEqualToString:@"wxe21eaa4dc541c522"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else if([scheme isEqualToString:@"tencent101127138"]){
        return [TencentOAuth HandleOpenURL:url];
    }else if ([scheme isEqualToString:@"wb3591795453"]){
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    
    return YES;
    
    
}

#pragma mark WeiboDelegate
-(void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    DLog(@"%s",__FUNCTION__);
}

-(void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    DLog(@"%s",__FUNCTION__);
    
//    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
//    {
//        NSString *title = @"发送结果";
//        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
// 
//    }
//    else if ([response isKindOfClass:WBAuthorizeResponse.class])
//    {
//        NSString *title = @"认证结果";
//        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        
//       NSString * wbtoken = [(WBAuthorizeResponse *)response accessToken];
//   
//    }
}

#pragma mark QQ
-(void)onReq:(BaseReq *)req{
    DLog(@"%s",__FUNCTION__);
}

-(void)onResp:(BaseResp *)resp
{
    DLog(@"%s",__FUNCTION__);
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)showGuideView
{
    UIScrollView *scro=[[UIScrollView alloc]initWithFrame:self.window.bounds];
    scro.pagingEnabled=YES;
    _currentScro=scro;
    scro.scrollEnabled=YES;
    scro.bounces=NO;
    scro.showsHorizontalScrollIndicator=NO;;
    scro.delegate=self;
    UIImageView *imgView1=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Guide1.png"]];
    imgView1.frame=CGRectMake(0, 0, 320, 480);
    UIImageView *imgView2=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Guide2.png"]];
    imgView2.frame=CGRectMake(320, 0, 320, 480);
    
    UIButton *btnEnter= [[UIButton alloc] initWithFrame:CGRectMake(400, 200, 100, 100)];
    [btnEnter setTitle:@"Enter" forState:UIControlStateNormal];
    
    //    [imgView2 addSubview:btnEnter];
    
    [scro addSubview:imgView1];
    [scro addSubview:imgView2];
    [scro addSubview:btnEnter];
    
    [btnEnter addTarget:self action:@selector(gotoMainStoryboard) forControlEvents:UIControlEventTouchUpInside];
    
    scro.contentSize=CGSizeMake(320*2, scro.frame.size.height);
    UIPageControl *page=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 400, 320, 20)];
    page.numberOfPages=2;
    _pageControl=page;
    [page addTarget:self action:@selector(changeCurrentPage:) forControlEvents:UIControlEventValueChanged];
    page.backgroundColor=[UIColor redColor];
    page.currentPage=0;
    [self.window addSubview:scro];
    [self.window addSubview:page];
}

-(void) gotoMainStoryboard
{
    //    NSArray *nibViews =[[NSBundle mainBundle] loadNibNamed:@"Guide" owner:self options:nil];
    //    [self.window addSubview:[nibViews objectAtIndex:0]];
    //
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *vc=[sb instantiateInitialViewController];
//    UIViewController *vc=[sb instantiateViewControllerWithIdentifier:@"tabar"];
    [self.window setRootViewController:vc];
    [self.window makeKeyAndVisible];
}

-(void)changeCurrentPage:(UIPageControl *)sender
{
    [_currentScro setContentOffset:CGPointMake(sender.currentPage*320, 0)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ((int)scrollView.contentOffset.x%320==0) {
        _pageControl.currentPage=(int)scrollView.contentOffset.x/320;
    }
}

@end
