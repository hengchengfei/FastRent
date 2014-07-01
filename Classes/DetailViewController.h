//
//  HouseDetailViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-3-24.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LXActivity.h"
#import "Toast+UIView.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import "WeiboSDK.h"

@class DetailViewController;
@protocol DetailDataDelegate <NSObject>

-(void)addItemViewController:(DetailViewController *)controller disFinishEnteringItem:(BOOL)isFavorite;

@end

@interface DetailViewController :UIViewController<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,LXActivityDelegate,TencentSessionDelegate,QQApiInterfaceDelegate>
{
    TencentOAuth* _tencentOAuth;
    NSArray     *_permissions  ;

}
@property(nonatomic,retain)id<DetailDataDelegate> delegate;

@property(weak,nonatomic)IBOutlet UITableView *tableView;

@property(nonatomic,retain)NSNumber *id;
@property(nonatomic)BOOL isFavorited;
 
@property(nonatomic,retain)UIBarButtonItem *backButton;
@property(nonatomic,retain)UIBarButtonItem *favoriteButton;

@property(nonatomic,retain)UIViewController *fromViewController;

@end
