//
//  PDMoreViewController.h
//  TestCombox
//
//  Created by heng chengfei on 14-9-4.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComboxVo.h"
#import "ComboxDatas.h"
#import "ComboxData.h"

@protocol PDMoreDelegate <NSObject>

-(void)PDMoreOKClick:(NSNumber *)sourceId houseType:(NSNumber *)houseTypeId order:(NSNumber *)orderId;

@end

@interface PDMoreViewController : UIViewController

@property(nonatomic,retain) ComboxVo *datasource;
@property(nonatomic,retain) id<PDMoreDelegate> delegate;

@property(nonatomic,retain) IBOutlet UISegmentedControl *segSource;
@property(nonatomic,retain)IBOutlet UISegmentedControl *segHouseType;
@property(nonatomic,retain)IBOutlet UISegmentedControl *segOrder;

-(IBAction)okClick:(id)sender;

-(id)initWithDataSource:(ComboxVo *)_comboxVo;

@end
