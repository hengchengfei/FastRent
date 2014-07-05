//
//  User.m
//  TestJson
//
//  Created by heng chengfei on 14-3-3.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "Rent.h"
#import "Image.h"

@implementation Rent

@synthesize rentImages,agencyType,city,contacterName,contacterPhone,contacterPhoneDisplay,deposit,gatherTime,houseAddress,houseArea,houseDecoration,houseFacility,houseFloor,houseType,infoSource,infoChannel,publishContent,publishTime,publishTitle,region1,region2,rentMoney,rentType,resident,residentType,roomDirection,sex,updateTime,latitude,longitude,distance,mapImage;


+(Class)rentImages_class{
    return [Image class];
}
@end
