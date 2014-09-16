//
//  PDMoreViewController.m
//  TestCombox
//
//  Created by heng chengfei on 14-9-4.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "PDMoreSearchViewController.h"



@interface PDMoreSearchViewController ()

@end

@implementation PDMoreSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithDataSource:(ComboxVo *)_comboxVo
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    self.datasource=_comboxVo;
    
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.segHouseType removeAllSegments];
    [self.segOrder removeAllSegments];
 
    for (ComboxDatas *cDatas in self.datasource.result) {
        if ([TypeHouseType integerValue] == [cDatas.type integerValue]) {
            for (int i=0; i<cDatas.datas.count; i++) {
                ComboxData *data = (ComboxData *)cDatas.datas[i];
                [self.segHouseType insertSegmentWithTitle:data.name atIndex:i animated:NO];
            }
        }
        if ([TypeOrder integerValue] == [cDatas.type integerValue]) {
            for (int i=0; i<cDatas.datas.count; i++) {
                ComboxData *data = (ComboxData *)cDatas.datas[i];
                if ([data.name compare:@"距离"]==0) {
                    continue;
                }
                [self.segOrder insertSegmentWithTitle:data.name atIndex:i animated:NO];
            }
        }
    }
    [self.segHouseType setWidth:52.0 forSegmentAtIndex:0];
    [self.segHouseType setSelectedSegmentIndex:0];
    [self.segOrder setSelectedSegmentIndex:1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)okClick:(id)sender
{

    NSNumber *houseTypeId=[self getSegSelectedId:TypeHouseType text:[self.segHouseType titleForSegmentAtIndex:self.segHouseType.selectedSegmentIndex]];
    
    NSNumber *orderId = [self getSegSelectedId:TypeOrder text:[self.segOrder titleForSegmentAtIndex:self.segOrder.selectedSegmentIndex]];
    
    
    [self.delegate PDMoreOKClick:houseTypeId order:orderId ];
    
}

#pragma mark 取得选择项的id
-(NSNumber *)getSegSelectedId:(NSNumber *)type text:(NSString *)text
{
    for (ComboxDatas *cDatas in self.datasource.result) {
        if ([type integerValue]== [cDatas.type integerValue]) {
            for (int i=0; i<cDatas.datas.count; i++) {
                ComboxData *data = (ComboxData *)cDatas.datas[i];
                if ([data.name compare:text]==0) {
                    return data.id;
                }
                
            }
        }
    }
    
    return nil;
}

@end
