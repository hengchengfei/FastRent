//
//  FRComboxItem.m
//  FastRent
//
//  Created by heng chengfei on 14-8-21.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "FRComboxItem.h"

#define itemLabelPointX 0
#define itemLabelWidth 70 //
#define itemDistanceWithImage 0 //按钮文本与图片之间的距离
#define itemFont [UIFont systemFontOfSize:13.0]
#define itemLinePointX 8 //下划线距离左右边界的距离
#define itemLineBetweenBottom 4 //下划线距离底部的距离
#define itemLineHeight 1 //下划线的高度
#define itemImageDistanceRight 8 //图片距离右侧的距离

@implementation FRComboxItem
{
    UIImage *_defaultImage;
    UIImage *_pressedImage;
}

@synthesize state;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id)initWithText:(CGRect)frame text:(NSString *)text image:(UIImage *)image pressedImage:(UIImage *)imagePressed
{
    self=[super initWithFrame:frame];
    if (self) {
        _defaultImage=image;
        _pressedImage=imagePressed;
        [self setupView:text ];
        [self setupBorderLine];
    }
    [self addTarget:self action:@selector(itemclick:) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

-(void)itemclick:(id)sender
{
   // FRComboxItem *item=(FRComboxItem *)sender;
   // item.label.text=@"aa";
    
    [self.delegate comboxClick:sender];
}
-(void)setupView:(NSString *)text{
    
    CGSize size = MB_TEXTSIZE(text, itemFont);
 
    //添加文本框
    self.label=[[UILabel alloc]init];
    self.label.font=itemFont;
    self.label.text=text;
    self.label.textAlignment=NSTextAlignmentCenter;
    //self.label.textColor=[UIColor orangeColor];
    self.label.frame=CGRectMake(itemLabelPointX
                           ,self.frame.size.height/2-size.height/2
                           ,itemLabelWidth
                           ,size.height);
    [self addSubview:self.label];

    //添加图片
    if (_defaultImage!=nil) {
        self.imageview=[[UIImageView alloc]initWithImage:_defaultImage];
        //imageView.backgroundColor=[UIColor orangeColor];
        self.imageview.contentMode=UIViewContentModeScaleAspectFill;
        CGRect imageFrame=CGRectMake(self.frame.size.width-_defaultImage.size.width-itemImageDistanceRight
                                     , self.frame.size.height/2-_defaultImage.size.height/2
                                     , _defaultImage.size.width
                                     , _defaultImage.size.height);
        self.imageview.frame=imageFrame;
        [self addSubview:self.imageview];
    }

    
    //添加横线
    self.line=[[UILabel alloc]initWithFrame:CGRectZero];
    self.line.backgroundColor=appColor;
    [self addSubview:self.line];
}

-(void)refreshState:(COMBOX_STATE)state1{
    self.state=state1;
    if (state==COMBOX_PULL_DOWN) {
        self.imageview.image=_defaultImage;
        self.label.textColor=[UIColor blackColor];
        self.line.frame=CGRectZero;
    }else if(state1==COMBOX_PULL_UP){
        self.imageview.image=_pressedImage;
        self.label.textColor=appColor;
        self.line.frame=CGRectMake(itemLinePointX/2,
                                   self.frame.size.height-itemLineBetweenBottom,
                                   self.frame.size.width-itemLinePointX,
                                   itemLineHeight);
    }
}

#pragma mark 按钮添加边框
-(void)setupBorderLine{
    //添加边框
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:1.0];
    [self.layer setBorderWidth:0.5];
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    
    CGColorRef colorRef=CGColorCreate(colorSpace, (CGFloat[]){100/255,100/255,100/255,0.2});
    [self.layer setBorderColor:colorRef];
    
    //
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(colorRef);
}

@end
