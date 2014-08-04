//
//  SearchViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-5-22.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MALTabBarChinldVIewControllerDelegate.h"

@interface SearchViewController : UITableViewController<UISearchBarDelegate,UISearchDisplayDelegate,CLLocationManagerDelegate>

@property (nonatomic, assign) id<MALTabBarChinldVIewControllerDelegate>delegate;

@end
