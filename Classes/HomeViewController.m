//
//  HomeViewController.m
//  Test2
//
//  Created by heng chengfei on 13-12-31.
//  Copyright (c) 2013年 cf. All rights reserved.
//

#import "HomeViewController.h"
#import "NearbyViewController.h"
#import "MoreViewController.h"
#import "WebRequest.h"
#import "MoreViewController.h"
#import "MobClick.h"
#import "LTUpdate.h"

@interface HomeViewController ()
{
    CLLocationManager *locationManager;
    
    MoreViewController *moreController;
}

@end

@implementation HomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self chkUpdate];
    
    BOOL isLocation = [CLLocationManager locationServicesEnabled];
    if (isLocation) {
        locationManager=[CLLocationManager new];
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        locationManager.distanceFilter=100.0f;//当位置超过多少米时更新
        [locationManager startUpdatingLocation];
    }
    [self setTitle:@"闪租"];
 
    //不显示底部的cell
    self.tableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    

}

-(void)chkUpdate{
    //检测版本
    [[LTUpdate shared] update:LTUpdateNow
                     complete:^(BOOL isNewVersionAvailable, LTUpdateVersionDetails *versionDetails) {
                         //*// [TIP] Remove the first slash to toggle block comments if you'd like to use MBAlertView.
                         if (isNewVersionAvailable) {
                             //                             DLog(@"New version %@ released on %@.", versionDetails.version, versionDetails.releaseDate);
                             //                             DLog(@"The app is about %@", humanReadableFileSize(versionDetails.fileSizeBytes));
                             //                             DLog(@"Release notes:\n%@", versionDetails.releaseNotes);
                             [[LTUpdate shared] alertLatestVersion:LTUpdateOption | LTUpdateSkip];
                         }
                     }];
}
//设置导航颜色
-(void)setTitle:(NSString *)title
{
    UIFont *font = [UIFont systemFontOfSize:kNav_TitleSize];
    
    CGSize titleSize=MB_TEXTSIZE(title, font);
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, titleSize.width, 44)];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=title;
    titleLabel.font=font;
    titleLabel.textColor=[UIColor blackColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    titleLabel.userInteractionEnabled=YES;
    self.navigationItem.titleView=titleLabel;
    
    
}

-(void)pushSettingController:(id)sender
{
    moreController=[self.storyboard instantiateViewControllerWithIdentifier:@"moreController"];
    [self.navigationController pushViewController:moreController animated:YES];
}

#pragma mark 定位操作
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation  *_currentLocation=[locations lastObject];
    CLLocationCoordinate2D coor = _currentLocation.coordinate;//手机GPS
    
    double _latitude = coor.latitude;
    double _longitude =coor.longitude;
    
    //取得所有下拉框的值
    __block BOOL isSuccess=NO;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WebRequest findAddress:_latitude longitude:_longitude onCompletion:^(Address * address, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
            }else{
                isSuccess=YES;
                [self setDefaultCity:address.city];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [locationManager stopUpdatingLocation];
        });
    });
}

#pragma mark 设置默认城市
-(void)setDefaultCity:(NSString *)cityText
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:cityText forKey:kLocation_City];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
    [self setDefaultCity:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *destinct = segue.destinationViewController;
    if ([destinct isKindOfClass:[NearbyViewController class]]) {
        NearbyViewController *controller=(NearbyViewController *)destinct;
            controller.navTitle= @"附近";
    }

   
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"首页"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"首页"];
}
@end
