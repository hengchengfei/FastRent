//
//  UserTableViewCell.h
//  TestCombobox
//
//  Created by heng chengfei on 14-3-20.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearbyViewCell : UITableViewCell


@property(weak,nonatomic)IBOutlet UIImageView *img;
@property(weak,nonatomic)IBOutlet UILabel *title;
@property(weak,nonatomic)IBOutlet UILabel *price;
@property(weak,nonatomic)IBOutlet UILabel *rentType;
@property(weak,nonatomic)IBOutlet UILabel *houseType;
@property(weak,nonatomic)IBOutlet UILabel *agencyType;
@property(weak,nonatomic)IBOutlet UILabel *id;
@property(weak,nonatomic)IBOutlet UILabel *distance;
@property(weak,nonatomic)IBOutlet UILabel *updateTime;
@property(weak,nonatomic)IBOutlet UILabel *houseArea;

@end
