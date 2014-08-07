//
//  SearchTableViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-8-7.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchTableDelegate <NSObject>

-(void)didSelectedSearch:(NSString *)searchText;

@end
@interface SearchTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain)NSMutableArray *datasource;

@end
