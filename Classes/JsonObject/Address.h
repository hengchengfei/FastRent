//
//  Address.h
//  FastRent
//
//  Created by heng chengfei on 14-5-19.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "Jastor.h"

@interface Address : Jastor

@property(nonatomic,retain)NSString *business;
@property(nonatomic,retain)NSString *city;
@property(nonatomic,retain)NSString *cityCode;
@property(nonatomic,retain)NSNumber *code;
@property(nonatomic,retain)NSString *district;
@property(nonatomic,retain)NSString *formattedAddress;
@property(nonatomic,retain)NSNumber *lat;
@property(nonatomic,retain)NSNumber *lng;
@property(nonatomic,retain)NSString *msg;
@property(nonatomic,retain)NSString *province;
@property(nonatomic,retain)NSString *street;
@property(nonatomic,retain)NSString *streetNumber;
@property(nonatomic,retain)NSString *success;
@property(nonatomic,retain)NSString *location;

@end
