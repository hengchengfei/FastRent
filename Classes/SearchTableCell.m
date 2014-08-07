//
//  SearchTableCell.m
//  FastRent
//
//  Created by heng chengfei on 14-8-7.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "SearchTableCell.h"

@implementation SearchTableCell

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
