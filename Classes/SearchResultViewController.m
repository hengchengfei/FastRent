//
//  SearchResultViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-6-5.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "SearchResultViewController.h"
#import "NearbyViewCell.h"
#import "DetailViewController.h"
#import "UIImageView+WebCache.h"
#import "WebRequest.h"
#import "MBProgressHUD.h"
#import "RentComboxs.h"
#import "RentCombox.h"
#import "PullDownButton.h"
#import "MobClick.h"

@interface SearchResultViewController ()
{
    UITableViewCell *moreCell;
    
    MBProgressHUD *hud;
    
    SelectionViewController *selectionViewController;
    WYPopoverController *popoverController;
    
    BOOL isAddedCombox;
    RentComboxs *_comboxDatasource;
    
    NSNumber *_typeId;
    NSNumber *_priceId;
    NSNumber *_sourceId;
}
@end

@implementation SearchResultViewController

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
    
    //导航栏设置
    [self setTitle:self.searchText];
    [self setNavLeftButton];
    
    //View样式设置
    [self initStyle];
    
    [self addComboxBox];
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
    //   self.tableView.hidden=YES;
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    if(ISOS7){
        self.tableView.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);//分割线的位置
    }
    
    
    //更多
    moreCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    moreCell.textLabel.textAlignment = NSTextAlignmentCenter;
    moreCell.textLabel.text=@"更多";
    moreCell.textLabel.textColor=[UIColor grayColor];
    moreCell.textLabel.font=[UIFont fontWithName:moreCell.textLabel.font.fontName size:12];
}

#pragma mark -
#pragma mark 设置导航栏上的标题和左侧按钮样式
-(void)setTitle:(NSString *)title
{     UIFont *font = [UIFont systemFontOfSize:16];
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    CGFloat y=-1.0;
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
    
    [self reloadData:nil];
}

-(void)reloadData:(NSNumber *)id
{
    BOOL isConnected =[WebRequest isConnectionAvailable];
    
    if (!isConnected) {
        MBProgressHUD *hd =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hd.mode=MBProgressHUDModeText;
        hd.labelText=@"网络连接失败";
        [hd show:YES];
        
        [hd hide:YES afterDelay:2.0];
        return;
    }
    
    hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"加载中";
    hud.dimBackground=YES;
    [hud show:YES];
    
    __block BOOL isSuccess;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0) ,^{
        // [NSThread sleepForTimeInterval:2.0f];
        [WebRequest findSearchString:self.city searchString:self.searchText id:id  typeId:_typeId priceId:_priceId sourceId:_sourceId onCompletion:^(Rents *rents, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
            }else{
                isSuccess=YES;
                self.datasource=rents;
            }
        }] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!isSuccess) {
                hud.labelText=@"加载失败";
                [hud hide:YES afterDelay:2.0];
                return;
            }
            
            [hud hide:YES];
            [self.tableView reloadData];
            
            //定位到第一行
            if (self.datasource!=nil && self.datasource.rents.count>0) {
                NSIndexPath *firstpath=[NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView scrollToRowAtIndexPath:firstpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        });
    });
}

#pragma mark -
#pragma mark Table操作
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datasource!=nil && self.datasource.rents.count>0) {
        return self.datasource.rents.count+1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (row ==self.datasource.rents.count) {
        return moreCell;
    }
    static NSString *RentCellIdentifier =@"NearbyCell";
    
    Rent *rent = [self.datasource.rents objectAtIndex:row];
    
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
    if (rent.houseArea==nil) {
        rentCell.houseArea.text=@"面积未知";
    }else{
        NSString *area=[NSString stringWithFormat:@"%d",rent.houseArea.intValue];
        rentCell.houseArea.text=[NSString stringWithFormat:@"%@%@",area,rent.houseAreaUnit];
    }
    
    return rentCell;
    
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath row] == self.datasource.rents.count) {
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (cell ==moreCell && [self isAutoLoadMore]) {
        moreCell.textLabel.text=@"正在加载...";
        [self loadedMoreDatas];
    }
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == self.datasource.rents.count) {
        return 40.0f;
    }
    
    return 74.0f;
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
        Rent *rent=  [self.datasource.rents lastObject];
        
        __block BOOL isSuccess;
        __block Rents *moreRents;

        [WebRequest findSearchString:self.city searchString:self.searchText id:rent.id typeId:_typeId priceId:_priceId sourceId:_sourceId   onCompletion:^(Rents *newRents, NSError *error) {
            if (error==nil) {
                isSuccess=YES;
                moreRents=newRents;
            }else{
                isSuccess=NO;
            }
        } ];
        
        if (moreRents!=nil && moreRents.rents.count>0) {
            [self.datasource.rents addObjectsFromArray:moreRents.rents];
        }
        
        
        NSMutableArray *moreIndexpath = [NSMutableArray arrayWithCapacity:moreRents.rents.count];
        for (int i=0; i<moreRents.rents.count; i++) {
            NSIndexPath *path =[NSIndexPath indexPathForRow:[self.datasource.rents indexOfObject:[moreRents.rents objectAtIndex:i]] inSection:0];
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
 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NearbyViewCell *cell = (NearbyViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    DetailViewController *destinct = segue.destinationViewController;
    destinct.id= [NSNumber numberWithInt:[cell.id.text intValue]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"搜索结果页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"搜索结果页面"];
}
@end
