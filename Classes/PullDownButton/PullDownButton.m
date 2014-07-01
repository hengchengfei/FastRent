//
//  PullDownButton.m
//  FastRent
//
//  Created by heng chengfei on 14-5-28.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "PullDownButton.h" 

@implementation PullDownButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame labelText:(NSString *)text font:(UIFont *)font
{
    self=[super initWithFrame:frame];
    if (self) {
        [self initStyle:text font:font];
    }
    
    return self;
}

-(void)initStyle:(NSString *)text font:(UIFont *)font
{
    
    CGSize textSize=MB_TEXTSIZE(text, font);
    CGSize btnSize=self.frame.size;
    
    //添加边框
    self.backgroundColor=[UIColor whiteColor];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:1.0];
    [self.layer setBorderWidth:0.5];
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    CGColorRef colorRef=CGColorCreate(colorSpace, (CGFloat[]){175/255,175/255,175/255,0.2});
    [self.layer setBorderColor:colorRef];
   
    //
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(colorRef);
    
    //添加文本
    UILabel *label =[[UILabel alloc]initWithFrame:CGRectMake(5, 10, btnSize.width-30, textSize.height)];
    label.font=font;
    label.text=text;
    label.textColor=[UIColor blackColor];
    label.backgroundColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    
    //添加图片
    UIImage *image =[UIImage imageNamed:@"buttonDown.png"];
    UIImageView *imageview = [[UIImageView alloc]initWithImage:image];
    
    imageview.backgroundColor=[UIColor clearColor];
    
    CGSize imageSize=image.size;
    CGSize titleSize=self.frame.size;
    
    CGRect frame1=CGRectMake(titleSize.width-imageSize.width, titleSize.height/2-15/2, 12 , 12);
    imageview.frame=frame1;
    
    [self addSubview:label];
    [self addSubview:imageview];
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
