//
//  RentSearchBar.m
//  FastRent
//
//  Created by heng chengfei on 14-5-23.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "RentSearchBar.h"

@implementation RentSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)layoutSubviews
{
    UITextField *searchField;
    NSUInteger numViews = [self.subviews count];
    for (int i=0; i<numViews; i++) {
        if ([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [self.subviews objectAtIndex:i];
        }
    }

    if (searchField!=nil) {
        searchField.textColor=[UIColor redColor];
        [searchField setTextAlignment:NSTextAlignmentLeft];
        [searchField setBorderStyle:UITextBorderStyleRoundedRect];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(0, 0, 50, 44);
        button.titleLabel.text=@"上海";
        searchField.leftView=button;
    }
    
    [super layoutSubviews];
    
}

@end
