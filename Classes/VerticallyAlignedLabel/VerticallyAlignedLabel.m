//
//  VerticallyAlignedLabel.m
//  FastRent
//
//  Created by heng chengfei on 14-6-8.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "VerticallyAlignedLabel.h"

@implementation VerticallyAlignedLabel

@synthesize verticalAlignment=_verticalAlignment;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.verticalAlignment=VerticalAlignmentMiddle;
    }
    return self;
}

-(void)setVerticalAlignment:(VerticalAlignment)verticalAlignment{
    _verticalAlignment=verticalAlignment;
    [self setNeedsDisplay];
}

-(CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines{
    CGRect textRect=[super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case VerticalAlignmentTop:
            textRect.origin.y=bounds.origin.y;
            break;
        case VerticalAlignmentBottom:
            textRect.origin.y=bounds.origin.y+bounds.size.height-textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
            break;
    }
    
    return textRect;
}

-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
