//
//  CityViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-5-26.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "CityViewController.h"
#import "DXAlertView.h"
#import "WebRequest.h"
#import "CityLocationViewCell.h"
#import "WYPopoverController.h"
#import "MobClick.h"

@interface CityViewController ()
{
    UISearchBar *_searchBar;
    UISearchDisplayController *_searchDisplayController;
    
    NSArray *_hotCitys;
    NSArray *_allLetters;
    NSMutableArray *_allGroupedCitys;
    
    NSMutableArray *_searchCitys;
    
    UIActivityIndicatorView *_loadingIndicator;
    CLLocationManager *_locationManager;
    
    BOOL isSuccessLocation;//是否定位成功
    
    WYPopoverController *popController;
    SelectionViewController *selectionController;
    
}
@end

@implementation CityViewController

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
    [self setTitle:@"切换城市"];
    [self setNavLeftButton];
    isSuccessLocation=NO;
    
    [self initData];
    
    [self openMapLocation];
    //
    if (ISOS7) {
        self.tableView.sectionIndexBackgroundColor=[UIColor clearColor];
    }
    
    self.tableView.sectionIndexColor=[UIColor grayColor];
    
    
    _searchBar=[[UISearchBar alloc]init];
    _searchBar.frame=CGRectMake(0, 0, self.tableView.bounds.size.width, 0);
    _searchBar.delegate=self;
    _searchBar.keyboardType=UIKeyboardTypeDefault;
    _searchBar.showsCancelButton=YES;
    //searchBar.showsBookmarkButton=YES;
    _searchBar.placeholder=@"请输入城市名称";
    _searchBar.translucent=YES;
    _searchBar.barStyle=UIBarStyleDefault;
    //_searchBar.layer.sublayerTransform=CATransform3DMakeTranslation(-5, 0, 0);
    
    //searchBar.prompt=@"搜索";
    [_searchBar sizeToFit];
    self.tableView.tableHeaderView=_searchBar;
    


//   _searchDisplayController =[[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
//    _searchDisplayController.searchResultsDelegate=self;
//    _searchDisplayController.searchResultsDataSource=selectionController;
//    _searchDisplayController.delegate=self;
}

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

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initData{
    
    NSString *citypath=[[NSBundle mainBundle]pathForResource:@"city" ofType:@"plist"];
    
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:citypath];
    
    _hotCitys=[dict mutableArrayValueForKey:@"热门城市"];
    
    
    NSArray *keys=[dict allKeys];
    NSMutableArray *letters=[[NSMutableArray alloc]init];
    for (NSString *key in keys) {
        if (![key compare:@"热门城市"]==0) {
            [letters addObject:key];
        }
    }

    _allLetters=[letters sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return  [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    
    _allGroupedCitys=[[NSMutableArray alloc]init];
    for (int i=0; i<_allLetters.count; i++) {
        NSString *key=[_allLetters objectAtIndex:i];
        NSArray *value=[dict objectForKey:key];
        
        
        [_allGroupedCitys addObject:value];
    }
}

#pragma mark 检测网络连接
-(BOOL)checkInternet
{
    BOOL isConnectionNetwork =[WebRequest isConnectionAvailable];
    if (!isConnectionNetwork) {
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
        _locationManager=[CLLocationManager new];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=1000.0f;//当位置超过多少米时更新
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark -
#pragma mark 定位操作
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self showLoadingControl];
    
    CLLocation  *_currentLocation=[locations lastObject];
    CLLocationCoordinate2D coor = _currentLocation.coordinate;//手机GPS
    
    double _latitude = coor.latitude;
    double _longitude =coor.longitude;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        __block BOOL isSuccess=NO;
        __block NSString *errMsg;
        __block Address *_address;
        
        [WebRequest findAddress:_latitude longitude:_longitude onCompletion:^(Address * address, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
                errMsg=[error.userInfo objectForKey:NSLocalizedDescriptionKey];
            }else{
                isSuccess=YES;
                _address=address;
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[_locationManager stopUpdatingLocation];
            
            NSIndexPath *path =[NSIndexPath indexPathForRow:0 inSection:0];
            CityLocationViewCell *cell= (CityLocationViewCell *) [self.tableView cellForRowAtIndexPath:path];
            if (!isSuccess) {
                isSuccessLocation=NO;
                cell.citylabel.text=@"定位失败，请点击重试";
            }else{
                isSuccessLocation=YES;
                if (_address.city==nil) {
                    isSuccessLocation=NO;
                    cell.citylabel.text=@"不在中国，请点击重试";
                }else{
                                    cell.citylabel.text=_address.city;
                }

                
            }
            
            [self hiddenLoadingControl];
        });
        
    });
    
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    isSuccessLocation=NO;
    NSIndexPath *path =[NSIndexPath indexPathForRow:0 inSection:0];
    CityLocationViewCell *cell= (CityLocationViewCell *) [self.tableView cellForRowAtIndexPath:path];
    cell.citylabel.text=@"定位失败，请点击重试";
    
    [self hiddenLoadingControl];
}


#pragma mark 加载控件
-(void)showLoadingControl
{
    [_loadingIndicator removeFromSuperview];
    
    NSIndexPath *path =[NSIndexPath indexPathForRow:0 inSection:0];
    CityLocationViewCell *cell= (CityLocationViewCell *) [self.tableView cellForRowAtIndexPath:path];
    
    //cell.btnRefresh.hidden=YES;
    
    CGPoint point= cell.btnRefresh.frame.origin;
    
    _loadingIndicator =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_loadingIndicator setFrame:CGRectMake(point.x-40, point.y, 25.0, 25.0)];
    [_loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    [cell addSubview:_loadingIndicator];
}
-(void)hiddenLoadingControl
{
    if (_loadingIndicator) {
        [_loadingIndicator removeFromSuperview];
    }
    NSIndexPath *path =[NSIndexPath indexPathForRow:0 inSection:0];
    CityLocationViewCell *cell= (CityLocationViewCell *) [self.tableView cellForRowAtIndexPath:path];
    
    cell.btnRefresh.hidden=NO;
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search bar delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (0==searchText.length) {
        return;
    }
        _searchCitys=[[NSMutableArray alloc]init];
    
    for (int i=0; i<_allGroupedCitys.count; i++) {
        NSArray *citys=(NSArray *)[_allGroupedCitys objectAtIndex:i];
        
        
        for (int j=0; j<citys.count;j++) {
            NSString *city=(NSString *)[citys objectAtIndex:j];
            NSRange range=[city rangeOfString:searchText];
            
            if (range.location==NSNotFound) {
                continue;
            }else{
                [_searchCitys addObject:city];
            }
        }
    }
 
    if (_searchCitys.count>0) {
        selectionController=[self.storyboard instantiateViewControllerWithIdentifier:@"SelectionController"];
        selectionController.titleDatasource=_searchCitys;
        selectionController.popDelegate=self;
        
        popController=[[WYPopoverController alloc]initWithContentViewController:selectionController];
        
           [popController presentPopoverFromRect:searchBar.bounds inView:searchBar permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        //  [self.tableView reloadData];

    }else{
        if (popController) {
            [popController dismissPopoverAnimated:YES];
        }
    }
}
-(void)popoverHandler:(SelectionViewController *)controller text:(NSString *)text id:(NSNumber *)id
{
    if(popController){
        [popController dismissPopoverAnimated:YES];
    }
    if(self.callback){
        self.callback(text);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _allLetters.count+2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section==0) {
        return 1;
    }else if(section==1){
        return _hotCitys.count;
    }else{
        NSInteger index=section-2;
         return [[_allGroupedCitys objectAtIndex:index] count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"cell";
    NSInteger section =  indexPath.section;
    NSInteger row = indexPath.row;
    if ([tableView isEqual:_searchDisplayController.searchResultsTableView]) {
      NSString *city=  [_searchCitys objectAtIndex:row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.textLabel.text=city;
        
        return cell;
    }
    
    if (section==0) {
        CityLocationViewCell *cell=(CityLocationViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LocationCityCell"];
        cell.refreshBlock=^{
            [_locationManager startUpdatingLocation];
        };
        
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
        return cell;
    }else if(section==1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSString *city=[_hotCitys objectAtIndex:row];
        cell.textLabel.text=city;
        
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
        
        
        return cell;
    }
    
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSInteger index=section-2;
        NSMutableArray *citys=[_allGroupedCitys objectAtIndex:index];
        NSString *city=[citys objectAtIndex:row];
        cell.textLabel.text=city;
        
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
        
        
        return cell;
    }
    
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:_searchDisplayController.searchResultsTableView]) {
        return nil;
    }
    if (section==0) {
        return @"定位城市";
    }else if(section==1){
        return @"热门城市";
    }
    NSInteger index=section-2;
    return [_allLetters objectAtIndex:index];
}
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _allLetters;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 21.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *city;
    if (indexPath.section==0) {
        CityLocationViewCell *cell=(CityLocationViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        city=cell.citylabel.text;
         [_locationManager startUpdatingLocation];
        if (!isSuccessLocation) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
    }else{
        UITableViewCell *cell= [tableView cellForRowAtIndexPath:indexPath];
        city=cell.textLabel.text;
    }
    
    if (self.callback) {
        self.callback(city);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"切换城市页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"切换城市页面"];
}

@end
