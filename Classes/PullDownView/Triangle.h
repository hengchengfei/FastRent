//
//  Triangle.h
//  Tangent
//
//  Created by Daniel.Burke on 3/27/14.
//  Copyright (c) 2014 D2. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Triangle : UIView

typedef enum {
    tDirectionUp,
    tDirectionRight,
    tDirectionDown,
    tDirectionLeft,
    tDirectionHalfUp,
    tDirectionHalfDown
} Direction;

@property (copy, nonatomic) UIColor *color;
@property (nonatomic) Direction direction;

@end
