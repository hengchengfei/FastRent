//
//  SelectionViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-5-28.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "SelectionViewController.h"
#import "SelectionViewCell.h"

@interface SelectionViewController ()

@end

@implementation SelectionViewController

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
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.titleDatasource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"SelectionCell";
    
    SelectionViewCell *cell=(SelectionViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell=[[SelectionViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
 
    cell.titleLabel.text=[self.titleDatasource objectAtIndex:indexPath.row];
    [cell.titleLabel sizeToFit];
    
    if (self.idDatasource.count<=0) {
        return cell;
    }
    
    NSString *idResult;
    id idValue=[self.idDatasource objectAtIndex:indexPath.row];
    if ([idValue isKindOfClass:[NSNumber class]]) {
        idResult =[(NSNumber *)idValue stringValue];
    }
    cell.idLabel.text=idResult;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSNumber *id=[self.idDatasource objectAtIndex:indexPath.row];
    NSString *text=[self.titleDatasource objectAtIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.popDelegate != nil && [self.popDelegate respondsToSelector:@selector(popoverHandler:text:id:)] == YES) {
        [self.popDelegate popoverHandler:self text:text id:id];
    }
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
