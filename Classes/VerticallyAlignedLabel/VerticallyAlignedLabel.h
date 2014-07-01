//
//  VerticallyAlignedLabel.h
//  FastRent
//
//  文本垂直方向对齐
//  Created by heng chengfei on 14-6-8.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum VerticalAlignment{
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom
}VerticalAlignment;

@interface VerticallyAlignedLabel : UILabel
{
    @private
    VerticalAlignment _verticalAlignment;
}

@property(nonatomic,assign)VerticalAlignment verticalAlignment;

@end
