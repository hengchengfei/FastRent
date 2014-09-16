//
//  PDMoreViewController.m
//  TestCombox
//
//  Created by heng chengfei on 14-9-4.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "PDMoreViewController.h"

@interface PDMoreViewController ()

@end

@implementation PDMoreViewController

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
    
    [self.segSource removeAllSegments];
    [self.segHouseType removeAllSegments];
    [self.segOrder removeAllSegments];
 
    for (ComboxDatas *cDatas in self.datasource.result) {
        if ([TypeSource integerValue]== [cDatas.type integerValue]) {
            for (int i=0; i<cDatas.datas.count; i++) {
                ComboxData *data = (ComboxData *)cDatas.datas[i];
                [self.segSource insertSegmentWithTitle:data.name atIndex:i animated:NO];
            }
        }
        if ([TypeHouseType integerValue] == [cDatas.type integerValue]) {
            for (int i=0; i<cDatas.datas.count; i++) {
                ComboxData *data = (ComboxData *)cDatas.datas[i];
                [self.segHouseType insertSegmentWithTitle:data.name atIndex:i animated:NO];
            }
        }
        if ([TypeOrder integerValue] == [cDatas.type integerValue]) {
            for (int i=0; i<cDatas.datas.count; i++) {
                ComboxData *data = (ComboxData *)cDatas.datas[i];
                [self.segOrder insertSegmentWithTitle:data.name atIndex:i animated:NO];
            }
        }
    }
    [self.segSource setWidth:52.0 forSegmentAtIndex:0];
    [self.segSource setSelectedSegmentIndex:0];
    [self.segHouseType setWidth:52.0 forSegmentAtIndex:0];
    [self.segHouseType setSelectedSegmentIndex:0];
    [self.segOrder setSelectedSegmentIndex:0];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)okClick:(id)sender
{
    NSNumber *sourceId=[self getSegSelectedId:[TypeSource integerValue]  text:[self.segSource titleForSegmentAtIndex:self.segSource.selectedSegmentIndex]];
    NSNumber *houseTypeId=[self getSegSelectedId:[TypeHouseType integerValue] text:[self.segHouseType titleForSegmentAtIndex:self.segHouseType.selectedSegmentIndex]];
    
    NSNumber *orderId = [self getSegSelectedId:[TypeOrder integerValue] text:[self.segOrder titleForSegmentAtIndex:self.segOrder.selectedSegmentIndex]];
    
    
    [self.delegate PDMoreOKClick:sourceId houseType:houseTypeId order:orderId ];
    
}

#pragma mark 取得选择项的id
-(NSNumber *)getSegSelectedId:(NSInteger)type text:(NSString *)text
{
    for (ComboxDatas *cDatas in self.datasource.result) {
        if (type == [cDatas.type integerValue]) {
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
