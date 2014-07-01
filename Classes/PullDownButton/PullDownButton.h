//
//  PullDownButton.h
//  FastRent
//
//  Created by heng chengfei on 14-5-28.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullDownButton : UIButton

@property(nonatomic,retain)NSArray *titleArray;
@property(nonatomic,retain)NSArray *idArray;

-(id)initWithFrame:(CGRect)frame labelText:(NSString *)text font:(UIFont *)font;
@end
