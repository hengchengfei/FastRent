//
//  NearbyViewController.h
//  Test2
//
//  Created by heng chengfei on 14-1-7.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RentComboxs.h"
#import "RentCombox.h"
#import "UIImageView+WebCache.h"
#import "EGORefreshTableHeaderView.h"
#import "SelectionViewController.h"
#import "MALTabBarChinldVIewControllerDelegate.h"

@interface NearbyViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, CLLocationManagerDelegate,NSURLConnectionDataDelegate,EGORefreshTableHeaderDelegate,SelectionViewControllerDelegate >
{
    CLLocationManager *locationManager;
}

@property (nonatomic, assign) id<MALTabBarChinldVIewControllerDelegate>delegate;

@property(nonatomic,retain)IBOutlet UITableView *tableView;

@property(nonatomic,retain)NSString *navTitle;
//开始重新加载时调用的方法
-(void)reloadTableViewDataSource;

//完成加载时调用的方法
-(void)doneLoadingTableViewData;
@end
