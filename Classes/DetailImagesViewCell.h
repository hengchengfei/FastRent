//
//  DetailImagesViewCell.h
//  FastRent
//
//  Created by heng chengfei on 14-5-18.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rent.h"

@interface DetailImagesViewCell : UITableViewCell<UIScrollViewDelegate>

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(Rent *)data;

-(void)addScrollView;
@end
