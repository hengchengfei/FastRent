//
//  CityLocationViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-5-26.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "CityLocationViewCell.h"

@implementation CityLocationViewCell

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

-(IBAction)refresh:(id)sender
{
    if (self.refreshBlock) {
        self.refreshBlock();
    }
}
@end
