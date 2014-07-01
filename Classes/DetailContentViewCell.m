//
//  DetailContentTableViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-3-25.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "DetailContentViewCell.h"

@implementation DetailContentViewCell

@synthesize publishContent;

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
