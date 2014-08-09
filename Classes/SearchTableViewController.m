//
//  SearchTableViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-8-7.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "SearchTableViewController.h"
#import "SearchTableCell.h"
#import "SearchSuggestion.h"

@interface SearchTableViewController ()

@end

@implementation SearchTableViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"SearchTableCell";
    
    SearchTableCell * cell=[tableView dequeueReusableCellWithIdentifier :identifier];
    if (cell==nil) {
        cell=(SearchTableCell *)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    SearchSuggestion *bean= [self.datasource objectAtIndex:indexPath.row];
    
    cell.titleLabel.text=bean.key;
    cell.numberLabel.text=[NSString stringWithFormat:@"%d条",[bean.count integerValue]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchTableCell *cell=(SearchTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *text=cell.titleLabel.text;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate didSelectedSearch:text];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[[UIApplication sharedApplication]keyWindow] endEditing:YES];
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
