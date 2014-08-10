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
    
    Rents *datasource;
    
    
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
    moreCell.textLabel.textColor=selectedItemTitleColor;
    moreCell.textLabel.font=[UIFont fontWithName:moreCell.textLabel.font.fontName size:12];
    if (ISOS7) {
            moreCell.separatorInset=UIEdgeInsetsMake(0, 7, 0, 0);
    }

    [self moreCellDefault];
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
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PullDownButton class]]) {
            view.hidden=YES;
        }
    }
    
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
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[PullDownButton class]]) {
            view.hidden=NO;
        }
    }
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
    [nav.navigationBar setBarTintColor:selectedItemTitleColor];
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
    
    //    BOOL isConnected = [WebRequest isConnectionAvailable];
    //    if (!isConnected) {
    //        MBProgressHUD *hd =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //        hd.mode=MBProgressHUDModeText;
    //        hd.labelText=@"网络连接失败";
    //        [hd show:YES];
    //
    //        [hd hide:YES afterDelay:2.0];
    //        return;
    //    }
    
    // __block Rents *_allSearchRents;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WebRequest findSearchString:city searchString:text id:nil typeId:_typeId priceId:_priceId sourceId:_sourceId  onCompletion:^(Rents *allRents, NSError *error) {
            if (error==nil) {
                datasource = allRents;
            }
        } ];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [self deleteLoadingAnimation];
            if (datasource.rents.count<=0) {
                MBProgressHUD *hudMsg=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hudMsg.mode=MBProgressHUDModeText;
                hudMsg.labelText=@"没有数据";
                [hudMsg hide:YES afterDelay:2.0];
                [self.tableView reloadData];
            }else{
                [self addComboxBox];
                //UIStoryboard *storyboard =[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                //_searchResultController = [storyboard instantiateViewControllerWithIdentifier:@"SearchResultController"];
                //_searchResultController.city=city;
                //_searchResultController.searchText=text;
                //_searchResultController.datasource=_allSearchRents;
                
                [self.tableView reloadData];
            }
        });
    });
}
#pragma mark Table操作
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (datasource!=nil && datasource.rents.count>0) {
        return datasource.rents.count+1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row ==datasource.rents.count) {
        return moreCell;
    }
    
    static NSString *RentCellIdentifier =@"NearbyCell";
    Rent *rent = [datasource.rents objectAtIndex:row];
    
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
    if ([indexPath row] == datasource.rents.count) {
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
    if ([indexPath row] == datasource.rents.count) {
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Rent *rent=  [datasource.rents lastObject];
        
        __block BOOL isSuccess;
        __block Rents *moreRents;
        
        [WebRequest findSearchString:city searchString:self.textField.text id:rent.id typeId:_typeId priceId:_priceId sourceId:_sourceId   onCompletion:^(Rents *newRents, NSError *error) {
            if (error==nil) {
                isSuccess=YES;
                moreRents=newRents;
            }else{
                isSuccess=NO;
            }
        } ];
        
        if (moreRents!=nil && moreRents.rents.count>0) {
            [datasource.rents addObjectsFromArray:moreRents.rents];
        }
        
        
        NSMutableArray *moreIndexpath = [NSMutableArray arrayWithCapacity:moreRents.rents.count];
        for (int i=0; i<moreRents.rents.count; i++) {
            NSIndexPath *path =[NSIndexPath indexPathForRow:[datasource.rents indexOfObject:[moreRents.rents objectAtIndex:i]] inSection:0];
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

#pragma mark Combox Action
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
    
    [WebRequest findComboxs:^(RentComboxs *bo, NSError *error) {
        if (error!=nil) {
            
        }else{
            _comboxDatasource=bo;
        }
    }];
    
    for (int i=0; i<_comboxDatasource.rentComboxs.count; i++) {
        RentCombox *combox =(RentCombox *)[_comboxDatasource.rentComboxs objectAtIndex:i];
        NSNumber *datatype=[combox type];
        switch (datatype.intValue) {
            case 0:
                break;
            case 1:
            {
                [priceTitleDatasource addObject:combox.name];
                [priceIdDatasource addObject:combox.id];
                break;
            }
            case 2:
            {
                [distanceTitleDatasource addObject:combox.name];
                [distanceIdDatasource addObject:combox.id];
                break;
            }
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
    CGFloat y=-self.navView.frame.origin.y+self.navView.frame.size.height;
    CGFloat width=screenSize.width/3.0;
    CGFloat height=40.0;
    
    CGRect distanceFrame=CGRectMake(x, y, width, height);
    CGRect priceFrame=CGRectMake(x+width, y, width, height);
    CGRect sourceFrame=CGRectMake(x+(width*2), y, width, height);
    
    
    [self addPullButton:@"租房类型" font:font frame:distanceFrame  titleDatasource:distanceTitleDatasource idDatasource:distanceIdDatasource];
    //btnDistance.tag=0;
    
    [self addPullButton:@"价格" font:font frame:priceFrame titleDatasource:priceTitleDatasource idDatasource:priceIdDatasource];
    
    [self addPullButton:@"来源" font:font frame:sourceFrame titleDatasource:sourceTitleDatasource idDatasource:sourceIdDatasource];
    
    isAddedCombox=YES;
}

-(void)addPullButton:(NSString *)text font:(UIFont *)font frame:(CGRect)frame titleDatasource:(NSArray *)titleDatasource idDatasource:(NSArray *)idDatasource
{
    //addTarget除了传递self之外，不能传递参数，所以最好自定义一个button
    PullDownButton *button=[[PullDownButton alloc]initWithFrame:frame labelText:text font:font];
    button.titleArray=titleDatasource;
    button.idArray=idDatasource;
    
    [self moreCellDefault];
    [button addTarget:self action:@selector(loadPullDownDatas:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}

-(void)loadPullDownDatas:(PullDownButton *)sender
{
    
    WYPopoverBackgroundView *bkView =[WYPopoverBackgroundView appearance];
    bkView.outerCornerRadius=0.0;
    //bkView.outerStrokeColor=[UIColor orangeColor];
    //bkView.glossShadowColor=[UIColor orangeColor];
    selectionViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"SelectionController"];
    selectionViewController.popDelegate=self;
    selectionViewController.fromPullDownButton=sender;
    selectionViewController.titleDatasource=sender.titleArray;
    selectionViewController.idDatasource=sender.idArray;
    popoverController =[[WYPopoverController alloc]initWithContentViewController:selectionViewController];
    [popoverController presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
}

-(void)popoverHandler:(SelectionViewController *)controller text:(NSString *)text id:(NSNumber *)id
{
    [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionScale];
    
    for(int i=0;i<_comboxDatasource.rentComboxs.count;i++){
        RentCombox *combox=(RentCombox *)[_comboxDatasource.rentComboxs objectAtIndex:i];
        NSInteger type=[[combox type]integerValue];
        NSInteger _id=[[combox id]integerValue];
        if([id integerValue] == _id){
            if(type==1){
                _priceId=id;
            }else if(type==2){
                _typeId=id;
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
