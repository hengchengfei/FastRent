//
//  MALTabBarViewController.m
//  TabBarControllerModel
//
//  Created by wangtian on 14-6-25.
//  Copyright (c) 2014年 wangtian. All rights reserved.
//

#import "MALTabBarViewController.h"
#import "NearbyViewController.h"

@interface MALTabBarViewController ()<MALTabBarDelegate,MALTabBarChinldVIewControllerDelegate>
{
    NSInteger _defauletSelectedIndex;
    NSString *_tabBarBgImageName;
    

}
@end

@implementation MALTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithItemModels:(NSArray *)itemModelArray
{
    if (self = [super init]) {
        
        self.itemsArray = itemModelArray;
        _defauletSelectedIndex = 0;
    }
    return self;
}

- (id)initWithItemModels:(NSArray *)itemModelArray defaultSelectedIndex:(NSInteger)defaultSelectedIndex
{
    self = [self initWithItemModels:itemModelArray];
    if (self) {
        
        _defauletSelectedIndex = defaultSelectedIndex;
    }
    return self;
}

- (UIView *)contentView
{
    if (_contentView == nil) {
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MainScreenBoundsSize.width, MainScreenBoundsSize.height - tabBarHeight)];
        [self.view addSubview:_contentView];
        //[self.view insertSubview:_contentView belowSubview:self.tabBar];
    }
    return  _contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpViewsWithDefauletSelectedIndex:_defauletSelectedIndex];
    // Do any additional setup after loading the view.
}


- (void)setUpViewsWithDefauletSelectedIndex:(NSInteger)defauletSelectedIndex
{
    if (self.itemsArray.count == 0) {
        
        return;
    }
    self.tabBar = [MALTabBar getMALTabBarWithItemModels:self.itemsArray defaultSelectedIndex:defauletSelectedIndex];
    
    if (_tabBarBgImageName) {
        
        [self.tabBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:_tabBarBgImageName]]];
       // [self.tabBar setBackgroundColor:[UIColor redColor]];
    }

    self.tabBar.delegate = self;
    [self.view addSubview:self.tabBar];
    for(int i = 0; i< self.itemsArray.count; i++){
    
        MALTabBarItemModel *itemModel = [self.itemsArray objectAtIndex:i];
       // id childViewController = [[NSClassFromString(itemModel.controllerName) alloc] init];
        
        //storyboard此时还未加载进来，所以不能用self.storyboard
        UIStoryboard *storyboard =[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        id childViewController  = [storyboard instantiateViewControllerWithIdentifier:itemModel.controllerName];
       [childViewController setDelegate:self];
       [self addChildViewController:childViewController];
        if (i == defauletSelectedIndex) {
            [[childViewController view] setFrame:self.contentView.bounds];
            [self.contentView addSubview:[childViewController view]];
            _currentViewController = childViewController;
        }
    }
}

#pragma mark -设置tabBar背景图片
- (void)setTabBarBgImage:(NSString *)imageName
{
    _tabBarBgImageName = imageName;
}

#pragma mark - 点击item触发代理方法
- (void)selectedItem:(MALTabBarItemModel *)selectedItemModel
{
    
    UIViewController *childViewController = [self.childViewControllers objectAtIndex:selectedItemModel.itemIndex];
    [childViewController.view setFrame:self.contentView.bounds];
    [_currentViewController.view removeFromSuperview];
    [self.contentView addSubview:childViewController.view];
    _currentViewController = childViewController;

}

#pragma mark -设置item  badge红圈
- (void)setBadgeNumber:(NSInteger)number index:(NSInteger)index
{
    [self.tabBar setItemBadgeNumberWithIndex:index badgeNumber:number];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
