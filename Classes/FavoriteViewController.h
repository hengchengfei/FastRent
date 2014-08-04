//
//  FavoriteViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-4-25.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "MALTabBarChinldVIewControllerDelegate.h"

@interface FavoriteViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,DetailDataDelegate>

@property (nonatomic, assign) id<MALTabBarChinldVIewControllerDelegate>delegate;
@property(nonatomic,retain)IBOutlet UITableView *tableView;

-(IBAction)edit:(id)sender;

@end
