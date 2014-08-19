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
    //自动更新版本检测
    [self chkUpdate];
    
    //是否自动加载更多
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    id isAutoload = [defaults objectForKey:kIsAutoLoadMore];
    if (isAutoload==nil && isAutoLoad) {
        [defaults setBool:YES forKey:kIsAutoLoadMore];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    
    //显示状态栏，因为在plist中启动时，隐藏了状态栏
    //[[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
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
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    NSArray *controllerArray = [NSArray arrayWithObjects:@"NearbyNavigation",@"allCityController",@"favoriteNavigation",@"moreNavigation",nil];//类名数组
    NSArray *titleArray = [NSArray arrayWithObjects:@"附近",@"全城",@"收藏",@"更多",nil];//item标题数组
    NSArray *normalImageArray = [NSArray arrayWithObjects:@"TABLocation.png",@"TABSearch.png",@"TABFavorite.png",@"TABMore.png", nil];//item 正常状态下的背景图片
    NSArray *selectedImageArray = [NSArray arrayWithObjects:@"TABLocation_selected.png",@"TABSearch_selected.png", @"TABFavorite_selected.png",@"TABMore_selected.png",nil];//item被选中时的图片名称
    
    for (int i = 0; i< controllerArray.count; i++) {
        
        MALTabBarItemModel *itemModel = [[MALTabBarItemModel alloc] init];
        itemModel.controllerName = controllerArray[i];
        itemModel.itemTitle = titleArray[i];
        itemModel.itemImageName = normalImageArray[i];
        itemModel.selectedItemImageName = selectedImageArray[i];
        [itemsArray addObject:itemModel];
    }
    
    tabBarController = [[MALTabBarViewController alloc] initWithItemModels:itemsArray defaultSelectedIndex:0];
    [tabBarController setTabBarBgImage:kPNG_TAB_Background];//设置tabBar的背景图片
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    //First Install
    NSString *firstInstallKey = @"IS_FIRST_INSTALL";//1.0.2
    BOOL isFirstInstall=[defaults boolForKey:firstInstallKey];
    if (isFirstInstall) {
        self.window.rootViewController = tabBarController;
    }else{
        [defaults setBool:YES forKey:firstInstallKey];
        [defaults synchronize];
        
        IntroductionViewController *root=[[IntroductionViewController alloc]init];
        [root.view addSubview: [self addScrollView]];
        
        self.window.rootViewController=root;
        
    }
    
    
    [self.window makeKeyAndVisible];
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

-(UIScrollView *)addScrollView{
    CGRect screen =[[UIScreen mainScreen]bounds];
    _scrollView =[[UIScrollView alloc]initWithFrame:screen];
    //CGSize size = scrollView.frame.size;
    imageCount=3;
    currentPage=1;
    _scrollView.backgroundColor=[UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.pagingEnabled=YES;
    _scrollView.delegate=self;
    //scrollView.autoresizingMask=(UIViewAutoresizingFlexibleHeight)
    _scrollView.contentSize=CGSizeMake(screen.size.width*imageCount, screen.size.height);
    
    
    UIImageView *imageview1=[[UIImageView alloc]init];
    [imageview1 setImage:[UIImage imageNamed:@"Introduction1.jpg"]];
    imageview1.frame=screen;
    imageview1.contentMode=UIViewContentModeScaleToFill;
    imageview1.backgroundColor=[UIColor clearColor];
    
    UIImageView *imageview2=[[UIImageView alloc]init];
    [imageview2 setImage:[UIImage imageNamed:@"Introduction2.jpg"]];
    imageview2.frame=CGRectMake(screen.size.width, 0, screen.size.width, screen.size.height);
    imageview2.contentMode=UIViewContentModeScaleToFill;
    imageview2.backgroundColor=[UIColor clearColor];
    
    UIImageView *imageview3=[[UIImageView alloc]init];
    [imageview3 setImage:[UIImage imageNamed:@"Introduction3.jpg"]];
    imageview3.frame=CGRectMake(screen.size.width*2, 0, screen.size.width, screen.size.height);
    imageview3.contentMode=UIViewContentModeScaleToFill;
    imageview3.backgroundColor=[UIColor clearColor];
    
    [_scrollView addSubview:imageview1];
    [_scrollView addSubview:imageview2];
    [_scrollView addSubview:imageview3];
    
    return _scrollView;
}

#pragma mark scrollviewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    DLog(@"%f",scrollView.contentOffset.x);
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //先取得当前所在的偏移点
    currentOffsetX= scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //根据最后松开时所在的x偏移点，判断向左还是向右滑动
    CGFloat offsetX = scrollView.contentOffset.x;
    //DLog(@"end:%f",offsetX);
    NSUInteger nextPage=currentPage;
    if (offsetX > currentOffsetX) {
        //right
        nextPage=currentPage+1;
    }else if(offsetX < currentOffsetX){
        nextPage=currentPage-1;
    }
    
    if (nextPage<=0) {
        return;
    }
    
    if (nextPage>imageCount) {
        self.window.rootViewController=tabBarController;
        return;
    }
    
    NSNumber *next=[NSNumber numberWithInteger:nextPage];
    
    [self performSelectorOnMainThread:@selector(gotoNextPageView:) withObject:next waitUntilDone:NO];
    //[self gotoNextPageView:nextPage];不起效果
}

#pragma mark 下一个图
-(void)gotoNextPageView:(NSNumber *)pageIndex
{
    CGRect screen = [[UIScreen mainScreen]bounds];
    CGPoint x=CGPointMake((pageIndex.intValue-1)*screen.size.width,0);
    
    [_scrollView setContentOffset:x animated:YES];
    
    currentPage = pageIndex.intValue;
}

#pragma mark 检测版本
-(void)chkUpdate{
    [[LTUpdate shared] update:LTUpdateNow
                     complete:^(BOOL isNewVersionAvailable, LTUpdateVersionDetails *versionDetails) {
                         //*// [TIP] Remove the first slash to toggle block comments if you'd like to use MBAlertView.
                         if (isNewVersionAvailable) {
                             //                             DLog(@"New version %@ released on %@.", versionDetails.version, versionDetails.releaseDate);
                             //                             DLog(@"The app is about %@", humanReadableFileSize(versionDetails.fileSizeBytes));
                             //                             DLog(@"Release notes:\n%@", versionDetails.releaseNotes);
                             //[[LTUpdate shared] alertLatestVersion:LTUpdateOption | LTUpdateSkip];
                             [[LTUpdate shared] alertLatestVersion:LTUpdateOption | LTUpdateSkip];
                         }
                     }];
}

@end
