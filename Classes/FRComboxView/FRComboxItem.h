//
//  FRComboxItem.h
//  FastRent
//
//  Created by heng chengfei on 14-8-21.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  enum
{
    COMBOX_PULL_DOWN,
    COMBOX_PULL_UP
}COMBOX_STATE;


@protocol FRComboxItemDelegate <NSObject>

-(void)comboxClick:(id)sender;

@end

@interface FRComboxItem : UIButton
{
    COMBOX_STATE *_state;
}


@property(nonatomic,retain) id<FRComboxItemDelegate> delegate;

@property(nonatomic,retain) NSNumber *type;//下拉框对应的类型
@property(nonatomic,assign) COMBOX_STATE state;
@property(nonatomic,retain) UILabel *label;//
@property(nonatomic,retain) UIImageView *imageview;//上下箭头图片
@property(nonatomic,retain) UILabel *line;

-(id)initWithText:(CGRect)frame text:(NSString *)text image:(UIImage *)image pressedImage:(UIImage *)image;
-(void)refreshState:(COMBOX_STATE) state;

@end
