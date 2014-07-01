//
//  CityLocationViewCell.h
//  FastRent
//
//  Created by heng chengfei on 14-5-26.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityLocationViewCell : UITableViewCell

@property(nonatomic,copy) dispatch_block_t refreshBlock;
@property(nonatomic,retain)IBOutlet UILabel *citylabel;
@property(nonatomic,retain)IBOutlet UIButton *btnRefresh;
-(IBAction)refresh:(id)sender;

@end
