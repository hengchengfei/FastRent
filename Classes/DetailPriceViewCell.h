//
//  DetailMoneyTableViewCell.h
//  FastRent
//
//  Created by heng chengfei on 14-3-25.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rent.h"

@interface DetailPriceViewCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel  *rentMoney;
@property(nonatomic,weak)IBOutlet UILabel  *rentType;
@property(nonatomic,weak)IBOutlet UILabel  *houseType;
@property(nonatomic,weak)IBOutlet UILabel  *houseArea;
@property(nonatomic,weak)IBOutlet UILabel  *houseDecoration;
@property(nonatomic,weak)IBOutlet UILabel  *agencyType;

-(void)setAttribute:(Rent *) rent;
@end
