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
#import "WebRequest.h"
//#import "MBProgressHUD.h"
#import "Reachability.h"
//#import "MKNetworkEngine.h"
#import "DXAlertView.h"
#import "Address.h"
#import "WYPopoverController.h"
#import "MBProgressHUD.h"

#import "Toast+UIView.h"
#import "MobClick.h"

////////////
#import "ComboxVo.h"
#import "FRComboxView.h"
#import "FRComboxItem.h"

//左边距大小
#define kLeftOrigon 5.0
typedef enum {
    StartLocation,//开始定位
    LocationError,//定位失败
    LocationSuccess//定位成功
}LoadingType;

@interface NearbyViewController ()
{
    BOOL _reloading;
    
    BOOL isAddedCombox;
    
    WYPopoverController *popoverController;
    
    UIImageView *_loadingImageView;
    
    //Rents *allRents;
    
    CLGeocoder *_geocoder;
    CGFloat _latitude;
    CGFloat _longitude;
    
    NSString *_city;
    
    NSNumber *_distanceId;
    NSNumber *_priceId;
    NSNumber *_rentTypeId;
    NSNumber *_sourceId;
    NSString *_defaultDistanceName;
    
    UITableViewCell *moreCell;
    
    Address *_address;
    
    //////////
    FilterViewController* fcontroller;
    ComboxVo *_comboxVo;
    NSMutableDictionary *_locationDictionary;
    NSMutableDictionary *_paramsDictionary;
    NSInteger _page;
    HouseVo *_houseVo;
    
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
    
    _locationDictionary =[[NSMutableDictionary alloc]init];
    _paramsDictionary=[[NSMutableDictionary alloc]init];
    _page=1;
}


-(void)addCombox{
    //防止重复添加
    if (fcontroller) {
        return;
    }
    fcontroller =[[FilterViewController alloc]init];
    fcontroller.comboxDatasource=_comboxVo;
    fcontroller.delegate=self;
    [self.view insertSubview:fcontroller.view aboveSubview:self.tableView];
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
    // [self.view setBackgroundColor:[UIColor whiteColor]];
    if (ISOS7) {
        //self.edgesForExtendedLayout=UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars=NO;
        //self.modalPresentationCapturesStatusBarAppearance=NO;
        //self.navigationItem.leftBarButtonItem.title=@"";
        //self.tabBarController.tabBar.translucent=NO;
        // self.automaticallyAdjustsScrollViewInsets=NO;
    }
    //self.tableView.hidden=YES;
    self.tableView.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    
    //    if(ISOS7){
    //        self.tableView.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);//分割线的位置（Storyboard中设置了）
    //    }
    
    
    //更多
    moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
    moreCell.textLabel.textColor=appColor;
    moreCell.textLabel.font=[UIFont fontWithName:moreCell.textLabel.font.fontName size:12];
    if(ISOS7){
        moreCell.separatorInset =UIEdgeInsetsMake(0, 7, 0, 0);
    }
    
    [self moreCellDefault];
    
}

#pragma mark 检测网络连接
-(BOOL)checkInternet
{
    BOOL isConnectionNetwork =[WebRequest isConnectionAvailable];
    if (!isConnectionNetwork) {
        //View中间添加刷新按钮
        [self setTitle:LocationError subTitle:nil];
        [self addLoadingFaile];
        return NO;
    }
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
        if ([view isKindOfClass:[UIButton class]] && view.tag==101) {
            return;
        }
    }
    
    UIImage *image=[UIImage imageNamed:@"GLOBALRefresh.png"];
    UIImage *image2=[UIImage imageNamed:@"GLOBALRefresh_pressed.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:image2 forState:UIControlStateHighlighted];
    
    button.frame=CGRectMake(0, 0, image.size.width, image.size.height);
    button.center=CGPointMake(self.view.center.x, self.view.center.y-80);
    [button addTarget:self action:@selector(didClickRefresh:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=101;
    
    UIFont *font = [UIFont systemFontOfSize:15.0];
    NSString *text=@"点击屏幕，重新加载";
    CGSize size=MB_TEXTSIZE(text, font);
    
    
    //button.frame=CGRectMake(0, 0, button.frame.size.width, button.frame.size.height+size.height+30);
    
    UILabel *refreshText=[[UILabel alloc]initWithFrame:CGRectMake(0, image.size.height+20, size.width, size.height)];
    //refreshText.center=CGPointMake(0, image.size.height+40);
    refreshText.textColor=[UIColor blackColor];
    refreshText.font=font;
    refreshText.text=text;
    [button addSubview:refreshText];
    
    [self.view insertSubview:button aboveSubview:self.tableView];
    
}
-(void)removeLoadingFaile{
    for (UIView *view in self.view.subviews) {
        if (view.tag==101) {
            [view removeFromSuperview];
            break;
        }
    }
}


#pragma mark 网络连接后刷新
-(void)didClickRefresh:(id)sender
{
    if ([self checkInternet]) {
        [sender removeFromSuperview];//删除错误画面
        
        //打开地图定位
        [self openMapLocation];
        
        //[hudLoading hide:NO];
        [_loadingImageView removeFromSuperview];
    }
    
}


-(void)setTitle:(LoadingType )loadingType  subTitle:(NSString *)subTitle
{
    
    UIFont *font = [[UIFont alloc]init];
    NSString *startLocation = @"正在加载";
    NSString *locationError=@"加载失败";
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
    UIFont *font =[UIFont systemFontOfSize:14.0];
    CGSize size =MB_TEXTSIZE(text, font);
    [button setFrame:CGRectMake(0, 5, size.width, size.height)];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:font];
    [button addTarget:self action:@selector(openMapLocation) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=item;
    
}
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
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
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        //取得所有下拉框的值
        __block BOOL isSuccess=NO;
        __block NSString *errMsg;
        if(_comboxVo==nil){
            [WebRequest getFilterInfo:^(ComboxVo *bo, NSError *error) {
                if (error!=nil) {
                    isSuccess=NO;
                    errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
                }else{
                    isSuccess=YES;
                    _comboxVo=bo;
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
                    _city=_address.city;
                }
            }];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[hudLoading hide:NO];
            [_loadingImageView removeFromSuperview];
            [self removeLoadingFaile];
            //[hudLoading hide:YES];
            if (!isSuccess) {
                [self setTitle:LocationError subTitle:nil];
                if (self.tableView.hidden) {
                    [self addLoadingFaile];
                }else{
                    [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:2.0 position:@"bottom"];
                }
                [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                //self.tableView.hidden=YES;
                
                return;
            }
            
            if (_address.formattedAddress==nil) {
                if (self.tableView.hidden) {
                    [self setTitle:LocationError subTitle:nil];
                    [self addLoadingFaile];
                }else{
                    [self setTitle:LocationError subTitle:@"当前位置(不在中国)"];
                    [self.view makeToast:@"当前位置(不在中国)" duration:1.0 position:@"bottom"];
                }
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
                return;
            }
            
            _city=_address.city;

            [_locationDictionary setObject:@"baidu" forKey:@"geotype"];
            [_locationDictionary setObject:_address.lat forKey:@"lat"];
            [_locationDictionary setObject:_address.lng forKey:@"lng"];
            [_locationDictionary setObject:_address.city forKey:@"city"];
            [_locationDictionary setObject:_address.cityCode forKey:@"citycode"];
            
            
            [self.view makeToast:_address.location
                        duration:2.0
                        position:@"bottom"];
            [self addCombox];
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

#pragma 取得下拉框的参数
-(void)getFilterParams:(NSMutableDictionary *)params
{
    _paramsDictionary=params;
    [self setTitle:StartLocation subTitle:nil];
    [self reloadData];
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

-(void)reloadData
{
    _page=1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    [self removeLoadingFaile];
    BOOL isConnected =[WebRequest isConnectionAvailable];
    if (!isConnected) {
        [self setTitle:LocationError subTitle:nil];
        [_loadingImageView removeFromSuperview];
        [self warnMessage:@"网络连接失败"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        return;
    }

    __block BOOL isSuccess;
    __block NSString *errMsg;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        // [NSThread sleepForTimeInterval:2.0f];
        isSuccess=YES;
        if (_city) {
            [WebRequest getListNearby:_locationDictionary filterparams:_paramsDictionary page:_page complete:^(HouseVo *vo, NSError *error) {
                if (error!=nil) {
                    isSuccess=NO;
                    errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
                }else{
                    isSuccess=YES;
                     _houseVo=vo;
                }
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (!isSuccess) {
                [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:2.0 position:@"bottom"];
                [self setTitle:LocationError subTitle:nil];
                return;
            }
            
            [self moreCellDefault];
            [self setTitle:LocationSuccess subTitle:_address.location];
            [self.tableView reloadData];
            
            NSNumber *defaultDistanceId=_houseVo.result.distanceId;
            if (defaultDistanceId!=nil) {
                //设置默认距离
                for (ComboxDatas *result in _comboxVo.result) {
                    for (ComboxData *_data in result.datas) {
                        if ([defaultDistanceId integerValue] ==[_data.id integerValue]) {
                            for (UIView *view in fcontroller.view.subviews) {
                                if ([view isKindOfClass:[FRComboxView class]]) {
                                    for (UIView *subView in view.subviews) {
                                        if ([subView isKindOfClass:[FRComboxItem class]]) {
                                            FRComboxItem *item=(FRComboxItem *)subView;
                                            if ([item.type integerValue]==[TypeDistance integerValue]) {
                                                item.label.text=_data.name;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            return;
                        }
                    }
                }
            }
            
            //定位到第一行
            if (_houseVo.result.datas!=nil && _houseVo.result.datas.count>0) {
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
    if (_houseVo.result.datas  && _houseVo.result.datas .count>0) {
        return  _houseVo.result.datas.count+1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row ==_houseVo.result.datas.count) {
        return moreCell;
    }
    static NSString *RentCellIdentifier =@"NearbyCell";
    
    if (_houseVo.result.datas && _houseVo.result.datas.count>0) {
        HouseData *data = [_houseVo.result.datas  objectAtIndex:row];
        
        NearbyViewCell *RentCell=[tableView dequeueReusableCellWithIdentifier:RentCellIdentifier];
        if (RentCell==nil) {
            RentCell =(NearbyViewCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RentCellIdentifier];
        }
        
        
        if ([data houseImg]!=nil) {
            NSURL *url =[NSURL URLWithString:[data houseImg]];
            [RentCell.img setImageWithURL:url placeholderImage:[UIImage imageNamed:kPNG_Loading_100]];
        }
        
        RentCell.title.text=data.publishTitle;
        RentCell.price.text=[NSString stringWithFormat:@"%@元/月",data.rentMoney];
        RentCell.rentType.text=[data rentType];
        RentCell.houseType.text=[data houseType];
        RentCell.agencyType.text=[data agencyType];
        RentCell.updateTime.text=data.updateTime;
        RentCell.backgroundColor = [UIColor clearColor];
        RentCell.id.text = [[data id]stringValue];
        if (data.distance!=nil) {
            NSString *displayDistance =@"";
            int dd =data.distance.intValue;
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
    
    if ([indexPath row] == _houseVo.result.datas .count) {
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
        //        nav.navigationBar.barTintColor = appColor;
        //        [self presentViewController:nav animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == _houseVo.result.datas .count) {
        return 40.0f;
    }
    
    return 74.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (cell ==moreCell && [self isAutoLoadMore]) {
        NSString *display=moreCell.textLabel.text;
        if ([display compare:@"没有更多消息了"]==0) {
            return;
        }
        
        moreCell.textLabel.text=@"正在加载...";
        [self loadedMoreDatas];
    }
}

-(void)loadedMoreDatas
{
    [self removeLoadingFaile];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    BOOL isConnected = [WebRequest isConnectionAvailable];
    if (!isConnected) {
        [self warnMessage:@"网络连接失败"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        return;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isSuccess;
        __block NSString *errMsg;
        __block HouseVo *moreHouseVo;
        
        _page++;
        [WebRequest getListNearby:_locationDictionary filterparams:_paramsDictionary page:_page complete:^(HouseVo *vo, NSError *error) {
            if (error!=nil) {
                _page--;
                isSuccess=NO;
                errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
            }else{
                isSuccess=YES;
                moreHouseVo=vo;
            }
        }];
        if (moreHouseVo!=nil && moreHouseVo.result.datas.count>0) {
            [_houseVo.result.datas  addObjectsFromArray:moreHouseVo.result.datas];
        }else{
            _page--;
        }
        
        
        NSMutableArray *moreIndexpath = [NSMutableArray arrayWithCapacity:moreHouseVo.result.datas.count];
        for (int i=0; i<moreHouseVo.result.datas.count; i++) {
            NSIndexPath *path =[NSIndexPath indexPathForRow:[_houseVo.result.datas indexOfObject:[moreHouseVo.result.datas objectAtIndex:i]] inSection:0];
            [moreIndexpath addObject:path];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            if (moreIndexpath.count>0) {
                //插入数据
                [self.tableView insertRowsAtIndexPaths:moreIndexpath withRowAnimation:UITableViewRowAnimationFade];
            }
            
            if(moreIndexpath.count <10){
                [self moreCellNo];
            }else{
                [self moreCellDefault];
            }
            
        });
        
    });
    
    
}

#pragma mark 更多单元格的显示
-(void)moreCellDefault{
    moreCell.textLabel.text=@"更多";
}

-(void)moreCellNo{
    moreCell.textLabel.text=@"没有更多消息了";
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
