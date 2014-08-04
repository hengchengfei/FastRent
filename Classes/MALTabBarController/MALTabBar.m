//
//  MALTabBar.m
//  TabBarControllerModel
//
//  Created by wangtian on 14-6-25.
//  Copyright (c) 2014年 wangtian. All rights reserved.
//

#import "MALTabBar.h"

#define distance 10 //第一个和最后一个item距离屏幕边界的距离
#define itemY 4 //item在tabBar 里面的纵坐标
#define MALTabBarSize CGSizeMake(MainScreenBoundsSize.width, tabBarHeight)
#define MALTabBarOrigin CGPointMake(0, MainScreenBoundsSize.height - MALTabBarSize.height)
@implementation MALTabBar
{
    float _itemDisTance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (NSMutableArray *)items
{
    if (_items == nil) {
        
        _items = [[NSMutableArray alloc] init];
    }
    return _items;
}

+ (MALTabBar *)getMALTabBarWithItemModels:(NSArray *)itemModels defaultSelectedIndex:(NSInteger)defaultSelectedIndex
{
    MALTabBar *malTabBar = [[MALTabBar alloc] initWithFrame:CGRectMake(MALTabBarOrigin.x, MALTabBarOrigin.y, MALTabBarSize.width, MALTabBarSize.height)];
    malTabBar.itemArray = itemModels;
    [malTabBar setUpViews];
    [malTabBar selectdefaultItem:defaultSelectedIndex];
    return malTabBar;
}

#pragma mark - 设置item
- (void)setUpViews
{
    NSInteger itemCount = self.itemArray.count;
    _itemDisTance = (MALTabBarSize.width - 2 * distance - itemCount * itemWH) / (itemCount - 1);
    for(NSInteger itemIndex = 0; itemIndex < itemCount; itemIndex++){
    
        MALTabBarItemModel *itemModel = [self.itemArray objectAtIndex:itemIndex];
        itemModel.itemIndex = itemIndex;
        MALTabBarItem *item = [MALTabBarItem getMALTabBarItemWithModel:itemModel];
        item.tag = itemIndex;
        [item addTarget:self action:@selector(selectItem:) forControlEvents:(UIControlEventTouchUpInside)];
        CGPoint itemPosition = [self getItemPositionWithItemIndex:itemIndex itemCount:itemCount];
        [item setFrame:CGRectMake(itemPosition.x, itemPosition.y, itemWH, itemWH)];
        [self addSubview:item];
        [self.items addObject:item];
    }
    [self selectdefaultItem:0];
}

#pragma mark -获得item的坐标 （item的索引   item的总数）
- (CGPoint)getItemPositionWithItemIndex:(NSInteger)itemIndex itemCount:(NSInteger)itemCount
{
    CGPoint itemPosition;
    itemPosition = CGPointMake(itemIndex * (itemWH + _itemDisTance) + distance, (tabBarHeight - itemWH) / 2);
    return itemPosition;
}

#pragma mark -点击tabBar上item调用方法
- (void)selectItem:(UIButton *)sender
{
    [self selectedItemAtIndex:sender.tag];
}

#pragma mark -默认选中项
- (void)selectdefaultItem:(NSInteger)defaultSelectedItemIndex
{
     _currentSelectedIndex = defaultSelectedItemIndex;
    _lastSelectedIndex = defaultSelectedItemIndex;
    [self setSelectedItemStatus];
}

#pragma mark -选中item  改变item状态  并向tabBar代理发送消息
- (void)selectedItemAtIndex:(NSInteger)itemIndex
{
    if (itemIndex == _currentSelectedIndex) {
        
        return;
    }
    MALTabBarItemModel *itemModel = [self.itemArray objectAtIndex:itemIndex];
    _lastSelectedIndex = _currentSelectedIndex;
    _currentSelectedIndex = itemIndex;
    [self setSelectedItemStatus];
    [self setLastSelectedItemStatus];
    if ([self.delegate respondsToSelector:@selector(selectedItem:)]) {
        
        [self.delegate selectedItem:itemModel];
    }
}

#pragma mark - 设置选中item状态的样式
- (void)setSelectedItemStatus
{
    MALTabBarItemModel *itemModel = [self.itemArray objectAtIndex:_currentSelectedIndex];
    MALTabBarItem *currentSelecteditem = [self.items objectAtIndex:_currentSelectedIndex];
    [currentSelecteditem setTitleColor:selectedItemTitleColor forState:(UIControlStateNormal)];
    if (itemModel.selectedItemImageName != nil) {
        
        [currentSelecteditem setImage:[UIImage imageNamed:itemModel.selectedItemImageName] forState:(UIControlStateNormal)];
    }
}

#pragma mark - 设置上一个被选中的item的样式
- (void)setLastSelectedItemStatus
{
    MALTabBarItemModel *itemModel = [self.itemArray objectAtIndex:_lastSelectedIndex];
    MALTabBarItem *lastSelectedItem = [self.items objectAtIndex:_lastSelectedIndex];
    [lastSelectedItem setTitleColor:itemTitleColor forState:(UIControlStateNormal)];
    if (itemModel.itemImageName != nil) {
        
        [lastSelectedItem setImage:[UIImage imageNamed:itemModel.itemImageName] forState:(UIControlStateNormal)];
    }
}

- (void)setItemBadgeNumberWithIndex:(NSInteger)itemIndex badgeNumber:(NSInteger)badgeNumber
{
    MALTabBarItem *item = [self.items objectAtIndex:itemIndex];
    [item setItemBadgeNumber:badgeNumber];
}

//-(void)drawRect:(CGRect)rect
//{
//    //获得处理的上下文
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    //指定直线样式
//    CGContextSetLineCap(context, kCGLineCapSquare);
//    
//    //直线宽度
//    CGContextSetLineWidth(context, 10.0);
//    
//     //设置颜色
//    CGContextSetRGBStrokeColor(context, 30.0/255, 197.0/255.0, 183.0/255.0, 1.0);
//    
//    //开始绘制
//    CGContextBeginPath(context);
//    
//    //画笔移动到点(31,170)
//    CGContextMoveToPoint(context, 0, 0);
//    
//    //下一点
//    CGContextAddLineToPoint(context, 320, 0);
//    
//    CGContextStrokePath(context);
//}
@end




