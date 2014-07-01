//
//  UserMapping.m
//  TestJson
//
//  Created by heng chengfei on 14-3-3.
//  Copyright (c) 2014年 cf. All rights reserved.
//
#import "Rent.h"
#import "Rents.h"

@implementation Rents

@synthesize code,rents;

+(Class)rents_class{
    return [Rent class];
}
@end
