//
//  FRComboxView.m
//  FastRent
//
//  Created by heng chengfei on 14-8-21.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "FRComboxView.h"

@implementation FRComboxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//-(void)drawBorder{
//   // self.backgroundColor=[UIColor whiteColor];
//    [self.layer setMasksToBounds:YES];
//    [self.layer setCornerRadius:1.0];
//    [self.layer setBorderWidth:0.5];
//    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
//    
//    CGColorRef colorRef=CGColorCreate(colorSpace, (CGFloat[]){175/255,175/255,175/255,0.2});
//    [self.layer setBorderColor:colorRef];
//    
//    //
//    CGColorSpaceRelease(colorSpace);
//    CGColorRelease(colorRef);
//}

//-(void)drawRect:(CGRect)rect{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
//    CGContextMoveToPoint(context, 106, 0);
//    CGContextAddLineToPoint(context, 106,100);
//    CGContextStrokePath(context);
//}
@end
