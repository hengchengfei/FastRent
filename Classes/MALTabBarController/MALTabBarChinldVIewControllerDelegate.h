//
//  MALTabBarChinldVIewControllerDelegate.h
//  MALTabBarControllerDemo
//
//  Created by wangtian on 14-6-25.
//  Copyright (c) 2014年 wangtian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MALTabBarChinldVIewControllerDelegate <NSObject>

- (void)setBadgeNumber:(NSInteger)number index:(NSInteger)index;
@end
