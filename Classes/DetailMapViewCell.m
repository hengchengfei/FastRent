//
//  DetailMapTableViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-3-28.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "DetailMapViewCell.h"
#import "UIImageView+WebCache.h"

@implementation DetailMapViewCell

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

-(void)setAttribute:(Rent *)rent
{
    self.lblResident.text=[@"小区：" stringByAppendingString:rent.resident];
    self.lblAddress.text=[@"地址：" stringByAppendingString:rent.houseAddress];
    //self.imageViewMap =[[UIImageView alloc]initWithFrame:CGRectMake(13, 72, 300, 105.0)];
    NSURL *url=[NSURL URLWithString:rent.mapImage];
    [self.imageViewMap setImageWithURL:url placeholderImage:[UIImage imageNamed:kPNG_Loading_300]];
    
    [self.imageViewMap setContentMode:UIViewContentModeScaleToFill];
}
@end
