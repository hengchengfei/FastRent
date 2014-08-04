//
//  MALTabBarItemModel.h
//  TabBarControllerModel
//
//  Created by wangtian on 14-6-25.
//  Copyright (c) 2014年 wangtian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MALTabBarItemModel : NSObject

@property (nonatomic, assign) NSInteger itemIndex;//item 对应的索引(程序自己计算)
@property (nonatomic, copy) NSString *controllerName;//item 对应控制器类名
@property (nonatomic, copy) NSString *itemImageName;// item 对应图片名称(未选中状态)
@property (nonatomic, copy) NSString *itemTitle;// item 对应标题
@property (nonatomic, copy) NSString *selectedItemImageName;//item 选中状态下图片名

- (MALTabBarItemModel *)initMALTabBarItemModelWithTitle:(NSString *)itemTitle itemImageName:(NSString *)itemImageName controllerName:(NSString *)controllerName selectedItemImageName:(NSString *)selectedItemImageName;
@end
