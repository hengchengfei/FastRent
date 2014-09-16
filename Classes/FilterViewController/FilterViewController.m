//
//  ViewController.m
//  TestCombox
//
//  Created by heng chengfei on 14-8-21.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "FilterViewController.h"
#import "FRComboxViewController.h"
#import "FRComboxView.h"
#import "FRComboxItem.h"
#import "PullDownObject.h"
#import "Triangle.h"
#import "UIView+AddCGRect.h"
#import "WebRequest.h"

#import "ComboxData.h"
#import "ComboxDatas.h"


#define screen [[UIScreen  mainScreen]bounds]
#define FRViewPointY 64//combox组合view的Y轴位置
#define FRComboxViewPointY 0 //combox的Y轴位置
#define FRComboxViewHeight 45 //combox的高度
#define FRBetweenPD 7 //combox与下拉列表的间隔
#define MainViewBefore CGRectMake(0,FRViewPointY,screen.size.width,FRComboxViewHeight)//最外层的view大小设置，否则会遮盖其他view
#define MainViewAfter CGRectMake(0,FRViewPointY,screen.size.width,screen.size.height)
#define PDBoundsDistance 10 //下拉列表与两侧的距离之和
#define PDHeightAnimateBefore 0 //下拉列表的高度
#define PDHeightAnimateAfter screen.size.height - FRComboxViewHeight - 64-70 //下拉列表的高度
#define PDFrameMore 59//更多下拉框的宽度
#define PDPointYStart FRComboxViewPointY+FRComboxViewHeight+FRBetweenPD//下拉框的起始位置
#define PDFrameBefore CGRectMake(PDBoundsDistance/2.0,PDPointYStart,screen.size.width-PDBoundsDistance,PDHeightAnimateBefore)
#define PDFrameAfter CGRectMake(PDBoundsDistance/2.0,PDPointYStart,screen.size.width-PDBoundsDistance,PDHeightAnimateAfter)
#define PDTBLFrameBefore CGRectMake(0,0,PDFrameBefore.size.width,0)
#define PDTBLFrameAfter CGRectMake(0,0,PDFrameAfter.size.width,PDFrameAfter.size.height)
#define PDTBLAnimateDuration 0.5 //下拉动画间隔时间
#define PDTBLBackgroundBefore CGRectMake(0,FRComboxViewPointY+FRComboxViewHeight,screen.size.width,0) //下拉列表的背景view
#define PDTBLBackgroundAfter CGRectMake(0,FRComboxViewPointY+FRComboxViewHeight,screen.size.width,screen.size.height)//下拉列表的背景view
#define PDTBLArrow CGRectMake(0, FRComboxViewPointY+FRComboxViewHeight, 15, 12)

#define FilterParams_ID(frItem) type == [TypeDistance integerValue] ? @"distanceId":type ==[TypePrice integerValue]?@"priceId":@"rentTypeId"

@interface FilterViewController ()
{
    NSMutableArray *_arrayComboxs;
    FRComboxItem *_lastSelectComboxItem;
    
    UIView *backgroundView;
    PullDownViewController *_pullDownViewController;
    Triangle *_PDTBLArrow;
    
    PDMoreViewController *_pdMoreViewController;

    NSMutableDictionary *_filterParams;
}
@end

@implementation FilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame=CGRectMake(0, MainViewBefore.origin.y, screen.size.width,FRComboxViewHeight);
    // self.view.backgroundColor=[UIColor redColor];
    
    _filterParams=[[NSMutableDictionary alloc]init];

    //单击背景的手势操作
    UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenPullDownTable)];
    gesture.numberOfTapsRequired=1;
    gesture.numberOfTouchesRequired=1;
    
    _pullDownViewController = [[PullDownViewController alloc]init];
    _pullDownViewController.delegate=self;
    
    _arrayComboxs=[[NSMutableArray alloc]init];
    //CGRect ctrlFrame=CGRectMake(0, FRComboxViewPointY, screen.size.width, FRComboxViewHeight);
    CGRect frViewFrame=CGRectMake(0, FRComboxViewPointY, screen.size.width, FRComboxViewHeight);
    

    FRComboxView *frView=[[FRComboxView alloc]initWithFrame:frViewFrame];
    
    NSArray *arrayText=[NSArray arrayWithObjects:@"距离",@"租金",@"租住类型", nil];
    NSArray *arrayImage=[NSArray arrayWithObjects:@"down.png",@"down.png",@"down.png", nil];
    NSArray *arrayImagePressed=[NSArray arrayWithObjects:@"up.png",@"up.png",@"up.png", nil];
    NSArray *arrayType =@[TypeDistance,TypePrice,TypeRentType,@-1];//此处的类型一定要和对应的类型一致
    //
    CGFloat totalWidth = screen.size.width-PDFrameMore;
    
    for (int i=0; i<arrayText.count; i++) {
        CGFloat itemWidth=totalWidth/arrayText.count;
        
        CGRect itemFrame=CGRectMake(i*itemWidth, 0, itemWidth, FRComboxViewHeight);
        NSString *text=[arrayText objectAtIndex:i];
        UIImage *image=[UIImage imageNamed:[arrayImage objectAtIndex:i]];
        UIImage *imagePressed=[UIImage imageNamed:[arrayImagePressed objectAtIndex:i]];
        FRComboxItem *item=[[FRComboxItem alloc]initWithText:itemFrame text:text image:image pressedImage:imagePressed];
        item.state=COMBOX_PULL_DOWN;
        item.delegate=self;
        item.type=[arrayType objectAtIndex:i];
        [_arrayComboxs addObject:item];
        [frView addSubview:item];
        
    }
    
    //添加筛选下拉框
    CGRect itemMoreFrame=CGRectMake(totalWidth, 0, PDFrameMore, FRComboxViewHeight);
    NSString *text=@"筛选";
    FRComboxItem *item=[[FRComboxItem alloc]initWithText:itemMoreFrame text:text image:nil pressedImage:nil];
    item.state=COMBOX_PULL_DOWN;
    item.delegate=self;
    item.type=nil;
    [frView addSubview:item];
    
    
    //背景view
    backgroundView=[[UIView alloc]initWithFrame:PDTBLBackgroundBefore];
    backgroundView.backgroundColor=[UIColor colorWithRed:90/255 green:90/255 blue:90/255 alpha:0.2];
    [self.view addSubview:backgroundView];
    [backgroundView addGestureRecognizer:gesture];
    
    //增加下拉框
    _pullDownViewController.frame=PDFrameBefore;
   [self.view addSubview:_pullDownViewController.view];
    
//    UIView *cview = [[UIView alloc]initWithFrame:ctrlFrame];
//    [cview addSubview:frView];
//    
    //[_frController.view addSubview:frView];
  [self.view addSubview:frView];
    
    //arrow
    _PDTBLArrow = [[Triangle alloc]initWithFrame:PDTBLArrow];
    _PDTBLArrow.hidden=YES;
    _PDTBLArrow.color=[UIColor whiteColor];
    _PDTBLArrow.direction=tDirectionUp;
    [self.view addSubview:_PDTBLArrow];
    
    //添加筛选下拉列表
    _pdMoreViewController=[[PDMoreViewController alloc]initWithDataSource:self.comboxDatasource];
    _pdMoreViewController.delegate=self;
    [_pdMoreViewController.view changeCGPoint:CGPointMake(PDBoundsDistance/2.0, PDPointYStart)];
    _pdMoreViewController.view.hidden=YES;
    
    [self.view addSubview:_pdMoreViewController.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark FRComboxItemDelegate
-(void)comboxClick:(id)sender
{
    FRComboxItem *item=(FRComboxItem *)sender;
    
    if(_lastSelectComboxItem){
        if (item == _lastSelectComboxItem) {
            if( item.state==COMBOX_PULL_DOWN){
                [item refreshState:COMBOX_PULL_UP];
                [self showPullDownTable];
            }else{
                [item refreshState:COMBOX_PULL_DOWN];
                [self hiddenPullDownTable];
            }
        }else{
            [_lastSelectComboxItem refreshState:COMBOX_PULL_DOWN];
            [item refreshState:COMBOX_PULL_UP];
            _lastSelectComboxItem=item;
            [self showPullDownTable];
        }
    }else{
        [item refreshState:COMBOX_PULL_UP];
        _lastSelectComboxItem=item;
        [self showPullDownTable];
    }
}
#pragma mark PDTBLDelegate
-(void)PDTBLCellClick:(id)sender data:(ComboxData *)data
{
    NSInteger type = [_lastSelectComboxItem.type integerValue];
    NSString *key=FilterParams_ID(type);
    [_filterParams setObject:data.id forKey:key];
    [self hiddenPullDownTable];
    [self setComboxText:data];
    
    [self requestWebData];
    
}

#pragma mark PDMoreDelegate
-(void)PDMoreOKClick:(NSNumber *)sourceId houseType:(NSNumber *)houseTypeId order:(NSNumber *)orderId
{
 
[_filterParams setObject:sourceId forKey:@"sourceId"];
    [_filterParams setObject:houseTypeId forKey:@"houseTypeId"];
    [_filterParams setObject:orderId forKey:@"orderId"];
    
    [self hiddenPullDownTable];
    [_lastSelectComboxItem refreshState:COMBOX_PULL_DOWN];
    
    [self requestWebData];
}

#pragma 设置选中后，下拉框的显示
-(void)setComboxText:(ComboxData *)data
{
    if ([@"不限" compare:data.name]==0) {
        for (ComboxDatas *result in self.comboxDatasource.result) {
            for (ComboxData *_data in result.datas) {
                if (data==_data) {
                    _lastSelectComboxItem.label.text=result.name;
                    return;
                }
            }
        }
    }else{
        _lastSelectComboxItem.label.text=data.name;
    }
}

#pragma mark 隐藏和显示下拉列表框
-(void)hiddenPullDownTable{
    
    [self hiddenMoreTable];
    _PDTBLArrow.hidden=YES;
        self.view.frame=MainViewBefore;
    
    //点击筛选
    if (_lastSelectComboxItem.type==nil) {
        backgroundView.frame=PDTBLBackgroundBefore;
        _pullDownViewController.view.frame=PDFrameBefore;
        _pullDownViewController.tableview.frame=PDTBLFrameBefore;
        return;
    }
    
    [UIView animateWithDuration:PDTBLAnimateDuration animations:^{
        [_lastSelectComboxItem refreshState:COMBOX_PULL_DOWN];
        backgroundView.frame=PDTBLBackgroundBefore;
        _pullDownViewController.view.frame=PDFrameBefore;
        _pullDownViewController.tableview.frame=PDTBLFrameBefore;
        
    }];
    
    
}

-(void)showPullDownTable{
    //点击筛选

    if (_lastSelectComboxItem.type==nil) {
        [self showMoreTable];
        return;
    }
    
    [self hiddenMoreTable];
    
        self.view.frame=MainViewAfter;
    _pullDownViewController.view.frame=PDFrameBefore;
    _pullDownViewController.tableview.frame=PDTBLFrameBefore;
    _PDTBLArrow.hidden=NO;
    backgroundView.frame=PDTBLBackgroundBefore;
    [UIView animateWithDuration:PDTBLAnimateDuration animations:^{
        backgroundView.frame=PDTBLBackgroundAfter;
        [_PDTBLArrow changePointX:_lastSelectComboxItem.frame.origin.x+_lastSelectComboxItem.frame.size.width/2.0];
        _pullDownViewController.view.frame=PDFrameAfter;
        _pullDownViewController.tableview.frame=PDTBLFrameAfter;
    }];
    
    [self reloadPDTBLData];
}

#pragma mark 显示更多选项
-(void)hiddenMoreTable{
    _pdMoreViewController.view.hidden=YES;
}

-(void)showMoreTable{
    //NSArray *views = [[NSBundle mainBundle]loadNibNamed:@"PDMoreView" owner:nil options:nil];
    //UIView *view1 = views[0];
    _PDTBLArrow.hidden=YES;
    
    [self hiddenPullDownTable];
    
    self.view.frame=MainViewAfter;
    _pdMoreViewController.view.hidden=NO;
   [_pdMoreViewController.view changeCGPoint:CGPointMake(PDBoundsDistance/2.0, PDPointYStart)];
     
    _PDTBLArrow.hidden=NO;
    [_PDTBLArrow changePointX:_lastSelectComboxItem.frame.origin.x+_lastSelectComboxItem.frame.size.width/2.0];
    backgroundView.frame=PDTBLBackgroundAfter;
  
}

#pragma 重新加载下拉表格数据
-(void)reloadPDTBLData
{
    NSInteger type=[_lastSelectComboxItem.type integerValue];
    
    for (ComboxDatas *result in self.comboxDatasource.result) {
        if (type==[result.type integerValue]) {
            _pullDownViewController.datasource = result.datas;
            break;
        }
    }
    
    [_pullDownViewController.tableview reloadData];
    
}

#pragma mark refresh
-(void)requestWebData
{

    [self.delegate getFilterParams:_filterParams];
//    NSError *error=nil;
//    
//    NSData *data=[NSJSONSerialization dataWithJSONObject:_filterParams options:NSJSONWritingPrettyPrinted error:&error];
//    if ([data length]>0 && error==nil) {
//        NSString *json= [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",json);
//    }
}

@end
