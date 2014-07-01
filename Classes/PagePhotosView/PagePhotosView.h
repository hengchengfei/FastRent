//
//  PagePhotosView.h
//  FastRent
//
//  Created by heng chengfei on 14-4-8.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PagePhotosDataSource

-(int)numberOfPages;

-(UIImage *)imageAtIndex:(NSInteger)index;

@end

@interface PagePhotosView : UIView<UIScrollViewDelegate>{
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    
    id<PagePhotosDataSource> dataSource;
    NSMutableArray *imageViews;
    
    BOOL pageControlUsed;
}

@property (nonatomic,retain) id<PagePhotosDataSource> dataSource;
@property(nonatomic,retain) NSMutableArray *imageViews;

-(IBAction)changePage:(id)sender;

-(id)initWithFrame:(CGRect)frame withDataSource:(id<PagePhotosDataSource>)_dataSource;

@end
