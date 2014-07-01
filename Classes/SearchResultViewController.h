//
//  SearchResultViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-6-5.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rents.h"
#import "Rent.h"
#import "WYPopoverController.h"
#import "SelectionViewController.h"

@interface SearchResultViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,SelectionViewControllerDelegate>

@property(nonatomic,retain)NSString *city;
@property(nonatomic,retain)NSString *searchText;
@property(nonatomic,retain)IBOutlet UITableView *tableView;
@property(nonatomic,retain)Rents *datasource;
@end
