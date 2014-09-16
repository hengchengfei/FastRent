//
//  AllCityViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-8-6.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "AllCityViewController.h"
#import "SearchTableViewController.h"
#import "WebRequest.h"
#import "CityViewController.h"
#import "DXAlertView/DXAlertView.h"
#import "MBProgressHUD.h"
#import "JsonObject/RentComboxs.h"
#import "JsonObject/RentCombox.h"
#import "JsonObject/Rents.h"
#import "JsonObject/Rent.h"
#import "NearbyViewCell.h"
#import "DetailViewController.h"
#import "WYPopoverController.h"

////////////
#import "ComboxVo.h"
#import "FRComboxView.h"
#import "FRComboxItem.h"

@interface AllCityViewController ()
{
    NSString *city;
    BOOL _isSelectCity;
    SearchTableViewController *_searchController;
    NSMutableArray *_searchDatasource;
    UIImageView *_loadingImageView;
    
    UITableViewCell *moreCell;
    MBProgressHUD *hud;
    SelectionViewController *selectionViewController;
    WYPopoverController *popoverController;
    BOOL isAddedCombox;
    RentComboxs *_comboxDatasource;
    NSNumber *_typeId;
    NSNumber *_priceId;
    NSNumber *_sourceId;
    
    //Rents *datasource;
    
    //////////
    FilterSearchViewController* fcontroller;
    ComboxVo *_comboxVo;
    NSMutableDictionary *_locationDictionary;
    NSMutableDictionary *_paramsDictionary;
    NSInteger _page;
    HouseVo *_houseVo;
}
@end

@implementation AllCityViewController

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
    
    [self noActive];
    self.textField.delegate=self;
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.btnCancel addTarget:self action:@selector(noActive) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    _searchController=[[SearchTableViewController alloc]init];
    _searchController.delegate=self;
    self.searchTable.delegate=_searchController;
    self.searchTable.dataSource=_searchController;
    self.searchTable.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    //默认城市
    city=[self getSearchCity];
    if (city) {
        [self setCity:city];
        _isSelectCity=YES;
    }else{
        _isSelectCity=NO;
        [self setCity:@"选择"];
    }
    
    //更多
    moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
    moreCell.textLabel.textColor=appColor;
    moreCell.textLabel.font=[UIFont fontWithName:moreCell.textLabel.font.fontName size:12];
    if (ISOS7) {
        moreCell.separatorInset=UIEdgeInsetsMake(0, 7, 0, 0);
    }
    
    [self moreCellDefault];
    
    _locationDictionary =[[NSMutableDictionary alloc]init];
    _paramsDictionary=[[NSMutableDictionary alloc]init];
    _page=1;
}

#pragma mark 更多单元格的显示
-(void)moreCellDefault{
    moreCell.textLabel.text=@"更多";
}

-(void)moreCellNo{
    moreCell.textLabel.text=@"没有更多消息了";
}

#pragma mark Loading Animation
-(void)addLoadingAnimation{
    for (UIView *view in self.view.subviews) {
        if (view.tag==100) {
            [view removeFromSuperview];
            break;
        }
    }
    _loadingImageView=[[UIImageView  alloc]initWithFrame:self.view.frame];
    _loadingImageView.frame=CGRectMake(0, 0, 200, 225);
    _loadingImageView.center =CGPointMake(self.view.center.x, self.view.center.y);
    _loadingImageView.animationImages=[NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"LoadingImage_01.png"],
                                       [UIImage imageNamed:@"LoadingImage_02.png"],
                                       nil];
    _loadingImageView.animationDuration=0.5;
    _loadingImageView.animationRepeatCount=0;
    _loadingImageView.tag=100;
    
    [_loadingImageView startAnimating];
    [self.view addSubview:_loadingImageView];
    
}
-(void)deleteLoadingAnimation{
    [_loadingImageView removeFromSuperview];
}

#pragma 取得默认城市
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

#pragma mark Search Active
-(void)inActive{
    fcontroller.view.hidden=YES;
    isAddedCombox=NO;
    self.cityButton.hidden=YES;
    self.btnCancel.hidden=NO;
    self.searchTable.hidden=NO;
    self.tableView.hidden=YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect= [[UIScreen mainScreen] bounds];
        self.textField.frame=CGRectMake(10, self.textField.frame.origin.y, rect.size.width-80, self.textField.frame.size.height);
        self.btnCancel.frame=CGRectMake(self.textField.frame.origin.x+self.textField.frame.size.width+10, self.btnCancel.frame.origin.y, self.btnCancel.frame.size.width, self.btnCancel.frame.size.height);
    }];
}
-(void)noActive{
    fcontroller.view.hidden=NO;
    self.cityButton.hidden=NO;
    self.btnCancel.hidden=YES;
    self.searchTable.hidden=YES;
    self.tableView.hidden=NO;
    self.textField.frame=CGRectMake(82, 26, 227, 30);
    [self.textField resignFirstResponder];
}

-(void)setCity:(NSString *)title
{
    //    CGRect btnFrame=CGRectMake(6, 32, 60, 20);
    //    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    //    button.frame=btnFrame;
    //    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    //    button.backgroundColor=[UIColor clearColor];
    for (UIView *view in self.cityButton.subviews) {
        [view removeFromSuperview];
    }
    
    if (title) {
        title =[title stringByReplacingOccurrencesOfString:@"市" withString:@""];
    }
    [self.cityButton setTitle:@"" forState:UIControlStateNormal];
    [self.cityButton addTarget:self action:@selector(presentCityController:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加文本
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(5, 5,44, 20)];
    label.font=[UIFont systemFontOfSize:14.0];;
    label.text=title;
    label.textColor=[UIColor whiteColor];
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    
    //添加图片
    UIImage *image =[UIImage imageNamed:@"GLOBALArrowDown.png"];
    UIImageView *imageview = [[UIImageView alloc]initWithImage:image];
    
    imageview.backgroundColor=[UIColor clearColor];
    
    CGRect frame1=CGRectMake(55, 8, 15 , 15);
    imageview.frame=frame1;
    
    [self.cityButton insertSubview:label atIndex:0];
    [self.cityButton insertSubview:imageview   atIndex:1];
    
    // [self.searchTable addSubview:button];
}

-(void)presentCityController:(id)sender
{
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CityViewController *_controller =[storyboard instantiateViewControllerWithIdentifier:@"CityViewController"];
    _controller.callback=^(NSString *_city){
        [self setDefaultSearchCity:_city];
        city=_city;
        _isSelectCity=YES;
        [self setCity:_city];
    };
    
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:_controller];
    [nav.navigationBar setBarTintColor:appColor];
    [self presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark 设置默认城市
-(void)setDefaultSearchCity:(NSString *)cityText
{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:cityText forKey:kLastSearch_City];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark TextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self inActive];
    
    NSString *text=textField.text;
    if (text!=nil && text.length>0) {
        [self textFieldDidChange:textField];
    }else{
        textField.enablesReturnKeyAutomatically=YES;
    }
    
    return YES;
}



-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}

#pragma 文本变化时调用
-(void)textFieldDidChange:(id)sender
{
    //UITextField *txtField=[notification object];
    UITextField *txtField=(UITextField *)sender;
    NSString *text=txtField.text;
    
    if (text.length<=0) {
        self.searchTable.hidden=YES;
        return;
    }
    
    if (!_isSelectCity) {
        self.searchTable.hidden=YES;
        return;
    }
    
    //nghai
    UITextRange *range=txtField.markedTextRange;
    if (range==nil || range.empty) {
        
    }else{
        self.searchTable.hidden=YES;
        return;
    }
    
    [self addLoadingAnimation];
    
    _searchDatasource =[[NSMutableArray alloc]init];
    
    __block BOOL success;
    __block NSDictionary *dictResult;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        [WebRequest findByKey:city key:text onCompletion:^(NSDictionary *dict, NSError *err) {
            if (err!=nil || dict==nil || dict.count<=0) {
                success =NO;
            }else{
                dictResult=dict;
                success=YES;
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deleteLoadingAnimation];
            if (success==NO) {
                self.searchTable.hidden=YES;
                return;
            }
            NSArray *result=[dictResult objectForKey:@"datas"];
            for (int i=0; i<result.count; i++) {
                SearchSuggestion *bs=[SearchSuggestion new];
                NSDictionary *d1=[result objectAtIndex:i];
                
                bs.key=[d1 objectForKey:@"key"];
                bs.count=[d1 objectForKey:@"count"];
                
                [_searchDatasource addObject:bs];
            }
            
            _searchController.datasource=_searchDatasource;
            [self.searchTable reloadData];
            self.searchTable.hidden=NO;
        });
    });
    
    
    
    
}

//此方法在文本改变前就调用了,而不是在改变后调用
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.textField.text.length>0) {
        [self.textField resignFirstResponder];
    }
    
    [self noActive];
    [self reloadData];
    return YES;
}


#pragma mark SearchTableDelegate
-(void)didSelectedSearch:(NSString *)searchText
{
    [self moreCellDefault];
    self.textField.text=searchText;
    [self noActive];
    [self reloadData];
}


-(void)reloadData{
    
    _page=1;
    [self addLoadingAnimation];
    
    NSString *text= self.textField.text;
    if (text.length<=0) {
        [self deleteLoadingAnimation];
        return;
    }
    
    NSString *tmpcity=[self getSearchCity];
    if (tmpcity==nil) {
        [self deleteLoadingAnimation];
        DXAlertView *alert=[[DXAlertView alloc]initWithTitle:@"提示" contentText:@"请先选择城市" leftButtonTitle:nil rightButtonTitle:@"确定"];
        [alert show];
        
        return;
    }
    
    [_locationDictionary setObject:tmpcity forKey:@"city"];
    [_paramsDictionary setObject:text forKey:@"key"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isSuccess;
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
            isSuccess=YES;
        }
        if (isSuccess) {
            [WebRequest getListSearch:_locationDictionary filterparams:_paramsDictionary page:_page complete:^(HouseVo *vo, NSError *error) {
                if (error!=nil) {
                    isSuccess=NO;
                }else{
                    isSuccess=YES;
                    _houseVo=vo;
                }
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [self deleteLoadingAnimation];
            if (!isSuccess) {
                MBProgressHUD *hudMsg=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hudMsg.mode=MBProgressHUDModeText;
                hudMsg.labelText=@"网络连接失败";
                [hudMsg hide:YES afterDelay:2.0];
            }else{
                if (_houseVo.result.datas.count<=0) {
                    MBProgressHUD *hudMsg=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    hudMsg.mode=MBProgressHUDModeText;
                    hudMsg.labelText=@"没有数据";
                    [hudMsg hide:YES afterDelay:2.0];
                    [self.tableView reloadData];
                }else{
                    [self addCombox];
                    [self.tableView reloadData];
                }
            }

        });
    });
}

#pragma 取得下拉框的参数
-(void)getFilterParams:(NSMutableDictionary *)params
{
    _paramsDictionary=params;
    [self reloadData];
}

#pragma mark Table操作
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_houseVo.result.datas.count>0) {
        return _houseVo.result.datas.count+1;
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
    Rent *rent = [_houseVo.result.datas objectAtIndex:row];
    
    NearbyViewCell *rentCell=[tableView dequeueReusableCellWithIdentifier:RentCellIdentifier];
    if (rentCell==nil) {
        rentCell =(NearbyViewCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RentCellIdentifier];
    }
    
    
    if ([rent houseImg]!=nil) {
        NSURL *url =[NSURL URLWithString:[rent houseImg]];
        [rentCell.img setImageWithURL:url placeholderImage:[UIImage imageNamed:kPNG_Loading_100]];
    }
    
    rentCell.title.text=rent.publishTitle;
    rentCell.price.text=[NSString stringWithFormat:@"%@元/月",rent.rentMoney];
    rentCell.rentType.text=[rent rentType];
    rentCell.houseType.text=[rent houseType];
    rentCell.agencyType.text=[rent agencyType];
    rentCell.updateTime.text=rent.updateTime;
    rentCell.backgroundColor = [UIColor clearColor];
    rentCell.id.text = [[rent id]stringValue];
    if(rent.houseType==nil){
        rentCell.houseType.text=@"房型未知";
    }
    if (rent.houseArea==nil) {
        rentCell.houseArea.text=@"面积未知";
    }else{
        NSString *area=[NSString stringWithFormat:@"%d",rent.houseArea.intValue];
        rentCell.houseArea.text=[NSString stringWithFormat:@"%@%@",area,rent.houseAreaUnit];
    }
    
    return rentCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == _houseVo.result.datas.count) {
        return 40.0f;
    }
    
    return 74.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (cell==moreCell) {
        NSLog(@"%@",moreCell.textLabel.text);
    }
    if (cell ==moreCell && [self isAutoLoadMore]) {
        moreCell.textLabel.text=@"正在加载...";
        [self loadedMoreDatas];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == _houseVo.result.datas.count) {
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

#pragma mark 加载更多
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
    
    _page++;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL isSuccess;
        __block HouseVo *moreRents;
        
        [WebRequest getListSearch:_locationDictionary filterparams:_paramsDictionary page:_page complete:^(HouseVo *vo, NSError *error) {
                if (error!=nil) {
                    isSuccess=NO;
                    _page--;
                }else{
                    isSuccess=YES;
                    moreRents=vo;
                }
            }];
            
            if (moreRents.result.datas.count>0) {
                [_houseVo.result.datas addObjectsFromArray:moreRents.result.datas];
            }else{
                _page--;
            }
            
            
            NSMutableArray *moreIndexpath= [NSMutableArray arrayWithCapacity:moreRents.result.datas.count];
            for (int i=0; i<moreRents.result.datas.count; i++) {
                NSIndexPath *path =[NSIndexPath indexPathForRow:[_houseVo.result.datas indexOfObject:[moreRents.result.datas objectAtIndex:i]] inSection:0];
                [moreIndexpath addObject:path];
            }
       
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
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

#pragma mark 是否自动加载更多
-(BOOL)isAutoLoadMore{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL isAutoload = [defaults boolForKey:kIsAutoLoadMore];
    if (isAutoload) {
        return YES;
    }
    return NO;
}


#pragma mark 添加下拉列表框
-(void)addCombox{
    if (fcontroller) {
        return;
    }
    fcontroller =[[FilterSearchViewController alloc]init];
    fcontroller.comboxDatasource=_comboxVo;
    fcontroller.delegate=self;
    [self.view insertSubview:fcontroller.view aboveSubview:self.tableView];
}


#pragma  mark UITableViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textField resignFirstResponder];
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

@end
