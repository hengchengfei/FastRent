//
//  Triangle.m
//  Tangent
//
//  Created by Daniel.Burke on 3/27/14.
//  Copyright (c) 2014 D2. All rights reserved.
//

#import "Triangle.h"

@implementation Triangle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        //Default triangle Direction to up
        _direction = tDirectionDown; //tDirectionUp;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    if ((_direction==1&&self.frame.origin.x<100)||(_direction==3&&self.frame.origin.x>200)) {
        NSLog(@"NOOOOOOOOOOOOOOOOOOOOOOOOO");
    }
    
    switch (_direction) {
        case 0:{
            CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
            CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMinY(rect));  // top mid
            CGContextAddLineToPoint   (ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // top left
        }
            break;
        case 1:{
            CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // bottom left
            CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));  // top mid
            CGContextAddLineToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // top left
        }
            break;
        case 2:{
            CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
            CGContextAddLineToPoint(ctx, CGRectGetMidX(rect), CGRectGetMaxY(rect));  // bottom mid
            CGContextAddLineToPoint   (ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // top left
        }
            break;
        case 3:{ //Left
            CGContextMoveToPoint   (ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));  // top right
            CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMidY(rect));  // bottom mid
            CGContextAddLineToPoint   (ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));  // top left
        }
            break;
            
        default:
            break;
    }
    
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor(ctx, _color.CGColor);
    CGContextFillPath(ctx);
}

@end
