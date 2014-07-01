//
//  DetailImagesViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-5-18.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "DetailImagesViewCell.h"
#import "UIImageView+WebCache.h"
#import "Image.h" 


@implementation DetailImagesViewCell
{
    UIScrollView *_scrollView;
    UIView *blackView;
    Rent *rent;
    
    UILabel *countLabel;
    NSUInteger imageCount;
    NSUInteger currentPage;
    CGFloat currentOffsetX;
     
    int _offsetX;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(Rent *)data
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        rent = data;
        [self addScrollView];
    }
    return self;
}

-(void)addScrollView{
    _scrollView =[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 180)];
    //CGSize size = scrollView.frame.size;
    CGSize size =_scrollView.frame.size;
    imageCount=rent.rentImages.count;
    int imageViewOrignX=40;//图片距view边距
    int imageViewBetweenOrignX=20;//图片间的间隔
    int imageViewWidth=size.width-(2*imageViewOrignX);
    int imageViewHeight =180;
    int imageViewOrgnY=10;
    int scrollViewHeight=180;
    
    _offsetX =imageViewWidth +imageViewBetweenOrignX;
    
    NSUInteger sWidth=2*imageViewOrignX+imageCount*imageViewWidth+(imageCount-1)*imageViewBetweenOrignX;
    
    
    _scrollView.backgroundColor=[UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    _scrollView.pagingEnabled=YES;
    _scrollView.delegate=self;
    //scrollView.autoresizingMask=(UIViewAutoresizingFlexibleHeight)
    _scrollView.contentSize=CGSizeMake(sWidth, scrollViewHeight);
    
    
    NSMutableArray *imageViews = [[NSMutableArray alloc]init];
    for (int i=0; i<imageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        Image *img=(Image *)[rent.rentImages objectAtIndex:i];
        NSURL *url=[NSURL URLWithString:img.url];
        [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:kPNG_Loading_250]];
        
        int imageViewX=imageViewOrignX+i*(imageViewBetweenOrignX+imageViewWidth);
        imageView.frame=CGRectMake(imageViewX,imageViewOrgnY, imageViewWidth, imageViewHeight);
        imageView.contentMode =UIViewContentModeScaleAspectFit;
        imageView.backgroundColor=[UIColor clearColor];
        
        //添加分割线
        //左侧
        UIView *splitViewLeft=[[UIView alloc]initWithFrame:CGRectMake(imageViewX, imageViewOrgnY,2.0, imageViewHeight)];
        splitViewLeft.backgroundColor=[UIColor grayColor];
        splitViewLeft.alpha=0.2;
        
        //右侧
        int  splitRightX=imageViewX+imageViewWidth;
        UIView *splitViewRight=[[UIView alloc]initWithFrame:CGRectMake(splitRightX, imageViewOrgnY,2.0, imageViewHeight)];
        splitViewRight.backgroundColor=[UIColor grayColor];
        splitViewRight.alpha=0.2;
        
        [_scrollView addSubview:splitViewLeft];
        [_scrollView addSubview:splitViewRight];
        [_scrollView addSubview:imageView];
        [imageViews addObject:imageView];
    }
    
    //添加计数View
        UIFont *font =[UIFont fontWithName:@"Arial" size:12.0];
    
    currentPage =1;
    NSString *countL=[NSString stringWithFormat:@"%lu/%ld",(unsigned long)currentPage,(unsigned long)imageCount];
    CGSize sizeL=MB_TEXTSIZE(countL,font);

    CGRect rect = CGRectMake(imageViewOrignX+imageViewWidth-sizeL.width-sizeL.width-10, _scrollView.frame.size.height-sizeL.height-sizeL.height+5, sizeL.width+10, sizeL.height+5);
    countLabel=[[UILabel alloc]initWithFrame:CGRectZero];
     countLabel.backgroundColor=[UIColor clearColor];
    countLabel.textColor=[UIColor whiteColor];
    [countLabel setFrame:rect];
    countLabel.text=countL;
    countLabel.font = font;
    countLabel.textAlignment=NSTextAlignmentCenter;
 
    blackView = [[UIView alloc]initWithFrame:countLabel.frame];
    blackView.backgroundColor=[UIColor blackColor];
    blackView.alpha=0.5;

    [self addSubview:_scrollView];
    [self addSubview:blackView];
    [self addSubview:countLabel];

}


#pragma mark scrollviewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    DLog(@"%f",scrollView.contentOffset.x);
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //先取得当前所在的偏移点
    currentOffsetX= scrollView.contentOffset.x;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //根据最后松开时所在的x偏移点，判断向左还是向右滑动
    CGFloat offsetX = scrollView.contentOffset.x;
    //DLog(@"end:%f",offsetX);
    NSUInteger nextPage=currentPage;
    if (offsetX > currentOffsetX) {
        //right
        nextPage=currentPage+1;
    }else if(offsetX < currentOffsetX){
        nextPage=currentPage-1;
    }
    
    if (nextPage>imageCount || nextPage<=0) {
        return;
    }
    
    NSNumber *next=[NSNumber numberWithInteger:nextPage];
    
    [self performSelectorOnMainThread:@selector(gotoNextPageView:) withObject:next waitUntilDone:NO];
    //[self gotoNextPageView:nextPage];不起效果
}

#pragma mark 下一个图
-(void)gotoNextPageView:(NSNumber *)pageIndex
{
            UIFont *font =[UIFont fontWithName:@"Arial" size:12.0];
    
    NSString *countL=[NSString stringWithFormat:@"%ld/%lu",(long)pageIndex.integerValue,(unsigned long)imageCount];
    CGSize sizeL=MB_TEXTSIZE(countL, font);
    [ countLabel setFrame:CGRectMake(countLabel.frame.origin.x,countLabel.frame.origin.y,sizeL.width+10,countLabel.frame.size.height)];
    [blackView setFrame:countLabel.frame];
    countLabel.text=countL;
    CGPoint x=CGPointMake((pageIndex.intValue-1)*_offsetX,0);
    
    [_scrollView setContentOffset:x animated:YES];
    
    currentPage = pageIndex.intValue;
}

@end
