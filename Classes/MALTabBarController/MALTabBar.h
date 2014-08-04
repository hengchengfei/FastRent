//
//  MALTabBar.h
//  TabBarControllerModel
//
//  Created by wangtian on 14-6-25.
//  Copyright (c) 2014年 wangtian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MALTabBarItem.h"

#define MainScreenBoundsSize [UIScreen mainScreen].bounds.size
#define tabBarHeight ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? 49 : 69) //tabBar的高度
@protocol MALTabBarDelegate <NSObject>

- (void)selectedItem:(MALTabBarItemModel *)selectedItemModel;
 

@end

@interface MALTabBar : UIView
{
    NSMutableArray *_items;
}

@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, assign) id<MALTabBarDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger currentSelectedIndex;
@property (nonatomic, assign, readonly) NSInteger lastSelectedIndex;
@property (nonatomic, readonly) NSMutableArray *items;

+ (MALTabBar *)getMALTabBarWithItemModels:(NSArray *)itemModels defaultSelectedIndex:(NSInteger)defaultSelectedIndex;
- (void)selectedItemAtIndex:(NSInteger)itemIndex;
- (void)setItemBadgeNumberWithIndex:(NSInteger)itemIndex badgeNumber:(NSInteger)badgeNumber;
@end
