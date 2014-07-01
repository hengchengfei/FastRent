//
//  HomeViewController.h
//  Test2
//
//  Created by heng chengfei on 13-12-31.
//  Copyright (c) 2013年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface HomeViewController : UITableViewController<CLLocationManagerDelegate>

@property(nonatomic,retain)IBOutlet UIImageView *imageViewSearch;
@property(nonatomic,retain)IBOutlet UIImageView *imageViewFavorite;

@end
