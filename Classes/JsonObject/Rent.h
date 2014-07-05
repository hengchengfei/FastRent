//
//  User.h
//  TestJson
//
//  Created by heng chengfei on 14-3-3.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "Jastor.h"


@interface Rent : Jastor

@property(nonatomic,retain)NSArray *rentImages;
@property(nonatomic,retain)NSNumber *id;
@property(nonatomic,retain)NSString *agencyType;
@property(nonatomic,retain)NSString *city;
@property(nonatomic,retain)NSString *contacterName;
@property(nonatomic,retain)NSString *contacterPhone;
@property(nonatomic,retain)NSString *contacterPhoneDisplay;

@property(nonatomic,retain)NSString *deposit;
@property(nonatomic,retain)NSString *gatherTime;
@property(nonatomic,retain)NSString *houseAddress;
@property(nonatomic,retain)NSNumber *houseArea;
@property(nonatomic,retain)NSString *houseAreaUnit;
@property(nonatomic,retain)NSString *houseDecoration;
@property(nonatomic,retain)NSString *houseFacility;
@property(nonatomic,retain)NSString *houseImg;
@property(nonatomic,retain)NSString *houseFloor;
@property(nonatomic,retain)NSString *houseType;
@property(nonatomic,retain)NSString *infoSource;
@property(nonatomic,retain)NSString *infoChannel;
@property(nonatomic,retain)NSString *infoUrl;
@property(nonatomic,retain)NSString *publishContent;
@property(nonatomic,retain)NSString *publishTime;
@property(nonatomic,retain)NSString *publishTitle;
@property(nonatomic,retain)NSString *region1;
@property(nonatomic,retain)NSString *region2;
@property(nonatomic,retain)NSNumber *rentMoney;
@property(nonatomic,retain)NSString *rentType;
@property(nonatomic,retain)NSString *resident;
@property(nonatomic,retain)NSString *residentType;
@property(nonatomic,retain)NSString *roomDirection;
@property(nonatomic,retain)NSString *sex;
@property(nonatomic,retain)NSString *updateTime;
@property(nonatomic,retain)NSNumber *latitude;
@property(nonatomic,retain)NSNumber *longitude;
@property(nonatomic,retain)NSNumber *distance;
@property(nonatomic,retain)NSString *mapImage;


@end
