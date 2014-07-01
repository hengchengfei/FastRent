//
//  DetailMapTableViewCell.h
//  FastRent
//
//  Created by heng chengfei on 14-3-28.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Rent.h"

@interface DetailMapViewCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *lblResident;
@property(nonatomic,weak) IBOutlet UILabel *lblAddress;
@property(nonatomic,retain) IBOutlet UIImageView *imageViewMap;

-(void)setAttribute:(Rent *) rent;
@end
