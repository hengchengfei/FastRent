//
//  SelectionViewController.h
//  FastRent
//
//  切换城市页面中，搜索框的下拉选择Controller
//  Created by heng chengfei on 14-5-28.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectionViewController;

//此协议为了关闭弹出窗口
@protocol SelectionViewControllerDelegate <NSObject>

@optional
- (void)popoverHandler:(SelectionViewController*)controller text:(NSString *)text id:(NSNumber *)id;
@end

@interface SelectionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,retain) id<SelectionViewControllerDelegate> popDelegate;
@property(nonatomic,retain)NSArray *titleDatasource;
@property(nonatomic,retain)NSArray *idDatasource;
@property(nonatomic,retain)IBOutlet UITableView *tableView;

@end

