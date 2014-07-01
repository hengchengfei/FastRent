//
//  NearbyViewController.m
//  Test2
//
//  Created by heng chengfei on 14-1-7.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "NearbyViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DetailViewController.h"
#import "NearbyViewCell.h"
#import "Rent.h"
#import "WebRequest.h"
//#import "MBProgressHUD.h"
#import "Reachability.h"
//#import "MKNetworkEngine.h"
#import "DXAlertView.h"
#import "Address.h"
#import "WYPopoverController.h"
#import "MBProgressHUD.h"

#import "PullDownButton.h"
#import "Toast+UIView.h"
#import "MobClick.h"

//左边距大小
#define kLeftOrigon 5.0


@interface NearbyViewController ()
{
    EGORefreshTableHeaderView *_refreshTableView;
    BOOL _reloading;
    
    BOOL isAddedCombox;
    
    SelectionViewController *selectionController;
    WYPopoverController *popoverController;
    
    
 
    Rents *allRents;
    
    CLGeocoder *_geocoder;
    CGFloat _latitude;
    CGFloat _longitude;
    //NSString *_address;
    
    RentComboxs *_comboxsData;
    NSNumber *_distanceId;
    NSNumber *_priceId;
    NSNumber *_rentTypeId;
    NSNumber *_sourceId;
    NSString *_defaultDistanceName;
    
    UITableViewCell *moreCell;
    
    Address *_address;
    
    MBProgressHUD *hudLoading;
}

@end

@implementation NearbyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    hudLoading=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hudLoading.labelText=@"加载中";
    [hudLoading show:YES];
    
    //导航栏设置
    [self setTitle:self.navTitle];
    [self setNavLeftButton];
    
    //View样式设置
    [self initStyle];
    
    //检测网络连接
    if (![self checkInternet]) {
        return;
    }
    
    //打开地图定位
    [self openMapLocation];
    
    
}

#pragma mark View样式设置
-(void)initStyle{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    if (ISOS7) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.modalPresentationCapturesStatusBarAppearance=NO;
        self.navigationItem.leftBarButtonItem.title=@"";
        self.tabBarController.tabBar.translucent=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.tableView.hidden=YES;
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    if(ISOS7){
        self.tableView.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);//分割线的位置
    }
    
    
    
    //刷新控件
    if (_refreshTableView ==nil) {
        _refreshTableView  = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f, 10.0f, self.view.frame.size.width, 0)];
        _refreshTableView.delegate=self;
        [self.tableView addSubview:_refreshTableView];
    }
    
    //更多
    moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
    moreCell.textLabel.text=@"更多";
    moreCell.textLabel.textColor=[UIColor grayColor];
    moreCell.textLabel.font=[UIFont fontWithName:moreCell.textLabel.font.fontName size:12];
}

#pragma mark 检测网络连接
-(BOOL)checkInternet
{
    BOOL isConnectionNetwork =[WebRequest isConnectionAvailable];
    if (!isConnectionNetwork) {
        //View中间添加刷新按钮
        //hudLoading.labelText=@"网络连接失败";
        [hudLoading hide:YES] ;
        //hudLoading.labelText=@"加载中";
        [self addLoadingFaile];
        //      MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //        hud.labelFont=[UIFont systemFontOfSize:14];
        //        hud.labelText=@"网络连接失败";
        //        hud.mode=MBProgressHUDModeText;
        //        [hud showAnimated:YES whileExecutingBlock:^{
        //            sleep(1);
        //        } completionBlock:^{
        //            [hud removeFromSuperview];
        //
        //
        //
        //        }];
        
        return NO;
    }
    return YES;
}



#pragma mark 开启地图功能
-(void)openMapLocation
{
    
    if (![CLLocationManager locationServicesEnabled]) {
        [self openGPSTips];
    }else{
        locationManager=[CLLocationManager new];
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        locationManager.distanceFilter=100.0f;//当位置超过多少米时更新
        [locationManager startUpdatingLocation];
    }
}


-(void)addLoadingFaile
{
    UIImage *image=[UIImage imageNamed:@"failView1.png"];
    CGSize size=self.view.frame.size;
    CGSize imageSize=CGSizeMake(150, 150);
    CGRect rect=CGRectMake(size.width/2-imageSize.width/2, size.height/2-imageSize.height/2-44
                           , imageSize.width, imageSize.height);
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.frame=rect;
    [button addTarget:self action:@selector(didClickRefresh:) forControlEvents:UIControlEventTouchUpInside];

    [self.view insertSubview:button aboveSubview:self.tableView];
//    UIImageView *view=[[UIImageView alloc]initWithImage:image];
//    view.frame=rect;
    
//    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickRefresh:)];
//    view.userInteractionEnabled=YES;
//    [view addGestureRecognizer:gesture];
//    
//    
//    [self.view insertSubview:view belowSubview:self.tableView];
    
}

//-(void)addRefreshButton
//{
//    if (btnRefresh && btnRefresh.superview!=nil) {
//        return;
//    }
//    btnRefresh=[[UIButton alloc]init];
//    [btnRefresh setBackgroundColor:[UIColor clearColor]];
//    [btnRefresh addTarget:self action:@selector(didClickRefresh:) forControlEvents:UIControlEventTouchUpInside];
//    [btnRefresh setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [btnRefresh setBackgroundImage:[UIImage imageWithColor:[UIColor purpleColor]] forState:UIControlStateHighlighted];
//    [btnRefresh setTitle:@"刷新重试" forState:UIControlStateNormal];
//    btnRefresh.center=self.view.center;
//    
//    CGRect frame=self.view.frame;
//    btnRefresh.frame=CGRectMake(frame.size.width/2-40, frame.size.height/2-50, 80, 30);
//    
//    //设置边框
//    [btnRefresh.layer setMasksToBounds:YES];
//    [btnRefresh.layer setCornerRadius:2.0];
//    [btnRefresh.layer setBorderWidth:1.0];
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 192/255.0, 192/255.0, 192/255.0, 1 });
//    
//    
//    [btnRefresh.layer setBorderColor:colorref];
//    
//    [self.view addSubview:btnRefresh];
//}

#pragma mark 网络连接后刷新
-(void)didClickRefresh:(id)sender
{
    [sender removeFromSuperview];
    if ([self checkInternet]) {
        //打开地图定位
        [self openMapLocation];
        
        [hudLoading hide:NO];
    }
    
}


#pragma mark -
#pragma mark 设置导航栏上的标题和左侧按钮样式
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


-(void)setNavLeftButton
{
    UIButton *button=[[UIButton alloc]init];
    UIImage *back=[UIImage imageNamed:kPNG_BACK];
    //button.backgroundColor=[UIColor blackColor];
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

#pragma mark -
#pragma mark 下拉刷新操作

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
//下拉被触发调用的委托方法
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    BOOL isConnected =[WebRequest isConnectionAvailable];
    if (!isConnected) {
        [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:1.0 position:@"bottom"];
        return;
    }
    
    [hudLoading show:YES];
    
    _reloading=YES;
    
    
    __block BOOL isSuccess;
    __block NSString *errMsg;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        // [NSThread sleepForTimeInterval:2.0f];
        [WebRequest findNearby:_latitude longitude:_longitude city:_address.city distance:_distanceId price:_priceId type:_rentTypeId source:_sourceId lastRentId:nil onCompletion:^(Rents *rents, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
                errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
            }else{
                isSuccess=YES;
                allRents=rents;
            }
        }] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            //完成加载时，将下拉刷新隐藏
            _reloading=NO;
            [_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
             [hudLoading hide:YES];
            if (!isSuccess) {
                [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:1.0 position:@"bottom"];
                self.tableView.hidden=YES;
                return;
            }
            self.tableView.hidden=NO;
            [self.tableView reloadData];
            
            //定位到第一行
            if (allRents!=nil && allRents.rents.count>0) {
                NSIndexPath *firstpath=[NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:firstpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }else{
                //[self showWarnInfo:@"暂无信息"];
            }
        });
    });
    
}

//返回当前是刷新还是无刷新状态
-(BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

//返回刷新时间的回调方法
-(NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
//滚动控件的委托方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshTableView egoRefreshScrollViewDidScroll:scrollView];
    
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];
}

-(void)reloadTableViewDataSource{
    
}
-(void)doneLoadingTableViewData{
    
}

#pragma mark -
#pragma mark 定位操作
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation  *_currentLocation=[locations lastObject];
    CLLocationCoordinate2D coor = _currentLocation.coordinate;//手机GPS
    
    _latitude = coor.latitude;
    _longitude =coor.longitude;
    
    hudLoading.labelText=@"加载中";
    [hudLoading show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        
        //取得所有下拉框的值
        __block BOOL isSuccess=NO;
        __block NSString *errMsg;
        [WebRequest findComboxs:^(RentComboxs *bo, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
                errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
            }else{
                isSuccess=YES;
                _comboxsData=bo;
            }
        }];
        if (isSuccess) {
            [WebRequest findAddress:_latitude longitude:_longitude onCompletion:^(Address * address, NSError *error) {
                if (error!=nil) {
                    isSuccess=NO;
                    errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
                }else{
                    isSuccess=YES;
                    _address=address;
                }
            }];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [hudLoading hide:NO];
            if (!isSuccess) {
                [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:2.0 position:@"bottom"];
                self.tableView.hidden=YES;
                return;
            }
            
            if (_address.formattedAddress==nil) {
                                [self.view makeToast:@"定位失败(不在中国)" duration:1.0 position:@"bottom"];
                return;
            }
            
            //记录事件
            NSDictionary *dict = @{@"城市": _address.city};
            [MobClick event:@"CityEvent" attributes:dict];
            
            [self.view makeToast:_address.formattedAddress
                        duration:2.0
                        position:@"bottom"];
            [self addComboxBox];
            [self setDefaultCity:_address.city];
            [self reloadData];
        });
        
    });
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DLog(@"======%@",error);
    [hudLoading hide:NO];
    switch (error.code) {
        case kCLErrorDenied:
            [self openGPSTips];
            break;
        case kCLErrorLocationUnknown:
        {
            [locationManager startUpdatingLocation];
            break;
        }
            
        default:
            break;
    }
}



-(void)warnMessage:(NSString *)msg
{
    MBProgressHUD *hd =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hd.mode=MBProgressHUDModeText;
    hd.labelText=msg;
    [hd show:YES];
    
    [hd hide:YES afterDelay:2.0];
}

#pragma mark 设置默认城市
-(void)setDefaultCity:(NSString *)cityText
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:cityText forKey:kLocation_City];
    [[NSUserDefaults standardUserDefaults]synchronize];
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
#pragma mark -
#pragma mark 添加下拉框
-(void)addPullButton:(NSString *)text font:(UIFont *)font frame:(CGRect)frame titleDatasource:(NSArray *)titleDatasource idDatasource:(NSArray *)idDatasource
{
    //addTarget除了传递self之外，不能传递参数，所以最好自定义一个button
    PullDownButton *button=[[PullDownButton alloc]initWithFrame:frame labelText:text font:font];
    button.titleArray=titleDatasource;
    button.idArray=idDatasource;
    
    [button addTarget:self action:@selector(loadPullDownDatas:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}
-(void)loadPullDownDatas:(PullDownButton *)sender
{
    
    WYPopoverBackgroundView *bkView =[WYPopoverBackgroundView appearance];
    bkView.outerCornerRadius=0.0;
    //bkView.outerStrokeColor=[UIColor orangeColor];
    //bkView.glossShadowColor=[UIColor orangeColor];
    selectionController= [self.storyboard instantiateViewControllerWithIdentifier:@"SelectionController"];
    selectionController.popDelegate=self;
    selectionController.fromPullDownButton=sender;
    selectionController.titleDatasource=sender.titleArray;
    selectionController.idDatasource=sender.idArray;
    popoverController =[[WYPopoverController alloc]initWithContentViewController:selectionController];
    [popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
}

-(void)popoverHandler:(SelectionViewController *)controller text:(NSString *)text id:(NSNumber *)id
{
    //记录事件
    NSDictionary *dict = @{@"text": text,@"id":[id stringValue]};
    [MobClick event:@"ComboxSelectEvent" attributes:dict];
    
    [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionScale];
    
    for(int i=0;i<_comboxsData.rentComboxs.count;i++){
        RentCombox *combox=(RentCombox *)[_comboxsData.rentComboxs objectAtIndex:i];
        NSInteger type=[[combox type]integerValue];
        NSInteger _id=[[combox id]integerValue];
        if([id integerValue] == _id){
            if(type==0){
                _distanceId=id;
            }else if(type==1){
                _priceId=id;
            }else if(type==3){
                _sourceId=id;
            }
            break;
        }
    }
    
    //change pulldown nam
    PullDownButton *button= controller.fromPullDownButton;
    NSArray *views =  button.subviews;
    for(int i=0;i<views.count;i++){
        if([[views objectAtIndex:i] isKindOfClass:[UILabel class]]){
            UILabel *label=(UILabel *)[views objectAtIndex:i];
            label.text=text;
            break;
        }
    }
    
    [self reloadData];
}

#pragma mark 添加下拉列表框
-(void)addComboxBox
{
    //避免重复添加
    if (isAddedCombox) {
        return;
    }
    
    NSMutableArray *  distanceTitleDatasource = [[NSMutableArray alloc]init];
    NSMutableArray *  distanceIdDatasource=[[NSMutableArray alloc]init];
    NSMutableArray * priceTitleDatasource = [[NSMutableArray alloc]init];
    NSMutableArray * priceIdDatasource=[[NSMutableArray alloc]init];
    NSMutableArray *  sourceTitleDatasource = [[NSMutableArray alloc]init];
    NSMutableArray *  sourceIdDatasource=[[NSMutableArray alloc]init];
    
    for (int i=0; i<_comboxsData.rentComboxs.count; i++) {
        RentCombox *combox =(RentCombox *)[_comboxsData.rentComboxs objectAtIndex:i];
        NSNumber *datatype=[combox type];
        switch (datatype.intValue) {
            case 0:
            {
                [distanceTitleDatasource addObject:combox.name];
                [distanceIdDatasource addObject:combox.id];
                break;
            }
            case 1:
            {
                [priceTitleDatasource addObject:combox.name];
                [priceIdDatasource addObject:combox.id];
                break;
            }
            case 2:
                break;
            case 3:
            {
                [sourceTitleDatasource addObject:combox.name];
                [sourceIdDatasource addObject:combox.id];
                break;
            }
            default:
                break;
        }
    }
    
    UIFont *font=[UIFont systemFontOfSize:14];
    CGSize screenSize=[[UIScreen mainScreen]bounds].size;
    CGFloat x=-1.0;
    CGFloat y=-1.0;
    CGFloat width=screenSize.width/3.0;
    CGFloat height=40.0;
    
    CGRect distanceFrame=CGRectMake(x, y, width, height);
    CGRect priceFrame=CGRectMake(x+width, y, width, height);
    CGRect sourceFrame=CGRectMake(x+(width*2), y, width, height);
    
    
    [self addPullButton:@"距离" font:font frame:distanceFrame  titleDatasource:distanceTitleDatasource idDatasource:distanceIdDatasource];
    //btnDistance.tag=0;
    
    [self addPullButton:@"价格" font:font frame:priceFrame titleDatasource:priceTitleDatasource idDatasource:priceIdDatasource];
    
    [self addPullButton:@"来源" font:font frame:sourceFrame titleDatasource:sourceTitleDatasource idDatasource:sourceIdDatasource];
    
    isAddedCombox=YES;
}


-(void)reloadData
{
    
    BOOL isConnected =[WebRequest isConnectionAvailable];
    if (!isConnected) {
        [hudLoading hide:NO];
        [self warnMessage:@"网络连接失败"];
        return;
    }
    
    [hudLoading show:YES];
    self.tableView.hidden=YES;
    
    __block BOOL isSuccess;
    __block NSString *errMsg;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        // [NSThread sleepForTimeInterval:2.0f];
        [WebRequest findNearby:_latitude longitude:_longitude city:_address.city distance:_distanceId price:_priceId type:_rentTypeId source:_sourceId lastRentId:nil onCompletion:^(Rents *rents, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
                errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
            }else{
                isSuccess=YES;
                allRents=rents;
            }
        }] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isSuccess) {
                [hudLoading hide:YES];
                [self warnMessage:@"加载失败"];
                self.tableView.hidden=YES;
                return;
            }
            
            [hudLoading hide:YES];
            self.tableView.hidden=NO;
            [self.tableView reloadData];
            
            //定位到第一行
            if (allRents!=nil && allRents.rents.count>0) {
                NSIndexPath *firstpath=[NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:firstpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }else{
                //[self showWarnInfo:@"暂无信息"];
            }
        });
    });
}

/**
 Map
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //[locationManager stopUpdatingLocation];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NearbyViewCell *cell = (NearbyViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    DetailViewController *destinct = segue.destinationViewController;
    destinct.id= [NSNumber numberWithInt:[cell.id.text intValue]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark -
#pragma mark Table操作
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (allRents && allRents.rents.count>0) {
        return  allRents.rents.count+1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row ==allRents.rents.count) {
        return moreCell;
    }
    static NSString *RentCellIdentifier =@"NearbyCell";
    
    if (allRents && allRents.rents.count>0) {
        Rent *rent = [allRents.rents objectAtIndex:row];
        
        NearbyViewCell *RentCell=[tableView dequeueReusableCellWithIdentifier:RentCellIdentifier];
        if (RentCell==nil) {
            RentCell =(NearbyViewCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RentCellIdentifier];
        }
        
        
        if ([rent houseImg]!=nil) {
            NSURL *url =[NSURL URLWithString:[rent houseImg]];
            [RentCell.img setImageWithURL:url placeholderImage:[UIImage imageNamed:kPNG_Loading_100]];
        }
        
        RentCell.title.text=rent.publishTitle;
        RentCell.price.text=[NSString stringWithFormat:@"%@元/月",rent.rentMoney];
        RentCell.rentType.text=[rent rentType];
        RentCell.houseType.text=[rent houseType];
        RentCell.agencyType.text=[rent agencyType];
        RentCell.updateTime.text=rent.updateTime;
        RentCell.backgroundColor = [UIColor clearColor];
        RentCell.id.text = [[rent id]stringValue];
        if (rent.distance!=nil) {
            NSString *displayDistance =@"";
            int dd =rent.distance.intValue;
            if (dd<1000) {
                displayDistance=[NSString stringWithFormat:@"%d m",dd];
            }else{
                float idd = dd/1000.0f;
                displayDistance=[NSString stringWithFormat:@"%.2f km",idd];
            }
            RentCell.distance.text=displayDistance;
        }
        
        return RentCell;
    }
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath row] == allRents.rents.count) {
        NSString *text=moreCell.textLabel.text;
        
        if ([text compare:@"更多"]!=0) {
            UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        moreCell.textLabel.text =@"正在加载...";
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self loadedMoreDatas];
        return;
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == allRents.rents.count) {
        return 40.0f;
    }
    
    return 74.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (cell ==moreCell && [self isAutoLoadMore]) {
        moreCell.textLabel.text=@"正在加载...";
        [self loadedMoreDatas];
    }
}

-(void)loadedMoreDatas
{
    BOOL isConnected = [WebRequest isConnectionAvailable];
    if (!isConnected) {
        MBProgressHUD *hd =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hd.mode=MBProgressHUDModeText;
        hd.labelText=@"网络连接失败";
        [hd show:YES];
        
        [hd hide:YES afterDelay:2.0];
        return;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Rent *rent=  [allRents.rents lastObject];
        
        __block BOOL isSuccess;
        __block NSString *errMsg;
        __block Rents *moreRents;
        [WebRequest findNearby:_latitude longitude:_longitude city:_address.city distance:_distanceId price:_priceId type:_rentTypeId source:_sourceId
                    lastRentId:rent.id onCompletion:^(Rents *rents, NSError *error) {
                        if (error!=nil) {
                            isSuccess=NO;
                            errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
                        }else{
                            isSuccess=YES;
                            moreRents=rents;
                        }
                    }];
        
        if (moreRents!=nil && moreRents.rents.count>0) {
            [allRents.rents addObjectsFromArray:moreRents.rents];
        }
        
        
        NSMutableArray *moreIndexpath = [NSMutableArray arrayWithCapacity:moreRents.rents.count];
        for (int i=0; i<moreRents.rents.count; i++) {
            NSIndexPath *path =[NSIndexPath indexPathForRow:[allRents.rents indexOfObject:[moreRents.rents objectAtIndex:i]] inSection:0];
            [moreIndexpath addObject:path];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (moreIndexpath.count>0) {
                //插入数据
                [self.tableView insertRowsAtIndexPaths:moreIndexpath withRowAnimation:UITableViewRowAnimationFade];
            }
            
            if(moreIndexpath.count <10){
                moreCell.textLabel.text =@"没有更多信息了";
            }else{
                moreCell.textLabel.text =@"更多";
            }
            
        });
        
    });
    
    
}


#pragma mark 是否自动加载更多
-(BOOL)isAutoLoadMore{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL isAutoload = [defaults boolForKey:kIsAutoLoadMore];
    if (isAutoload) {
        return YES;
    }
    return NO;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"附近列表页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"附近列表页面"];
}
@end
