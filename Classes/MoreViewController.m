//
//  MoreViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-5-30.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "MoreViewController.h"
#import "MoreAutoLoadViewCell.h"
#import "FeedbackViewController.h"
#import "AboutViewController.h"
#import "WebRequest.h"
#import "MBProgressHUD.h"
#import "MobClick.h"
#import "LTUpdate.h"

@interface MoreViewController ()
{
    FeedbackViewController *feedbackController;
    AboutViewController *aboutController;
    NSString *updateUrl;
}
@end

@implementation MoreViewController

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
    
    //导航栏设置
    [self setTitle:@"设置"];
    [self setNavLeftButton];
    [self initStyle];
    
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    //否则Group风格显示不出来。
    if(ISOS7){
        self.tableView.backgroundColor=[UIColor colorWithWhite:1.0 alpha:0.8];
    }
}

#pragma mark 设置导航栏上的标题和左侧按钮样式
-(void)setTitle:(NSString *)title
{     UIFont *font = [UIFont systemFontOfSize:kNav_TitleSize];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }else if(section==1){
        return 3;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *loadMore=@"LoadingMoreCell";
    if (indexPath.section==0) {
        MoreAutoLoadViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:loadMore];
        if (cell==nil) {
            cell=[[MoreAutoLoadViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMore];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return  cell;
    }
    
    UITableViewCell *cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    cell.backgroundColor=[UIColor whiteColor];
    return cell;
}

-(CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
        switch (indexPath.row) {
//            case 0:
//                feedbackController=[self.storyboard instantiateViewControllerWithIdentifier:@"FeedController"];
//                [self.navigationController pushViewController:feedbackController animated:YES];
//                break;
            case 1:
            {
                [self chkUpdate];
                break;
            }
//            case 2:
//                aboutController=[self.storyboard instantiateViewControllerWithIdentifier:@"AboutController"];
//                [self.navigationController pushViewController:aboutController animated:YES];
//                break;
            default:
                break;
        }
    }
}

-(void)chkUpdate{
    
    BOOL isConnect=[WebRequest isConnectionAvailable];
    if (!isConnect) {
        [self warnMsg:@"网络连接失败"];
        return;
    }
    
       MBProgressHUD *hudLoading=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
         hudLoading.labelText=@"检测中...";
        [hudLoading show:YES];
    
    //检测版本
    [[LTUpdate shared] update:LTUpdateNow
                     complete:^(BOOL isNewVersionAvailable, LTUpdateVersionDetails *versionDetails) {
                         
                         [hudLoading hide:YES];
                         //*// [TIP] Remove the first slash to toggle block comments if you'd like to use MBAlertView.
                         if (isNewVersionAvailable) {
                             //                             DLog(@"New version %@ released on %@.", versionDetails.version, versionDetails.releaseDate);
                             //                             DLog(@"The app is about %@", humanReadableFileSize(versionDetails.fileSizeBytes));
                             //                             DLog(@"Release notes:\n%@", versionDetails.releaseNotes);
                             [[LTUpdate shared] alertLatestVersion:LTUpdateOption | LTUpdateSkip];
                         } else {
                             // DLog(@"You App is up to date.");
                             [self warnMsg:@"当前已是最新版本"];
                         }
                     }];
    

//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        __block BOOL isSuccess;
//        __block NSData *data;
//        [WebRequest chkupdate:^(NSData *_data,NSError *error) {
//            data=_data;
//            if (error) {
//                isSuccess=false;
//            }else{
//                isSuccess=true;
//            }
//        }];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hudLoading hide:NO];
//            if (isSuccess) {
//                NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//               NSDictionary *updateInfo = [dict objectForKey:@"updateInfo"];
//                NSString *msg=[dict objectForKey:@"msg"];
//                if (updateInfo==nil) {
//                    [self warnMsg:msg];
//                }else{
//                    NSString *updateContent =[updateInfo objectForKey:@"updateContent"];
//                    updateUrl=[updateInfo objectForKey:@"updateUrl"];
//                    NSString *newVersion=[updateInfo objectForKey:@"version"];
//                    updateContent = [updateContent stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
//                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:newVersion message:updateContent delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"升级", nil];
//                    [alert show];
//                   
//                }
//            }else{
//                [self warnMsg:@"版本检测失败"];
//            }
//        });
//    });
}

#pragma mark alertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        
    }else if(buttonIndex ==1){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:updateUrl]];
    }
}

-(void)willPresentAlertView:(UIAlertView *)alertView
{
    
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
    [MobClick beginLogPageView:@"设置页面"];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"设置页面"];
}

//IOS7 group圆角风格
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//
//{
//    
//    if ([cell respondsToSelector:@selector(tintColor)]) {
//        
//        if (tableView == self.tableView) {
//            
//            CGFloat cornerRadius = 5.f;
//            
//            cell.backgroundColor = UIColor.clearColor;
//            
//            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
//            
//            CGMutablePathRef pathRef = CGPathCreateMutable();
//            
//            CGRect bounds = CGRectInset(cell.bounds, 10, 0);
//            
//            BOOL addLine = NO;
//            
//            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                
//                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
//                
//            } else if (indexPath.row == 0) {
//                
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
//                
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
//                
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
//                
//                addLine = YES;
//                
//            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//                
//                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
//                
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
//                
//                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
//                
//                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
//                
//            } else {
//                
//                CGPathAddRect(pathRef, nil, bounds);
//                
//                addLine = YES;
//                
//            }
//            
//            layer.path = pathRef;
//            
//            CFRelease(pathRef);
//            
//            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
//            
//            
//            
//            if (addLine == YES) {
//                
//                CALayer *lineLayer = [[CALayer alloc] init];
//                
//                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
//                
//                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
//                
//                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
//                
//                [layer addSublayer:lineLayer];
//                
//            }
//            
//            UIView *testView = [[UIView alloc] initWithFrame:bounds];
//            
//            [testView.layer insertSublayer:layer atIndex:0];
//            
//            testView.backgroundColor = UIColor.clearColor;
//            
//            cell.backgroundView = testView;
//            
//        }
//        
//    }

//}

@end
