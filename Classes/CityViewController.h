//
//  CityViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-5-26.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SelectionViewController.h"

@interface CityViewController : UITableViewController<UISearchBarDelegate,UISearchDisplayDelegate,CLLocationManagerDelegate,SelectionViewControllerDelegate>

@property(copy) void(^callback)(NSString *city);
@end
