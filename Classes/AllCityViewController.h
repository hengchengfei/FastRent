//
//  AllCityViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-8-6.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MALTabBarChinldVIewControllerDelegate.h"

@interface AllCityViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) id<MALTabBarChinldVIewControllerDelegate>delegate;

@property(nonatomic,retain)IBOutlet UIButton *cityButton;
@property(nonatomic,retain)IBOutlet UITableView *searchTable;
@property(nonatomic,retain)IBOutlet UITableView *tableView;
@property(nonatomic,retain)IBOutlet UITextField *textField;
@property(nonatomic,retain)IBOutlet UIButton *btnCancel;


@end
