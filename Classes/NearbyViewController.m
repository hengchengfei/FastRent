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

typedef enum {
    StartLocation,//开始定位
    LocationError,//定位失败
    LocationSuccess//定位成功
}LoadingType;

@interface NearbyViewController ()
{
    EGORefreshTableHeaderView *_refreshTableView;
    BOOL _reloading;
    
    BOOL isAddedCombox;
    
    SelectionViewController *selectionController;
    WYPopoverController *popoverController;
    
    UIImageView *_loadingImageView;
    
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

    //View样式设置
    [self initStyle];
    
    //检测网络连接
    if (![self checkInternet]) {
        return;
    }
    
    [self loadingImage];
    
    //打开地图定位
    [self openMapLocation];


}


-(void)loadingImage{
    _loadingImageView=[[UIImageView  alloc]initWithFrame:self.view.frame];
    _loadingImageView.frame=CGRectMake(0, 0, 200, 225);
    _loadingImageView.center =CGPointMake(self.view.center.x, self.view.center.y-50);
    _loadingImageView.animationImages=[NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"LoadingImage_01.png"],
                                       [UIImage imageNamed:@"LoadingImage_02.png"],
                                       nil];
    _loadingImageView.animationDuration=0.5;
    _loadingImageView.animationRepeatCount=0;
    [_loadingImageView startAnimating];
    [self.view addSubview:_loadingImageView];
    
    
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
    //self.tableView.hidden=YES;
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
        [self setTitle:LocationError subTitle:nil];
        [hudLoading hide:YES] ;
        //hudLoading.labelText=@"加载中";
        [self addLoadingFaile];
        //self.navigationItem.rightBarButtonItem.enabled=NO;
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
   //  self.navigationItem.rightBarButtonItem.enabled=YES;
    return YES;
}



#pragma mark 开启地图功能
-(void)openMapLocation
{
    //导航栏设置
    [self setTitle:StartLocation subTitle:nil];
    [self setRightButton:@"重新定位"];
    
    if (![CLLocationManager locationServicesEnabled]) {
        [self openGPSTips];
    }else{
        locationManager=[CLLocationManager new];
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        [locationManager setPausesLocationUpdatesAutomatically:YES];
        
        locationManager.distanceFilter=500.0f;//当位置超过多少米时更新
        [locationManager startUpdatingLocation];
    }
}


-(void)addLoadingFaile
{
    //先判断有没有
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag==1) {
            return;
        }
    }

    UIImage *image=[UIImage imageNamed:@"GLOBALRefresh.png"];
    UIImage *image2=[UIImage imageNamed:@"GLOBALRefresh_pressed.png"];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:image2 forState:UIControlStateHighlighted];
    
    button.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    button.center=CGPointMake(self.view.center.x, self.view.center.y-60);
    [button addTarget:self action:@selector(didClickRefresh:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=1;
    
    UILabel *refreshText=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    refreshText.center=CGPointMake(self.view.center.x, self.view.center.y-65+image.size.height);
    refreshText.textColor=[UIColor blackColor];
    refreshText.font=[UIFont systemFontOfSize:15.0];
    refreshText.text=@"点击屏幕，重新加载";
    refreshText.tag=100;
    [self.view insertSubview:button aboveSubview:self.tableView];
    [self.view insertSubview:refreshText aboveSubview:self.tableView];
    
    
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
    if ([self checkInternet]) {
        [sender removeFromSuperview];//删除错误画面
        
        for (UIView *view in self.view.subviews) {
            if([view isKindOfClass:[UILabel class]] && view.tag==100){
                [view removeFromSuperview];
                break;
            }
        }
        
        //打开地图定位
        [self openMapLocation];
        
        //[hudLoading hide:NO];
        [_loadingImageView removeFromSuperview];
    }
    
}


#pragma mark -
#pragma mark 设置导航栏上的标题和左侧按钮样式
-(void)setTitle:(LoadingType )loadingType  subTitle:(NSString *)subTitle
{
    
    UIFont *font = [[UIFont alloc]init];
    NSString *startLocation = @"正在加载";
    NSString *locationError=@"定位失败";
    NSString *title =@"当前位置";
    
    if (loadingType==StartLocation  ) {
        font=[UIFont systemFontOfSize:16.0];
        title=startLocation;
    }else if(loadingType==LocationSuccess){
        font=[UIFont systemFontOfSize:13.0];
    }else if(loadingType==LocationError){
        font=[UIFont systemFontOfSize:16.0];
        title =locationError;
    }
    
    CGSize titleSize=MB_TEXTSIZE(title, font);
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, titleSize.width , titleSize.height)];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=title;
    titleLabel.font=font;
    titleLabel.textColor=[UIColor whiteColor];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.userInteractionEnabled=YES;
    
    if (loadingType==StartLocation  ) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        CGPoint p=CGPointMake(titleSize.width, -5);
        gradientLayer =[self getLoadingView:p];
        [titleLabel.layer addSublayer:gradientLayer];
    }
    
    
    //
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
     view.backgroundColor=[UIColor clearColor];
        [view addSubview:titleLabel];
    
    CGFloat maxWidth =titleSize.width;
    if (subTitle!=nil) {
        UIFont *font1=[UIFont systemFontOfSize:12.0];
        CGSize titleSize1=MB_TEXTSIZE(subTitle, font1);
        UILabel *titleLabel1=[[UILabel alloc]initWithFrame:CGRectMake(0, titleSize.height+2, titleSize1.width, titleSize1.height)];
        titleLabel1.backgroundColor=[UIColor clearColor];
        titleLabel1.text=subTitle;
        titleLabel1.font=font1;
        titleLabel1.textColor=[UIColor whiteColor];
        [titleLabel1 setTextAlignment:NSTextAlignmentCenter];
        if (maxWidth<titleSize1.width) {
            maxWidth=titleSize1.width;
        }
        [view addSubview:titleLabel1];
        view.frame=CGRectMake(0, 0, maxWidth, titleSize.height + 2 + titleSize1.height);
    }
    
    //将“当前位置”的中心X设置为view的中心X
    CGPoint centerX = CGPointMake(view.center.x, titleLabel.center.y);
    titleLabel.center= centerX;
    
    self.navigationItem.titleView=view;
    
}


-(void)setRightButton:(NSString *)text
{
    UIButton *button=[[UIButton alloc]init];
    UIFont *font =[UIFont systemFontOfSize:12.0];
    CGSize size =MB_TEXTSIZE(text, font);
    [button setFrame:CGRectMake(0, 0, size.width, size.height)];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:font];
    [button addTarget:self action:@selector(openMapLocation) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=item;
    
    //    UIImage *back=[UIImage imageNamed:kPNG_BACK];
    //    //button.backgroundColor=[UIColor blackColor];
    //    button.frame = CGRectMake(0, 0, back.size.width, back.size.height);
    //    [button setBackgroundImage:back forState:UIControlStateNormal];
    //    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    //
    //    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    //    self.navigationItem.leftBarButtonItem=item;
    
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
    
    //[locationManager startUpdatingLocation];
    //   [hudLoading show:YES];
    //
    _reloading=YES;
    //
    //
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
            //[hudLoading hide:YES];
            if (!isSuccess) {
                [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:1.0 position:@"bottom"];
                //self.tableView.hidden=YES;
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
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
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
        if(_comboxsData==nil){
            [WebRequest findComboxs:^(RentComboxs *bo, NSError *error) {
                if (error!=nil) {
                    isSuccess=NO;
                    errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
                }else{
                    isSuccess=YES;
                    _comboxsData=bo;
                }
            }];
        }else{
            isSuccess=true;
        }
        
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
            //[hudLoading hide:NO];
            [_loadingImageView removeFromSuperview];
            if (!isSuccess) {
                [self setTitle:LocationError subTitle:nil];
                [self addLoadingFaile];
                [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:2.0 position:@"bottom"];
                [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                //self.tableView.hidden=YES;
                
                return;
            }
            
            if (_address.formattedAddress==nil) {
                [self setTitle:LocationError subTitle:nil];
                [self addLoadingFaile];
                [self.view makeToast:@"定位失败(不在中国)" duration:1.0 position:@"bottom"];
                [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                return;
            }
            
            //记录事件
            NSDictionary *dict = @{@"城市": _address.city};
            [MobClick event:@"CityEvent" attributes:dict];
            
            [self setTitle:LocationSuccess subTitle:_address.location];
            
            [self.view makeToast:_address.location
                        duration:2.0
                        position:@"bottom"];
            [self addComboxBox];
            [self setDefaultCity:_address.city];
            [self reloadData];
            
            
            //正确定位后，则停止
            [locationManager stopUpdatingLocation];
        });
        
    });
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DLog(@"======%@",error);
    //[hudLoading hide:NO];
    [_loadingImageView removeFromSuperview];
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
        //导航栏设置
        [self setTitle:LocationError subTitle:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    };
    
    view.rightBlock=^{
        //导航栏设置
        [self setTitle:LocationError subTitle:nil];
        //[self.navigationController popViewControllerAnimated:YES];
    };
    
    view.dismissBlock=^{
        //导航栏设置
        [self setTitle:LocationError subTitle:nil];
        //[self.navigationController popViewControllerAnimated:YES];
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    BOOL isConnected =[WebRequest isConnectionAvailable];
    if (!isConnected) {
        //[hudLoading hide:NO];
        [_loadingImageView removeFromSuperview];
        [self warnMessage:@"网络连接失败"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        return;
    }
    
    [hudLoading show:YES];
    //self.tableView.hidden=YES;
    
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
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (!isSuccess) {
                [hudLoading hide:YES];
                [self warnMessage:@"加载失败"];
                //self.tableView.hidden=YES;
                return;
            }
            
            [hudLoading hide:YES];
            // self.tableView.hidden=NO;
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
    //NSString *aa= [segue identifier];
    UINavigationController *nav = segue.destinationViewController;
    DetailViewController *destinct = [nav.childViewControllers objectAtIndex:0];
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
    }else{
        //        NearbyViewCell *cell=(NearbyViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        //        UIStoryboard *st = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        //        DetailViewController *cc=[st instantiateViewControllerWithIdentifier:@"DetailController"];
        //        cc.id= [NSNumber numberWithInt:[cell.id.text intValue]];
        //
        //        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:cc];
        //        nav.navigationBar.barTintColor = selectedItemTitleColor;
        //        [self presentViewController:nav animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    BOOL isConnected = [WebRequest isConnectionAvailable];
    if (!isConnected) {
        MBProgressHUD *hd =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hd.mode=MBProgressHUDModeText;
        hd.labelText=@"网络连接失败";
        [hd show:YES];
        
        [hd hide:YES afterDelay:2.0];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
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
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
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
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
}

#pragma mark 导航栏上添加旋转动画
-(CAGradientLayer *) getLoadingView:(CGPoint)orgin{
    
    //声明加载view的动画路径
    UIBezierPath *pacmanOpenPath;
    
    CGFloat radius = 5.0f;
    CGPoint arcCenter = CGPointMake(radius, radius);
    
    //定制一段圆弧
    pacmanOpenPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                      
                                                    radius:radius
                      
                                                startAngle: 0
                      
                                                  endAngle: 3 * M_PI / 2
                      
                                                 clockwise:YES];
    
    //生成color数组
    NSMutableArray *colors = nil;
    if (colors == nil) {
        colors = [[NSMutableArray alloc] initWithCapacity:3];
        UIColor *color = nil;
        color = [UIColor whiteColor];
        [colors addObject:(id)[color CGColor]];
        color = [UIColor grayColor];
        [colors addObject:(id)[color CGColor]];
    }
    
    
    //CAGradientLayer 通过指定颜色，一个开始的点，一个结束的点和梯度类型使你能够简单的在层上绘制一个梯度，效果就是颜色渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    //在指定的color中绘制渐变层
    [gradientLayer setColors:colors];
    gradientLayer.frame = CGRectMake(orgin.x, orgin.y, 30, 30);
    
    //在 (20, 20, 100, 100) 位置绘制一个颜色渐变的层
    //[self.view.layer addSublayer:gradientLayer];
    
    //CAShapeLayer 通过创建一个核心图像路径，并且分配给CAShaperLayer的path属性，从而为需要的形状指定路径。 可以指定填充路径之外的颜色，路径内的颜色，绘制路径，线宽，是否圆角等等
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    shapeLayer.fillMode = kCAFillRuleEvenOdd;
    
    shapeLayer.path = pacmanOpenPath.CGPath;
    
    shapeLayer.strokeColor = [UIColor yellowColor].CGColor;
    
    shapeLayer.lineWidth = 2.0f;
    
    shapeLayer.lineJoin = kCALineJoinRound;
    
    
    //当你使用时，奇数的值被绘制，然后偶数的值不被绘制。例如，如果你指定5，10，15，20，笔画将会有5个单元被绘制，接下来10不被绘制，15被绘制，20不被绘制。这种模式可以使用你喜欢的间隙来指定。请记住：奇数等于绘制而偶数不绘制。这些单元是被放在了一个放置NSNumber对象的NSArray的数组中，如果你在NSSArray中放置其他东西，会带来一些异常的效果。
    //    [shapeLayer setLineDashPattern:
    //    [NSArray arrayWithObjects:[NSNumber numberWithInt:20], [NSNumber numberWithInt:15],
    //     nil]];
    
    
    shapeLayer.lineCap = kCALineCapRound;
    
    shapeLayer.frame = CGRectMake(10, 10, 10, 10);
    
    //所有继承于CALayer的核心动画层都有一个属性叫做mask.这个属性能够使你给层的所有内容做遮罩，除了层面罩中已经有的部分，它允许仅仅形状层绘制的部分显示那部分的图像。  我们将shapeLayer作为这个遮罩，显示出来的效果就是一个有着渐变填充色的圆弧
    gradientLayer.mask = shapeLayer;
    
    
    //最重要的显示内容已经有了，接下来就是让图层动起来，所以加一个旋转动画
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    spinAnimation.fromValue = [NSNumber numberWithInt:0];
    spinAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    spinAnimation.duration = 2;
    spinAnimation.repeatCount = HUGE_VALF;
    
    [shapeLayer addAnimation:spinAnimation forKey:@"shapeRotateAnimation"];
    
    //现在圆弧就能够旋转了，但是我们发现渐变色是固定的位置，感觉就像是固定的背景色，为了达到一种动态的渐变，所以给gradientLayer也加上旋转动画效果，这样就是一段旋转的有着渐变效果的圆弧
    [gradientLayer addAnimation:spinAnimation forKey:@"GradientRotateAniamtion"];
    
    return gradientLayer;
}
@end
