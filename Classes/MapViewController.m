//
//  MapViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-5-9.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "MapViewController.h"
#import "MobClick.h"
#import "CLLocationConvert.h"

@interface MapViewController ()
{
    double starLat;
    double starLng;
    // UIActivityIndicatorView *activityIndicatorView;
}
@end

@implementation MapViewController

@synthesize mapView;

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
    

    [self setTitle:@"地址"];
    [self setNavLeftButton];
    [self setNavRightButton];
    
    [self initMapView];
    
    
    //[self.mapView setShowsUserLocation:YES];
    
}

#pragma mark 设置导航颜色
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
    button.frame = CGRectMake(0, 0, back.size.width, back.size.height);
    [button setBackgroundImage:back forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=item;
    
}

-(void)setNavRightButton
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    UIFont *font=[UIFont systemFontOfSize:17.0];
    CGSize size =MB_TEXTSIZE(@"导航", font);
    [button setFrame:CGRectMake(0,0,size.width,size.height)];
    //[button setBackgroundColor:[UIColor blackColor]];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button setTitle:@"导航" forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    //button.titleLabel.textAlignment=NSTextAlignmentRight;
    [button addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.rightBarButtonItem=item;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
-(void)initMapView
{
   
    self.mapView.delegate=self;
    self.mapView.mapType=MKMapTypeStandard;
    //self.mapView.showsUserLocation=YES;
    //[self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];//用户跟踪模式
    
    //百度坐标转换为火星坐标
    transform_baidu_from_mars(self.lat.doubleValue, self.lng.doubleValue, &starLat, &starLng);
    CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(starLat , starLng);
    MKCoordinateRegion viewRegion=MKCoordinateRegionMakeWithDistance(coordinate, 200, 200);
    MKCoordinateRegion adjustRegion=[self.mapView regionThatFits:viewRegion];
    [self.mapView setRegion:adjustRegion animated:YES];
    
    
    MKPointAnnotation *annotation=[[MKPointAnnotation alloc]init];
    annotation.coordinate=CLLocationCoordinate2DMake(starLat,starLng);
    annotation.title=self.address;
    annotation.subtitle=[NSString stringWithFormat:@"%@：%@",self.contacter,self.tel];
    
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:YES];//如果不选择，则不会弹出显示
    
}

#pragma mark
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //方法一：using default pin as a PlaceMarker to display on map
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
    newAnnotation.pinColor = MKPinAnnotationColorRed;
    newAnnotation.animatesDrop = YES;
    //canShowCallout: to display the callout view by touch the pin
    newAnnotation.canShowCallout=YES;
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [button addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    newAnnotation.rightCalloutAccessoryView=button;
    
    return newAnnotation;
    
    //return nil;
}

#pragma mark 打开内置的MAP
-(void)checkButtonTapped:(id)sender
{
    //记录事件
    [MobClick event:@"MapNavigationEvent"];
    
    //http://stackoverflow.com/questions/576768/how-to-invoke-iphone-maps-for-directions-with-current-location-as-start-address/964131#964131
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=starLat;
    coordinate.longitude=starLng;
    MKPlacemark *place=[[MKPlacemark alloc]initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *destination=[[MKMapItem alloc]initWithPlacemark:place];
    destination.name=self.address;
    NSArray *items=[NSArray arrayWithObjects:destination, nil];
    NSDictionary *options=[[NSDictionary alloc]initWithObjectsAndKeys:MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsDirectionsModeKey , nil];
    [MKMapItem openMapsWithItems:items launchOptions:options];
}

#pragma mark MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //self.mapView.centerCoordinate=userLocation.location.coordinate;
}

- (void)didReceiveMemoryWarning

{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect=CGRectMake(0, 0, 1.0, 1.0);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"地图页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"地图页面"];
}

@end
