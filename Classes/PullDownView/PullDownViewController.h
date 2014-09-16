//
//  ComboxViewController.h
//  TestCombox
//
//  Created by heng chengfei on 14-8-29.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComboxData.h"

@protocol PDTBLDelegate <NSObject>

-(void)PDTBLCellClick:(id)sender data:(ComboxData *)data;

@end

@interface PullDownViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,assign)CGRect frame;
@property(nonatomic,retain)UITableView *tableview;
@property(nonatomic,retain)id<PDTBLDelegate> delegate;

@property(nonatomic,retain)NSArray *datasource;

@end
