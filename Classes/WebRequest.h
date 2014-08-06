//
//  WebRequest.h
//  FastRent
//
//  Created by heng chengfei on 14-4-12.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rents.h"
#import "Rent.h"
#import "RentComboxs.h"
#import "Address.h"




@interface WebRequest : NSObject

+(WebRequest *)sharedObj;

+(NSDictionary *)request:(NSString *)url;

+(NSString *)getHost;

+(NSString *)getVersion;

+(BOOL)isConnectionAvailable;

+(void)findNearby:(float) latitude longitude:(float)longitude city:(NSString *)city distance:(NSNumber *)distanceId price:(NSNumber *)priceId type:(NSNumber *)typeId source:(NSNumber *)sourceId lastRentId:(NSNumber *)id  onCompletion:(void (^)(Rents *,NSError *))onCompletion;

+(void)findRent:(NSNumber *)id  onCompletion:(void (^)(Rent *,NSError *))onCompletion;

+(void)findComboxs: (void(^)(RentComboxs *bo,NSError *error))onCompletion;

+(void)findByIds:(NSString *)ids onCompletion:(void(^)(Rents *allRents,NSError *error))onCompletion;

+(void)findAddress:(float)latitude longitude:(float)longitude onCompletion:(void (^)(Address *,NSError *))onCompletion;

+(void)findByKey:(NSString *)city key:(NSString *)key onCompletion:(void(^)(NSDictionary *,NSError *))onCompletion;

+(void)findSearchString:(NSString *)city searchString:(NSString *)searchString id:(NSNumber *)id typeId:(NSNumber *)typeId priceId:(NSNumber *)priceId sourceId:(NSNumber *)sourceId onCompletion:(void(^)(Rents *allRents,NSError *error))onCompletion;

+(void)feedback:(NSString *)contacter content:(NSString *)content device:(NSString *)device complete:(void (^)(NSData *,NSError *))complete;

//+(void)chkupdate: (void (^)(NSData *,NSError *))complete;


@end
