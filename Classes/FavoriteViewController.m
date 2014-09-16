//
//  FavoriteViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-4-25.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "FavoriteViewController.h"
#import "Rents.h"
#import "Rent.h"
#import "NearbyViewCell.h"
#import "WebRequest.h"
//#import "MBProgressHUD.h"
#import "DetailViewController.h"
#import "DXAlertView.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "MobClick.h"

@interface FavoriteViewController ()
{
    //MBProgressHUD *HUD;
    Rents *_allRents;
    
    DetailViewController *_detailViewController;
    Rents *_removeList;
    
    UIToolbar *toolbar;
}
@end

@implementation FavoriteViewController

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
    
    [self setTitle:@"我的收藏"];
    //[self setNavLeftButton];
    [self setNavRightButton];
    
    _removeList = [[Rents alloc]init];
    _removeList.rents = [[NSMutableArray alloc]init];
    
    
    
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    //self.navigationController.navigationBar.tintColor =[UIColor orangeColor];
    
    //控件开始位置和相关设置
    if (ISOS7) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.modalPresentationCapturesStatusBarAppearance=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    self.tableView.allowsSelectionDuringEditing=YES;
    
    //先隐藏
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    //loading..
    //    loadingIndicator =[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //    //    loadingIndicator.color=[UIColor grayColor];
    //    [loadingIndicator setFrame:CGRectMake(0, 0, 32.0f, 32.0f)];
    //    [loadingIndicator setCenter:CGPointMake(160.0f, 208.0f)];
    //    [loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    //
    //    [self.view insertSubview:loadingIndicator aboveSubview:self.tableView];
    
    
    //

    
}




#pragma mark -
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


-(void)setNavRightButton
{
    UIButton *button=[[UIButton alloc]init];
    UIImage *back=[UIImage imageNamed:@"NAVEdit.png"];
    button.frame = CGRectMake(0, 0, back.size.width, back.size.height);
    [button setBackgroundImage:back forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"NAVEdit_pressed.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    
    NSArray *arr=[[NSArray alloc]initWithObjects:item, nil];
    self.navigationItem.rightBarButtonItems=arr;
    
    //    UIButton *button=[[UIButton alloc]init];
    //    button.frame = CGRectMake(0, 0, 50, 22);
    //    //[button setBackgroundImage:back forState:UIControlStateNormal];
    //    [button addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    //    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    //    [button setTitle:@"编辑" forState:UIControlStateNormal];
    //    button.titleLabel.textAlignment=NSTextAlignmentRight;
    //
    //    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithCustomView:button];
    //    self.navigationItem.rightBarButtonItem=item;
}

-(void)setNavRightButtonTitle:(NSString *)title
{
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    UIButton *button =(UIButton *) item.customView;
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    UIFont *font=[UIFont systemFontOfSize:16.0];
    CGSize size= MB_TEXTSIZE(title, font);
    button.titleLabel.font=font;
    button.frame = CGRectMake(0, 0, size.width, size.height);
    //button.titleLabel.textAlignment=NSTextAlignmentRight;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 加载数据
-(void)loadFavoriteDatas
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    BOOL isConnected =[WebRequest isConnectionAvailable];
    if (!isConnected) {
        [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:1.0 position:@"bottom"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        return;
    }
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *array=[userDefaults arrayForKey:FavoriteIdKey];
    if (array.count<=0) {
        self.navigationItem.rightBarButtonItem.enabled=NO;
        [self.view makeToast:@"无收藏信息" duration:1.0 position:@"bottom"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        return;
    }
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"加载中";
    hud.dimBackground=NO;
    [hud show:YES];
    
    __block BOOL isSuccess = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *ids = [array componentsJoinedByString:@","];
        //ids=@"9999999,88888888";
        [WebRequest findByIds:ids onCompletion:^(Rents *allRents, NSError *error) {
            if (error!=nil) {
                isSuccess=NO;
            }else{
                _allRents=allRents;
                isSuccess=YES;
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
            [hud hide:YES];
            if (!isSuccess) {
                [self.view makeToast:@"无法连接到服务器，请检测网络连接" duration:1.0 position:@"bottom"];
                //[loadingIndicator stopAnimating];
                return;
            }
            
            if (_allRents!=nil && _allRents.rents.count<=0) {
                self.navigationItem.rightBarButtonItem.enabled=NO;
                [self.view makeToast:@"无收藏信息" duration:1.0 position:@"bottom"];
                [userDefaults removeObjectForKey:FavoriteIdKey];
            }else{
                self.navigationItem.rightBarButtonItem.enabled=YES;
                NSMutableArray *newArray=[[NSMutableArray alloc]init];
                for (int i=0; i<_allRents.rents.count; i++) {
                    [newArray addObject:[(Rent *)[_allRents.rents objectAtIndex:i] id]];
                }
                [userDefaults setObject:newArray forKey:FavoriteIdKey];
            }
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            self.tableView.hidden=NO;
            [self.tableView reloadData];
            //[loadingIndicator stopAnimating];
            
        });
    });
    
}

#pragma mark 底部工具栏
-(void)addBottomToolbar
{
    //增加tableview的偏移
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    CGSize size =CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+44);
    [self.tableView setContentSize:size];
    
    toolbar=[[UIToolbar alloc]initWithFrame: CGRectMake(0,self.view.frame.size.height-44, self.view.frame.size.width, 44.0 )];
    
    UIButton *allBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    allBtn.frame=CGRectMake(0, 0, ToolButton_Width, 35);
    [allBtn setBackgroundColor:[UIColor colorWithRed:95.0/255.0 green:155.0/255.0 blue:248.0/255.0 alpha:1.0]];
    [allBtn setTitle:@"全选" forState:UIControlStateNormal];
    [allBtn setBackgroundImage:[self imageWithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
    [allBtn addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deleteBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame=CGRectMake(ToolButton_Width+10.0, 0, ToolButton_Width, 35);
    [deleteBtn setBackgroundColor:[UIColor colorWithRed:95.0/255.0 green:155.0/255.0 blue:248.0/255.0 alpha:1.0]];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setBackgroundImage:[self imageWithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
    [deleteBtn setEnabled:false];
    [deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIBarButtonItem *selectAllItem= [[UIBarButtonItem alloc]initWithCustomView:allBtn];
    UIBarButtonItem *deleteItem =[[UIBarButtonItem alloc]initWithCustomView:deleteBtn];
    
    NSArray *array=[NSArray arrayWithObjects:selectAllItem,deleteItem, nil];
    
    [toolbar setBarStyle:UIBarStyleDefault];
    toolbar.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    [toolbar setItems:array animated:YES];
    [self.view addSubview:toolbar];
    
    //[self setToolbarItems:array animated:YES];
    
}

-(void)deleteBottomToolbar
{
    //减少tableview的偏移
    //    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    //    CGSize size =CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height+44);
    //    [self.tableView setContentSize:size];
    
    [toolbar removeFromSuperview];
}

#pragma mark 表格操作
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.tableView isEditing]) {
        [_removeList.rents addObject:[_allRents.rents objectAtIndex:indexPath.row]];
    }else{
        _detailViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"DetailController"];
        NearbyViewCell *cell=(NearbyViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        _detailViewController.id =[NSNumber numberWithInt:[cell.id.text intValue]];
        _detailViewController.delegate =self;
        _detailViewController.isFavorited=YES;//默认是收藏的
        
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:_detailViewController];
        if (ISOS7) {
            [nav.navigationBar setBarTintColor:appColor];
        }else{
            [nav.navigationBar setTintColor:appColor];
        }
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    
    //修改工具栏上按钮显示
    [self setBarButtonItemText];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_removeList.rents removeObject:[_allRents.rents objectAtIndex:indexPath.row]];
    [self setBarButtonItemText];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _allRents.rents.count;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *identifier = @"NearbyCell";
    NearbyViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil){
        cell=(NearbyViewCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    
    
    Rent *rent=[_allRents.rents objectAtIndex:row];
    cell.title.text=rent.publishTitle;
    cell.price.text=[NSString stringWithFormat:@"%@元/月",rent.rentMoney];
    cell.rentType.text=[rent rentType];
    cell.houseType.text=[rent houseType];
    cell.agencyType.text=[rent agencyType];
    cell.backgroundColor = [UIColor clearColor];
    cell.id.text = [[rent id]stringValue];
    
    
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}


#pragma mark 设置底部工具栏按钮的样式
-(void)setBarButtonItemText
{
    UIBarButtonItem *allItem = [toolbar.items objectAtIndex:0];
    UIButton *btnAll= (UIButton *)allItem.customView;
    
    UIBarButtonItem *deleteItem=[toolbar.items objectAtIndex:1];
    UIButton *btnDelete =(UIButton *)deleteItem.customView;
    if (_removeList.rents.count == _allRents.rents.count) {
        [btnAll setTitle:@"取消全选" forState:UIControlStateNormal];
    }else{
        [btnAll setTitle:@"全选" forState:UIControlStateNormal];
    }
    
    if (_removeList.rents.count <=0) {
        [btnDelete setBackgroundColor:[UIColor colorWithRed:95.0/255.0 green:155.0/255.0 blue:248.0/255.0 alpha:0.5]];
        
        [btnDelete setEnabled:NO];
    }else{
        [btnDelete setBackgroundColor:[UIColor colorWithRed:95.0/255.0 green:155.0/255.0 blue:248.0/255.0 alpha:1.0]];
        [btnDelete setEnabled:YES];
    }
}

#pragma mark -
#pragma mark 编辑按钮操作
-(IBAction)edit:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing) {
        [self setNavRightButtonTitle:@"完成"];
        [self addBottomToolbar];
        [self setBarButtonItemText];
    }else{
        [self setNavRightButton];
        [self deleteBottomToolbar];
    }
    
    [_removeList.rents removeAllObjects];
}

#pragma mark 选择按钮操作
-(void)selectAll:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    
    if ([btn.titleLabel.text compare:@"全选"]==NSOrderedSame) {
        [_removeList.rents removeAllObjects];
        for (int i=0; i<[self.tableView numberOfRowsInSection:0]; i++) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            [_removeList.rents addObject:[_allRents.rents objectAtIndex:i]];
        }
        [btn setTitle:@"取消全选" forState:UIControlStateNormal];
    }else{
        [_removeList.rents removeAllObjects];
        for (int i=0; i<[self.tableView numberOfRowsInSection:0]; i++) {
            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
        }
        [btn setTitle:@"全选" forState:UIControlStateNormal];
    }
    [self setBarButtonItemText];
}

#pragma mark 返回时更新数据
-(void)addItemViewController:(DetailViewController *)controller disFinishEnteringItem:(BOOL)isFavorite
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NearbyViewCell *cell=(NearbyViewCell *)[self.tableView cellForRowAtIndexPath:path];
    NSInteger row = path.row;
    NSNumber *_id=[NSNumber numberWithInteger:[cell.id.text integerValue]];
    
    NSArray *array=[NSArray arrayWithObject:path];
    
    //删除数组中数据，因为下面删除行时，会改变table中所有cell
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *ids=[userDefaults arrayForKey:FavoriteIdKey];
    
    //取消收藏
    if (!isFavorite) {
        NSMutableArray *newIds =[NSMutableArray arrayWithArray:ids];
        [newIds removeObject:_id ];
        [userDefaults setObject:newIds forKey:FavoriteIdKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        [_allRents.rents removeObject:[_allRents.rents objectAtIndex:row]];
        
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
    }else{
        [self.tableView deselectRowAtIndexPath:path animated:NO];
    }
    
}

#pragma mark 删除按钮操作
-(void)delete:(id)sender
{
    DXAlertView *alert =[[DXAlertView alloc]initWithTitle:@"提示" contentText:@"确定要删除吗？" leftButtonTitle:@"确定" rightButtonTitle:@"取消"];
    [alert show];
    
    alert.leftBlock=^{
        for (NSInteger i=[self.tableView numberOfRowsInSection:0]-1; i>=0; i--) {
            NearbyViewCell *cell=(NearbyViewCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (cell.selected) {
                [_allRents.rents removeObjectAtIndex:i];
                [self deleteFromUserCache:cell.id.text];
            }
        }
        [self.tableView reloadData];
        [_removeList.rents removeAllObjects];
        if (_allRents.rents.count<=0) {
            [self deleteBottomToolbar];
            
            [self setNavRightButton];
            self.navigationItem.rightBarButtonItem.enabled=NO;
        }
        [self setBarButtonItemText];
    };
    
    alert.rightBlock=^{
        return ;
    };
    
    
    
    
}

-(void)deleteFromUserCache:(NSString *)id;
{
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    NSArray *ids=[user arrayForKey:FavoriteIdKey];
    NSMutableArray *newIds=[NSMutableArray arrayWithArray:ids];
    
    NSNumber *_id=[NSNumber numberWithInt:[id intValue]];
    [newIds removeObject:_id];
    
    [user setObject:newIds forKey:FavoriteIdKey];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NearbyViewCell *cell=(NearbyViewCell *)[self.tableView cellForRowAtIndexPath:path];
    
    DetailViewController *des = segue.destinationViewController;
    des.delegate =self;
    des.isFavorited=YES;//默认是收藏的
    des.fromViewController=self;
    des.id=[NSNumber numberWithInt:[cell.id.text intValue]];
    
}


#pragma mark -
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

#pragma mark -
#pragma mark automatic
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadFavoriteDatas];
    
}

@end
