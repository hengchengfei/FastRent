//
//  MALTabBarViewController.h
//  TabBarControllerModel
//
//  Created by wangtian on 14-6-25.
//  Copyright (c) 2014年 wangtian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MALTabBar.h"
#import "MALTabBarChinldVIewControllerDelegate.h"

@interface MALTabBarViewController : UIViewController

@property (nonatomic, strong) NSArray *itemsArray;
@property (nonatomic, weak) MALTabBar *tabBar;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *currentViewController;//当前被选中controller
@property (nonatomic, assign) id<MALTabBarChinldVIewControllerDelegate>delegate;

- (id)initWithItemModels:(NSArray *)itemModelArray;
- (id)initWithItemModels:(NSArray *)itemModelArray defaultSelectedIndex:(NSInteger)defaultSelectedIndex;
- (void)setTabBarBgImage:(NSString *)imageName;
@end
