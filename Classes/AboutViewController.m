//
//  AboutViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-6-11.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "AboutViewController.h"
#import "WebRequest.h"
#import "AboutVersionViewCell.h"
#import "MobClick.h"

@interface AboutViewController ()

@end

@implementation AboutViewController



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
    
    [self setTitle:@"关于"];
    [self setNavLeftButton];
    [self initStyle];

    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.tableHeaderView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    //self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled=NO;
    
    //self.tableView.frame=self.view.frame;
}


#pragma mark 设置导航栏上的标题和左侧按钮样式
-(void)setTitle:(NSString *)title
{
    UIFont *font = [UIFont systemFontOfSize:kNav_TitleSize];
    
    CGSize titleSize=MB_TEXTSIZE(title, font);
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, titleSize.width, 44)];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=title;
    titleLabel.font=font;
    titleLabel.textColor=[UIColor whiteColor];
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


#pragma mark View样式设置
-(void)initStyle{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    if (ISOS7) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.modalPresentationCapturesStatusBarAppearance=NO;
        //self.navigationItem.leftBarButtonItem.title=@"";
        self.tabBarController.tabBar.translucent=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cell0=@"AboutIconCell";
   // NSString *cell1=@"AboutAuthorCell";
    NSString *cell2=@"AboutCopyrightCell";
    
    NSInteger row=indexPath.row;
    if (row==0) {
        AboutVersionViewCell *cell=(AboutVersionViewCell *)[self.tableView dequeueReusableCellWithIdentifier:cell0];
        
        cell.labelVersion.text=[NSString stringWithFormat:@"闪租 %@",[WebRequest getVersion]];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if(row==1){
//        UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:cell1];
//        cell.selectionStyle=UITableViewCellSelectionStyleNone;
//        return cell;
        UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:cell2];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }else if(row==2){
        
    }
    
    return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row=indexPath.row;
    if (row==0) {
        return 134.0;
    }else if(row==1){
        //return 86.0;
        if (ISOS7) {
            return self.tableView.frame.size.height-134;
        }
        return self.tableView.frame.size.height-134;
        
    }
    
    return 0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"关于页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"关于页面"];
}

@end
