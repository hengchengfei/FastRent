//
//  ComboxViewController.m
//  TestCombox
//
//  Created by heng chengfei on 14-8-29.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "PullDownViewController.h"

@interface PullDownViewController ()

@end

@implementation PullDownViewController

@synthesize frame;

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
    
    self.view.frame=self.frame;
    self.tableview=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    self.tableview.separatorInset=UIEdgeInsetsZero;
    self.tableview.separatorColor=[UIColor grayColor];
    self.tableview.separatorStyle =UITableViewCellSeparatorStyleSingleLine;
    self.tableview.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.tableview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    ComboxData *pdObject =(ComboxData *) [self.datasource objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont systemFontOfSize:14.0];
    cell.textLabel.text=pdObject.name;
    cell.textLabel.tag=[pdObject.id integerValue];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    ComboxData *pdObject=(ComboxData *)[self.datasource objectAtIndex:row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //回调combox
    [self.delegate PDTBLCellClick:tableView data:pdObject];
}

@end
