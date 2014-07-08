//
//  SearchViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-5-22.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "SearchViewController.h"
#import "RentSearchBar.h"
#import "WebRequest.h"
#import "BaiduSuggestion.h"
#import "CityViewController.h"
#import "MBProgressHUD.h"
#import "DXAlertView/DXAlertView.h"
#import "SearchResultViewController.h"
#import "MobClick.h"

@interface SearchViewController ()
{
    //    NSMutableArray *_baiduDatasource;
    //    NSMutableArray *_datasource;
    //    NSMutableArray *database;
    //
    UISearchBar *_searchBar;
    UISearchDisplayController * searchDisplayController;
    
    CityViewController *cityViewController;
    
    
    //CLLocationManager *locationManager;
    
    SearchResultViewController *searchResultController;
    NSString *city;
    
    MBProgressHUD *hud;
}
@end

@implementation SearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark 修改图片颜色
- (UIImage *)imageWithOverlayColor:(UIImage *)image color:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage
                                                scale:1.0 orientation: UIImageOrientationDownMirrored];
    
    return  flippedImage;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //打开地图定位
    [self openMapLocation];
    [self setNavLeftButton];
    
    city=[self getSearchCity];
    if (city) {
        [self setTitle:city];
    }else{
        [self setTitle:@"选择城市"];
    }
    
    
    
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    
    // _baiduDatasource=[[NSMutableArray alloc]init];
    
    _searchBar=[[UISearchBar alloc]init];
    _searchBar.frame=CGRectMake(0, 0, self.tableView.bounds.size.width, 0);
    _searchBar.delegate=self;
    _searchBar.keyboardType=UIKeyboardTypeDefault;
    _searchBar.showsCancelButton=YES;
    //searchBar.showsBookmarkButton=YES;
    _searchBar.placeholder=@"小区名/地名等";
    _searchBar.translucent=YES;
    _searchBar.barStyle=UIBarStyleDefault;
    [_searchBar setBackgroundImage:[UIImage new]];
    [_searchBar setTranslucent:YES];
    
    //searchBar.prompt=@"搜索";
    [_searchBar sizeToFit];
    self.tableView.tableHeaderView=_searchBar;
    
    searchDisplayController =[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    //[searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
//    [searchDisplayController.searchResultsTableView setHidden:YES];
//    [searchDisplayController.searchResultsTableView  setAlpha:0.0];
    //searchDisplayController.searchResultsDelegate=self;
    //searchDisplayController.searchResultsDataSource=self;
    //searchDisplayController.delegate=self;
    
    
}

#pragma mark 开启地图功能
-(void)openMapLocation
{
    if (![CLLocationManager locationServicesEnabled]) {
        [self openGPSTips];
    }else{
        //        locationManager=[CLLocationManager new];
        //        locationManager.delegate=self;
        //        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //        locationManager.distanceFilter=100.0f;//当位置超过多少米时更新
        //        [locationManager startUpdatingLocation];
    }
}

-(void)openGPSTips{
    DXAlertView *view=[[DXAlertView alloc]initWithTitle:@"当前定位服务不可用" contentText:@"请到“设置->隐私->定位服务”中开启定位" leftButtonTitle:nil rightButtonTitle:@"确定"];
    [view show];
    
    //定位错误，则返回到前一个页面
    view.leftBlock=^{
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    view.rightBlock=^{
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    view.dismissBlock=^{
        [self.navigationController popViewControllerAnimated:YES];
    };
}

-(void)setTitle:(NSString *)title
{
    CGRect btnFrame=CGRectMake(110, 0, 100, 44);
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=btnFrame;
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    button.backgroundColor=[UIColor clearColor];
    [button addTarget:self action:@selector(presentCityController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView=button;
    
    //添加文本
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(0, 0,btnFrame.size.width-25, 44)];
    label.font=[UIFont systemFontOfSize:14.0];;
    label.text=title;
    label.textColor=[UIColor blackColor];
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    
    //添加图片
    UIImage *image =[UIImage imageNamed:@"buttonDown.png"];
    UIImageView *imageview = [[UIImageView alloc]initWithImage:image];
    
    imageview.backgroundColor=[UIColor clearColor];
    
    CGSize imageSize=image.size;
    
    CGRect frame1=CGRectMake(btnFrame.size.width-imageSize.width, 16, 12 , 12);
    imageview.frame=frame1;
    
    [button addSubview:label];
    [button addSubview:imageview];
    
    
}

-(void)setNavLeftButton
{
    UIButton *button=[[UIButton alloc]init];
    UIImage *back=[UIImage imageNamed:kPNG_BACK];
    button.frame = CGRectMake(0, 0, back.size.width, back.size.height);
    [button setBackgroundImage:back forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=item;
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)presentCityController:(id)sender
{
    CityViewController *_controller =[self.storyboard instantiateViewControllerWithIdentifier:@"CityViewController"];
    _controller.callback=^(NSString *_city){
        [self setSearchCity:_city];
        city=_city;
        [self setTitle:_city];
    };
    
    [self.navigationController pushViewController:_controller animated:YES];
    
}

#pragma mark 设置默认城市
-(void)setSearchCity:(NSString *)cityText
{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:cityText forKey:kLastSearch_City];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString * )getSearchCity
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
//    NSDictionary *dict=[defaults dictionaryRepresentation];
//    DLog(@"=====%@",dict);
    
   city =  [defaults stringForKey:kLastSearch_City];
    if (city!=nil) {
        return city;
    }else{
        city =[defaults stringForKey:kLocation_City];
    }
    
    return city;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar delegate

#pragma mark 隐藏背景表格
 -(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [controller.searchResultsTableView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.8]];
    [controller.searchResultsTableView setRowHeight:800];
    [controller.searchResultsTableView setScrollEnabled:NO];
    
    UITableView *view =searchDisplayController.searchResultsTableView;
    [view removeFromSuperview];
//    for (UIView *subview in view.subviews) {
//        if ([subview class]==[UILabel class]) {
//            [subview removeFromSuperview];
//            return NO;
//        }
//    }
    return NO;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchDisplayController.searchResultsTableView setHidden:YES];
    [searchDisplayController.searchResultsTableView  setAlpha:0.0];
    //    if (!hasDefaultCity) {
    //        DXAlertView *alert=[[DXAlertView alloc]initWithTitle:@"提示" contentText:@"请先选择城市" leftButtonTitle:nil rightButtonTitle:@"确定"];
    //        [alert show];
    //        return;
    //    }
    //    if (0==searchText.length) {
    //        return;
    //    }
    
    //    [_baiduDatasource removeAllObjects];
    
    //    NSData *data=[WebRequest findBaiduSuggestion:city query:searchText];
    //    if(data==nil)
    //        return;
    //
    //    NSError *error;
    //    NSDictionary *suggestion= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    //    NSArray *result=[suggestion objectForKey:@"result"];
    //    if (error!=nil || result.count<=0   ) {
    //        return;
    //    }
    //    for (int i=0; i<result.count; i++) {
    //        BaiduSuggestion *bs=[BaiduSuggestion new];
    //        NSDictionary *d1=[result objectAtIndex:i];
    //
    //        bs.name=[d1 objectForKey:@"name"];
    //        bs.city=[d1 objectForKey:@"city"];
    //        bs.district=[d1 objectForKey:@"district"];
    //        bs.business=[d1 objectForKey:@"business"];
    //        bs.cityid=[d1 objectForKey:@"cityid"];
    //
    //        [_baiduDatasource addObject:bs];
    //    }
    
    
    
    //[self.tableView reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

    NSString *text= searchBar.text;
    if (text.length<=0) {
        return;
    }
    
    NSString *tmpcity=[self getSearchCity];
    if (tmpcity==nil) {
        DXAlertView *alert=[[DXAlertView alloc]initWithTitle:@"提示" contentText:@"请先选择城市" leftButtonTitle:nil rightButtonTitle:@"确定"];
        [alert show];
        return;
    }
    
   BOOL isConnected = [WebRequest isConnectionAvailable];
    if (!isConnected) {
        MBProgressHUD *hd =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hd.mode=MBProgressHUDModeText;
        hd.labelText=@"网络连接失败";
        [hd show:YES];
        
        [hd hide:YES afterDelay:2.0];
        return;
    }
    
    hud =[[MBProgressHUD alloc]initWithView:self.view];
    hud.dimBackground=NO;
    [self.view addSubview:hud];
    hud.labelText=@"加载中";
    [hud show:YES];
    
    
    [self reloadData:text];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    return cell;
}


-(void)reloadData:(NSString *)searchText{
 
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    __block Rents *_allSearchRents;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WebRequest findSearchString:city searchString:searchText id:nil typeId:nil priceId:nil sourceId:nil  onCompletion:^(Rents *allRents, NSError *error) {
        if (error==nil) {
            _allSearchRents = allRents;
        }
        } ];
        
       dispatch_async(dispatch_get_main_queue(), ^{
           [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
           [hud hide:YES];
           if (_allSearchRents.rents.count<=0) {
               MBProgressHUD *hudMsg=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
               hudMsg.mode=MBProgressHUDModeText;
               hudMsg.labelText=@"没有数据";
               [hudMsg hide:YES afterDelay:2.0];
               
           }else{
               //[self searchBarCancelButtonClicked:_searchBar];
               
               searchResultController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultController"];
               searchResultController.city=city;
               searchResultController.searchText=searchText;
               searchResultController.datasource=_allSearchRents;
               [self.navigationController pushViewController:searchResultController animated:YES];
           }
       });
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"搜索页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"搜索页面"];
}

@end
