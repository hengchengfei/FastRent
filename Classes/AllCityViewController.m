//
//  AllCityViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-8-6.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "AllCityViewController.h"
#import "SearchTableViewController.h"
#import "WebRequest.h"
#import "CityViewController.h"
#import "SearchSuggestion.h"

@interface AllCityViewController ()
{
    NSString *city;
    BOOL _isSelectCity;
    BOOL _isActive;
    SearchTableViewController *_searchController;
    NSMutableArray *_searchDatasource;
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
    
 
    self.textField.delegate=self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
    //[self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    
    _searchController=[[SearchTableViewController alloc]init];
    self.searchTable.delegate=_searchController;
    self.searchTable.dataSource=_searchController;
    self.searchTable.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    //默认城市
    city=[self getSearchCity];
    if (city) {
        [self setCity:city];
        _isSelectCity=YES;
    }else{
        _isSelectCity=NO;
        [self setCity:@"选择"];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!_isActive) {
        _isActive=YES;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}

#pragma 文本变化时调用
-(void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *txtField=[notification object];
    //UITextField *txtField=(UITextField *)sender;
    NSString *text=txtField.text;
    
    if (text.length<=0) {
        return;
    }
    
    if (!_isSelectCity) {
        return;
    }
    
    _searchDatasource =[[NSMutableArray alloc]init];
    
    [WebRequest findByKey:city key:text onCompletion:^(NSDictionary *dict, NSError *err) {
        if (err!=nil || dict==nil || dict.count<=0) {
            return;
        }
        NSArray *result=[dict objectForKey:@"datas"];
        for (int i=0; i<result.count; i++) {
            SearchSuggestion *bs=[SearchSuggestion new];
            NSDictionary *d1=[result objectAtIndex:i];
            
            bs.key=[d1 objectForKey:@"key"];
            bs.count=[d1 objectForKey:@"count"];
            
            [_searchDatasource addObject:bs];
        }
        
    }];
    if (_searchDatasource.count>0) {
        _searchController.datasource=_searchDatasource;
        [self.searchTable reloadData];
    }
    
    
}

#pragma 此方法在文本改变前就调用了,而不是在改变后调用
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.textField.text.length>0) {
        [self.textField resignFirstResponder];
    }else{
        _isActive=NO;
    }
    
    return YES;
}

#pragma UITableViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textField resignFirstResponder];
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
