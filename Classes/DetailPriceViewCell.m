//
//  DetailMoneyTableViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-3-25.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "DetailPriceViewCell.h"
#define Left_X 10.0f
#define Top_Y 5.0f

@implementation DetailPriceViewCell

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

-(void)setAttribute:(Rent *) rent
{
    if (rent.rentMoney!=NULL) {
        NSString *money=[NSString stringWithFormat:@"%@元", rent.rentMoney.stringValue];
            self.rentMoney.text=money;
    }

    
    self.rentType.text=rent.rentType;
        self.agencyType.text=rent.agencyType;
    
    if (rent.houseType==nil) {
            self.houseType.text=@"无";
    }else{
            self.houseType.text=rent.houseType;
    }


    if (rent.houseArea==nil) {
        self.houseArea.text =@"无";
    }else{
        
        self.houseArea.text=[NSString  stringWithFormat:@"%d%@",rent.houseArea.intValue,rent.houseAreaUnit];
    }
 
    if(rent.houseDecoration==nil){
         self.houseDecoration.text=@"无";
    }else{
         self.houseDecoration.text=rent.houseDecoration;
    }
   
    
}
@end
