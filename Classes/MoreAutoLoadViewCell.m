//
//  MoreAutoLoadViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-6-8.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "MoreAutoLoadViewCell.h"
 
@implementation MoreAutoLoadViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (ISOS7) {
            UIView *cellback=[[UIView alloc]init];
            cellback.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height );
            cellback.layer.borderWidth=0.57;
            cellback.layer.cornerRadius=8.0;
            cellback.layer.borderColor=[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0].CGColor;
            self.backgroundView=cellback;
            
        }
        
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(27, 13, 117, 20)];
        label.text=@"自动加载\"更多\"";
        label.font=[UIFont systemFontOfSize:15.0];
        label.backgroundColor=[UIColor clearColor];
        [self addSubview:label];
        
        UISwitch *switchMore =[[UISwitch alloc]init];
         switchMore.frame=CGRectMake(self.frame.size.width-95, 10, 50, 27);
        
        if (ISOS7) {
            switchMore.frame=CGRectMake(self.frame.size.width-70, 10, 50, 27);
        }
       
        [switchMore addTarget:self action:@selector(switchMoreClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:switchMore];
        
        //设置switch
        BOOL isAutoLoadMore=[self isAutoLoadMore];
        if (isAutoLoadMore) {
            [switchMore setOn:YES];
        }else{
            [switchMore setOn:NO];
        }
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)switchMoreClick:(id)sender
{
    UISwitch *switchButton=(UISwitch *)sender;
    BOOL isButttonOn=[switchButton isOn];
    if (isButttonOn) {
        [self saveAutoloadMore:YES];
    }else{
        [self saveAutoloadMore:NO];
    }
}

-(void)saveAutoloadMore:(BOOL)on
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:on forKey:kIsAutoLoadMore];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(BOOL)isAutoLoadMore{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    BOOL isAutoload = [defaults boolForKey:kIsAutoLoadMore];
    if (isAutoload) {
        return YES;
    }
    return NO;
}
@end
