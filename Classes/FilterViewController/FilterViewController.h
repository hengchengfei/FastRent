//
//  FilterViewController.h
//  TestCombox
//
//  Created by heng chengfei on 14-9-11.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRComboxItem.h"
#import "PullDownViewController.h"
#import "PDMoreViewController.h"
#import "ComboxVo.h"

@protocol FilterViewControllerDelegate <NSObject>

-(void)getFilterParams:(NSMutableDictionary *)params;

@end

@interface FilterViewController : UIViewController<FRComboxItemDelegate,PDTBLDelegate,PDMoreDelegate>

@property(nonatomic,retain)id<FilterViewControllerDelegate> delegate;

@property(nonatomic,retain)ComboxVo *comboxDatasource;
@end
