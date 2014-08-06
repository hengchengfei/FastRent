//
//  FeedbackViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-6-11.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FeedbackViewController.h"
#import "MBProgressHUD.h"
#import "WebRequest.h"
#import "FeedbackViewCell.h"
#import "MobClick.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

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
    
    [self setTitle:@"用户反馈"];
    [self setNavLeftButton];
    [self initStyle];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwasHidden:) name:UIKeyboardDidHideNotification object:nil];
    
 
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    [self tapBackground];

}


#pragma mark 手势（触发背景）关闭键盘
-(void)tapBackground
{

    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnce)];
    
    [tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tap];
}
-(void)tapOnce
{    [self resetFrame];
    [[[UIApplication sharedApplication]keyWindow ]endEditing:YES];
}

#pragma mark return按键事件
//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    if (textField==self.contacterField) {
//        [textField resignFirstResponder];
//    }
//    return YES;
//}


#pragma mark 键盘显示和关闭事件
-(void)keyboardwasShown:(NSNotification *) notify{

    
}

-(void) keyboardwasHidden:(NSNotification *) notify{
 
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

#pragma mark 联系人编辑时，向上移动位置
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame=self.tableView.frame;
    if (ISOS7) {
       frame.origin.y=34.0;
    }else{
        frame.origin.y=-20;
    }

 
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame=frame;
    }];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self resetFrame];
    return YES;
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
    
}

#pragma mark FeedbackDelegate
-(void)resetFrame
{
    CGRect frame=self.tableView.frame;
    if (ISOS7) {
            frame.origin.y=64.0;
    }else{
        frame.origin.y=0.0;
    }

    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame=frame;
    }];
}
-(void)pushBackController
{
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *feedback=@"feedbackCell";
    
    FeedbackViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:feedback];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.delegate=self;
    cell.contacterField.borderStyle=UITextBorderStyleNone;//此设置后，下面设置方有效
    cell.contacterField.layer.borderWidth=0.5;
    cell.contacterField.layer.cornerRadius=0;
    cell.contacterField.layer.borderColor=[[[UIColor grayColor]colorWithAlphaComponent:0.5] CGColor];
    cell.contacterField.delegate=self;
    cell.contacterField.tag=1;
    
    cell.textView.layer.borderWidth=0.5;
    cell.textView.delegate=self;
    cell.textView.tag=0;
    cell.textView.layer.borderColor=[[[UIColor grayColor]colorWithAlphaComponent:0.5] CGColor];
    [cell.textView setPlaceholder:@"如您遇到问题，请留下您的宝贵意见，我们会及时与您联系，排查解决。"];
    [cell.textView setPlaceholderTextColor:[UIColor grayColor]];
    
    UIColor *hightColor=[UIColor  colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    [cell.commitButton setBackgroundImage:[self imageWithColor:hightColor] forState:UIControlStateHighlighted];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 210.0;
}
#pragma mark color转换为image
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



-(void)warnMsg:(NSString *)msg{
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode=MBProgressHUDModeText;
    hud.labelText=msg;
    [hud show:YES];
    [hud hide:YES afterDelay:2.0];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MobClick beginLogPageView:@"反馈页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    [MobClick endLogPageView:@"反馈页面"];
}

@end
