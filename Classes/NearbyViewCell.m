//
//  UserTableViewCell.m
//  TestCombobox
//
//  Created by heng chengfei on 14-3-20.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "NearbyViewCell.h"

@implementation NearbyViewCell

@synthesize img,title,price,rentType,houseType,distance;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
