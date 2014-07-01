//
//  DetailTitleTableViewCell.h
//  FastRent
//
//  Created by heng chengfei on 14-3-25.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rent.h"

@interface DetailTitleViewCell : UITableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(Rent *)data;

@end
