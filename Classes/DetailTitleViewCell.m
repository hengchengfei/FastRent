//
//  DetailTitleTableViewCell.m
//  FastRent
//
//  Created by heng chengfei on 14-3-25.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "DetailTitleViewCell.h"

#define Left_X 10.0f
#define Top_Y 5.0f
@implementation DetailTitleViewCell
{
    Rent *rent;
    UILabel *publishTitle;
    UILabel *publishTime;
    UILabel *infoSource;
    
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(Rent *)data
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
         self.selectionStyle=UITableViewCellSelectionStyleNone;
        rent =data;
        [self initAttribute];
    }
    return self;
}

-(void)initAttribute
{
    NSString *title =[rent publishTitle];
    
    //设置字体,包括字体及其大小
    UIFont *fontTitle=[UIFont fontWithName:@"FZHei-B01S" size:16];
    
    //label可设置的最大高度和宽度
    CGSize maxSize=CGSizeMake(300.0f, MAXFLOAT);
    
    //字符串在指定区域内按照指定的字体显示时,需要的高度和宽度(宽度在字符串只有一行时有用)
   //一般用法:指定区域的宽度而高度用MAXFLOAT,则返回值包含对应的高度
   //如果指定区域的宽度指定,而字符串要显示的区域的高度超过了指定区域的高度,则高度返回0
    //核心:多行显示,指定宽度,获取高度
     CGSize sizeTitle = MB_MULTILINE_TEXTSIZE(title, fontTitle, maxSize, NSLineBreakByWordWrapping);
    
    //指定用于显示的区域
    CGRect rectTitle =CGRectMake(Left_X, Top_Y, sizeTitle.width, sizeTitle.height);
    
     //CGRectZero表示(0,0,0,0),即留待后面再设置
    publishTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    
    //label默认只显示一行,把numberofline设为0,即表示不限制行数,根据实际显示
    [publishTitle setNumberOfLines:0];
    
    publishTitle.frame=rectTitle;
    publishTitle.text=title;
    publishTitle.font=fontTitle;
    publishTitle.textColor=[UIColor blackColor];//千万不要把这个设置忘记了

    [self addSubview:publishTitle];
    
    //时间
    publishTime = [[UILabel alloc]initWithFrame:CGRectZero];
    NSString *time=[@"发布时间：" stringByAppendingString:[rent publishTime]];
    UIFont *font =[UIFont fontWithName:@"Arial" size:11.0];
    CGSize sizeTime =MB_TEXTSIZE(time, font);
    
    CGRect rectTime=CGRectMake(Left_X, publishTitle.frame.origin.y +sizeTitle.height+15.0, sizeTime.width, sizeTime.height);
    publishTime.frame=rectTime;
    publishTime.text=time;
    publishTime.font=font;//千万不要把这个设置忘记了
    [publishTime setTextColor:[UIColor grayColor]];
    publishTime.alpha=0.5;
    [self addSubview:publishTime];
 
    //来源
    infoSource = [[UILabel alloc]initWithFrame:CGRectZero];
    NSString *source=[rent infoSource];
    UIFont *fontSource =[UIFont fontWithName:@"Arial" size:10.0];
    CGSize sizeSource =MB_TEXTSIZE(source, fontSource);
    
    CGRect rectSource=CGRectMake(self.frame.size.width-40
                                 , publishTime.frame.origin.y, sizeSource.width, sizeSource.height);
    infoSource.frame=rectSource;
    infoSource.text=source;
    infoSource.font=fontSource;//千万不要把这个设置忘记了
    infoSource.textAlignment=NSTextAlignmentRight;
    [infoSource setTextColor:[UIColor grayColor]];
    infoSource.alpha=0.5;
    [self addSubview: infoSource];
}

@end
