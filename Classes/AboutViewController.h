//
//  AboutViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-6-11.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak)IBOutlet UITableView *tableView;

@end
