//
//  MoreViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-5-30.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MALTabBarChinldVIewControllerDelegate.h"

@interface MoreViewController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, assign) id<MALTabBarChinldVIewControllerDelegate>delegate;

@end
