//
//  PagePhotosView.m
//  FastRent
//
//  Created by heng chengfei on 14-4-8.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "PagePhotosView.h"

//私有方法
@interface PagePhotosView (PrivateMethods)

-(void)loadScrollViewWithPage:(int)page;
-(void)scrollViewDidScroll:(UIScrollView *)sender;

@end

@implementation PagePhotosView

@synthesize dataSource,imageViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame withDataSource:(id<PagePhotosDataSource>)_dataSource
{
    self=[super initWithFrame:frame];
    if (self) {
        self.dataSource = _dataSource;
        
        int pageControlHeight =20;
        scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, frame.size.height-pageControlHeight, frame.size.width, pageControlHeight)];
        
        [self addSubview:scrollView];
        [self addSubview:pageControl];
        
        int kNumberOfPages = [dataSource numberOfPages];
        
        NSMutableArray *views = [[NSMutableArray alloc]init];
        for (unsigned i=0; i<kNumberOfPages; i++) {
            [views addObject:[NSNull null]];
        }
        
        self.imageViews=views;
        
        scrollView.pagingEnabled=YES;
        scrollView.contentSize=CGSizeMake(scrollView.frame.size.width*kNumberOfPages, scrollView.frame.size.height);
        scrollView.showsHorizontalScrollIndicator=NO;
        scrollView.showsVerticalScrollIndicator=NO;
        scrollView.scrollsToTop=NO;
        scrollView.delegate=self;
        
        pageControl.numberOfPages=kNumberOfPages;
        pageControl.currentPage=0;
        pageControl.backgroundColor=[UIColor blackColor];
        
        // pages are created on demand
		// load the visible page
		// load the page on either side to avoid flashes when the user starts scrolling
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
    }
    
    return self;
}

-(void)loadScrollViewWithPage:(NSInteger)page
{
    int kNumberOfPages =[dataSource numberOfPages];
    if (page<0) {
        return;
    }
    
    if (page>=kNumberOfPages) {
        return;
    }
    
    UIImageView *view=[imageViews objectAtIndex:page];
    if ((NSNull *)view ==[NSNull null]) {
        UIImage *image=[dataSource imageAtIndex:page];
        view =[[UIImageView alloc]initWithImage:image];
        [imageViews replaceObjectAtIndex:page withObject:view];
    }
    
    [view setContentMode:UIViewContentModeScaleAspectFit];
    if (nil==view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x=frame.size.width*page;
        frame.origin.y=0;
        view.frame=frame;
        [scrollView addSubview:view];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (pageControlUsed) {
        return;
    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1;
    pageControl.currentPage=page;
    
    [self loadScrollViewWithPage:page-1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page+1];
    
}

-(IBAction)changePage:(id)sender{
    NSInteger page=pageControl.currentPage;
    
    [self loadScrollViewWithPage:page-1.0];
    [self loadScrollViewWithPage:page+0.0];
    [self loadScrollViewWithPage:page+1.0];
    
    CGRect frame = scrollView.frame;
    frame.origin.x=frame.size.width*page;
    frame.origin.y=0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlUsed=YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    pageControlUsed=NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    pageControlUsed=NO;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
