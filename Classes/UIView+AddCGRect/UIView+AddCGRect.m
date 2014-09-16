//
//  UIView+AddCGRect.m
//  TestCombox
//
//  Created by heng chengfei on 14-9-1.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "UIView+AddCGRect.h"

@implementation UIView (AddCGRect)

-(void)changeCGPoint:(CGPoint)point
{
  self.frame = CGRectMake(point.x,
               point.y,
               self.frame.size.width,
               self.frame.size.height);
}

-(void)changePointX:(CGFloat)pointX
{
    self.frame = CGRectMake(pointX,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height);
}

-(void)changeSizeH:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            height);
}
@end
