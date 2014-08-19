//
//  IntroductionViewController.m
//  FastRent
//
//  Created by heng chengfei on 14-8-19.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "IntroductionViewController.h"

@interface IntroductionViewController ()
{
    UIScrollView *_scrollView;
    int currentPage;
    int currentOffsetX;
    int imageCount;
}
@end

@implementation IntroductionViewController

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

#pragma 隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
