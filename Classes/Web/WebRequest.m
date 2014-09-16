//
//  WebRequest.m
//  FastRent
//
//  Created by heng chengfei on 14-4-12.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import "WebRequest.h"
#import "Reachability.h"

@implementation WebRequest

+(WebRequest *)sharedObj
{
    static WebRequest *instance=nil;
    
    @synchronized(self){
        if (instance==nil) {
            instance = [[self alloc]init];
        }
    }
    return instance;
}


+(BOOL)isConnectionAvailable
{
    BOOL isExistenceNetwork =YES;
    
    //网络状态
    BOOL reachable=[[Reachability reachabilityForInternetConnection] isReachable];
    if (!reachable) {
        return NO;
    }
    
    //    Reachability *reach = [Reachability reachabilityWithHostname:[self getHost]];
    //    switch ([reach currentReachabilityStatus]) {
    //        case NotReachable:
    //            isExistenceNetwork=NO;
    //            break;
    //        case ReachableViaWiFi:
    //            isExistenceNetwork=YES;
    //            break;
    //        case ReachableViaWWAN:
    //            isExistenceNetwork=YES;
    //            break;
    //        default:
    //            break;
    //    }
    
    return isExistenceNetwork;
}

+(NSString *)getHost
{
    NSString *configpath=[[NSBundle mainBundle]pathForResource:@"Config" ofType:@"plist"];
    
    NSDictionary *configDict = [NSDictionary dictionaryWithContentsOfFile:configpath];
    NSString *server =(NSString *) [configDict objectForKey:@"Server"];
    return server;
}


+(NSDictionary *)request:(NSString *)url
{
    url=[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    DLog(@"%@",url);
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:120];
    [request setHTTPShouldHandleCookies:false];
    [request setHTTPMethod:@"GET"];
    
    NSError *error1;
    NSHTTPURLResponse *response;
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error1];
    // NSInteger statusCode= response.statusCode;
    if (error1!=nil) {
        DLog(@"%@",error1);
        return error1.userInfo;
    }
    
    NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:nil];
    if (dictionary==nil) {
        DLog(@"WebRequest.h服务器数据取得失败:%@",returnData);
        NSDictionary *errorDict = [NSDictionary dictionaryWithObject:@"Json取得失败" forKey:NSLocalizedDescriptionKey];
        dictionary =errorDict;
    }
    return dictionary;
}

+(NSString *)getUrlByKey:(NSString *)key
{
    NSString *webpath =[[NSBundle mainBundle]pathForResource:@"WebUrl" ofType:@"plist"];
    NSDictionary *webDict=[NSDictionary dictionaryWithContentsOfFile:webpath];
    
    NSString *server =[self getHost];
    NSString *url = (NSString *)[webDict objectForKey:key];
    
    return [server stringByAppendingString:url];
}

/**
 
 */
+(void)findNearby:(float) latitude longitude:(float)longitude city:(NSString *)city distance:(NSNumber *)distanceId price:(NSNumber *)priceId type:(NSNumber *)typeId source:(NSNumber *)sourceId lastRentId:(NSNumber *)id  onCompletion:(void (^)(Rents *,NSError *))onCompletion
{
    
    NSString *url= [self getUrlByKey:@"findNearby"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    url = [url stringByReplacingOccurrencesOfString:@"{latitude}" withString:[NSString stringWithFormat:@"%f",latitude]];
    url = [url stringByReplacingOccurrencesOfString:@"{longitude}" withString:[NSString stringWithFormat:@"%f",longitude]];
    url = [url stringByReplacingOccurrencesOfString:@"{city}" withString:[NSString stringWithFormat:@"%@",city]];
    if (distanceId!=nil) {
        url = [url stringByReplacingOccurrencesOfString:@"{distanceId}" withString:[NSString stringWithFormat:@"%d",distanceId.intValue]];
    }else{
        url = [url stringByReplacingOccurrencesOfString:@"{distanceId}" withString:@""];
    }
    if (priceId==nil) {
        url=[url stringByReplacingOccurrencesOfString:@"{priceId}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{priceId}" withString:priceId.stringValue];
    }
    if (typeId==nil) {
        url=[url stringByReplacingOccurrencesOfString:@"{typeId}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{typeId}" withString:typeId.stringValue];
    }
    if (sourceId==nil) {
        url=[url stringByReplacingOccurrencesOfString:@"{sourceId}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{sourceId}" withString:sourceId.stringValue];
    }
    if(id==nil){
        url=[url stringByReplacingOccurrencesOfString:@"{id}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{id}" withString:id.stringValue];
    }
    
    
    NSDictionary *dict= [self request:url ];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err =[NSError errorWithDomain:WebErrorDomain code:FWConnectFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        Rents *result= [[Rents alloc]initWithDictionary:dict];
        onCompletion(result,nil);
    }
    
}

+(void)findRent:(NSNumber *)id  onCompletion:(void (^)(Rent *,NSError *))onCompletion
{
    NSString *url=[self getUrlByKey:@"findRent"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    url=[url stringByReplacingOccurrencesOfString:@"{id}" withString:id.stringValue];
    
    NSDictionary *dict= [self request:url ];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err =[NSError errorWithDomain:WebErrorDomain code:FWConnectFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        Rent *result= [[Rent alloc]initWithDictionary:dict];
        onCompletion(result,nil);
    }
}

+(void)findComboxs:(void (^)(RentComboxs *, NSError *))onCompletion
{
    NSString *url= [self getUrlByKey:@"findComboxs"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    NSDictionary *dict= [self request:url];
    
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err =[NSError errorWithDomain:WebErrorDomain code:FWConnectFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        RentComboxs *boxx= [[RentComboxs alloc]initWithDictionary:dict];
        onCompletion(boxx,nil);
    }
}

+(void)findByIds:(NSString *)ids onCompletion:(void (^)(Rents *, NSError *))onCompletion
{
    NSString *url =[self getUrlByKey:@"findByIds"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    url=[url stringByReplacingOccurrencesOfString:@"{ids}" withString:ids];
    NSDictionary *dict =[self request:url];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err=[NSError errorWithDomain:WebErrorDomain code:FWConnectFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        Rents *rents = [[Rents alloc]initWithDictionary:dict];
        onCompletion(rents,nil);
    }
}

+(void)findAddress:(float)latitude longitude:(float)longitude onCompletion:(void (^)(Address *,NSError *))onCompletion
{
    NSString *url=[self getUrlByKey:@"findAddress"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    url=[url stringByReplacingOccurrencesOfString:@"{latitude}" withString:[NSString stringWithFormat:@"%f",latitude]];
    url=[url stringByReplacingOccurrencesOfString:@"{longitude}" withString:[NSString stringWithFormat:@"%f",longitude]];
    
    NSDictionary *dict=[self request:url];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err =[NSError errorWithDomain:WebErrorDomain code:FWTimeoutFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        Address *address = [[Address alloc]initWithDictionary:dict];
        onCompletion(address,nil);
    }
}

+(void)findByKey:(NSString *)city key:(NSString *)key onCompletion:(void (^)(NSDictionary *, NSError *))onCompletion
{
    NSString *url=[self getUrlByKey:@"findByKey"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    url=[url stringByReplacingOccurrencesOfString:@"{city}" withString:city];
    url=[url stringByReplacingOccurrencesOfString:@"{key}" withString:key];
    
    NSDictionary *dict=[self request:url];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err=[NSError errorWithDomain:WebErrorDomain code:FWTimeoutFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        onCompletion(dict,nil);
    }
}

+(void)findSearchString:(NSString *)city
           searchString:(NSString *)searchString
                     id:(NSNumber *)id
typeId:(NSNumber *)typeId
priceId:(NSNumber *)priceId
sourceId:(NSNumber *)sourceId
onCompletion:(void (^)(Rents *, NSError *))onCompletion
{
    NSString *url=[self getUrlByKey:@"findSearchString"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    url=[url stringByReplacingOccurrencesOfString:@"{city}" withString:city];
    url=[url stringByReplacingOccurrencesOfString:@"{searchString}" withString:searchString];
    if(id==nil){
        url=[url stringByReplacingOccurrencesOfString:@"{id}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{id}" withString:[id stringValue]];
    }
    if(typeId==nil){
        url=[url stringByReplacingOccurrencesOfString:@"{typeId}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{typeId}" withString:[typeId stringValue]];
    }
    if(priceId==nil){
        url=[url stringByReplacingOccurrencesOfString:@"{priceId}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{priceId}" withString:[priceId stringValue]];
    }
    if(sourceId==nil){
        url=[url stringByReplacingOccurrencesOfString:@"{sourceId}" withString:@""];
    }else{
        url=[url stringByReplacingOccurrencesOfString:@"{sourceId}" withString:[sourceId stringValue]];
    }
    
    NSDictionary *dict=[self request:url];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err =[NSError errorWithDomain:WebErrorDomain code:FWTimeoutFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        Rents *rents = [[Rents alloc]initWithDictionary:dict];
        onCompletion(rents,nil);
    }
    
}

+(void)feedback:(NSString *)contacter content:(NSString *)content device:(NSString *)device complete:(void (^)(NSData *,NSError *))complete
{
    NSString *url=[self getUrlByKey:@"feedback"];
    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
    url=[url stringByReplacingOccurrencesOfString:@"{contacter}" withString:contacter];
    url=[url stringByReplacingOccurrencesOfString:@"{content}" withString:content];
    url=[url stringByReplacingOccurrencesOfString:@"{device}" withString:device];
    
    
    DLog(@"%@",url);
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPShouldHandleCookies:false];
    [request setHTTPMethod:@"POST"];
    
    NSError *error1;
    
    NSHTTPURLResponse *response;
    
    NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error1];
    NSInteger statusCode= response.statusCode;
    if (statusCode==200 || statusCode==206) {
        
    }else{
        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"数据取得失败" forKey:NSLocalizedDescriptionKey];
        error1=[NSError errorWithDomain:WebErrorDomain code:statusCode userInfo:dict];
    }
    
    complete(data,error1);
}

+(NSString *)getVersion{
    NSDictionary *infoDict =[[NSBundle mainBundle]infoDictionary];
    NSString *version =[infoDict objectForKey:@"CFBundleVersion"];
    
    return  version;
}

+(void)getFilterInfo:(void (^)(ComboxVo *, NSError *))onCompletion
{
    NSString *url=[self getUrlByKey:@"getFilterInfo"];
    
    NSDictionary *dict=[self request:url];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err=[NSError errorWithDomain:WebErrorDomain code:FWTimeoutFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        NSArray *result =   [dict objectForKey:@"result"];
        NSMutableArray *dlist = [[NSMutableArray alloc]init];
        //所有下拉框的数据
        for (NSDictionary *data in result) {
            //每个下拉框定义
            ComboxDatas *d = [ComboxDatas new];
            [d setName:data[@"name"]];
            [d setType:data[@"type"]];
            
            //每个下拉框的列表数据
            NSMutableArray *datalist=[[NSMutableArray alloc]init];
            NSArray *datas =[data objectForKey:@"datas"];
            for (NSDictionary *d2 in datas) {
                ComboxData *dd =[ComboxData new];
                [dd setId:[d2 objectForKey:@"id"]];
                [dd setName:[d2 objectForKey:@"name"]];
                [datalist addObject:dd];
            }
            
            [d setDatas:datalist];
            
            [dlist addObject:d];
        }
        
        ComboxVo *vo =[ComboxVo new];
        [vo setStatus:[dict objectForKey:@"status"]];
        [vo setResult:dlist];
        
        
        onCompletion(vo,nil);
    }
    
}

+(void)getListNearby:(NSDictionary *)location filterparams:(NSDictionary *)filterparams page:(NSInteger)page complete:(void (^)(HouseVo *, NSError *))onCompletion
{
    NSString *url=[self getUrlByKey:@"getListNearby"];
    
    NSError *error=nil;
    
    NSData *locationdata=[NSJSONSerialization dataWithJSONObject:location options:NSJSONWritingPrettyPrinted error:&error];
    if ([locationdata length]>0 && error==nil) {
        NSString *json= [[NSString alloc]initWithData:locationdata encoding:NSUTF8StringEncoding];
        url=[url stringByReplacingOccurrencesOfString:@"{location}" withString:json];
    }else{
        onCompletion(nil,error);
        return;
    }
    
    NSData *paramsdata=[NSJSONSerialization dataWithJSONObject:filterparams options:NSJSONWritingPrettyPrinted error:&error];
    if ([paramsdata length]>0 && error==nil) {
        NSString *json=[[NSString alloc]initWithData:paramsdata encoding:NSUTF8StringEncoding];
        url=[url stringByReplacingOccurrencesOfString:@"{filterparams}" withString:json];
    }else{
        onCompletion(nil,error);
        return;
    }
    
    url=[url stringByReplacingOccurrencesOfString:@"{page}" withString:[NSString stringWithFormat:@"%d",page]];
    
    
    NSDictionary *dict=[self request:url];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err=[NSError errorWithDomain:WebErrorDomain code:FWTimeoutFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        HouseVo *vo=[HouseVo new];
        [vo setStatus:[dict objectForKey:@"status"]];
        
        HouseDatas *hdatas=[HouseDatas new];
        
        NSDictionary *result = [dict objectForKey:@"result"];
        hdatas.totalPage=[result objectForKey:@"totalPage"];
        hdatas.totalCount=[result objectForKey:@"totalCount"];
        hdatas.distanceId=[result objectForKey:@"distanceId"];
        NSArray *datas =[result objectForKey:@"datas"];
        
        NSMutableArray *dlist = [[NSMutableArray alloc]init];
        for (NSDictionary *data in datas) {
            //每个下拉框定义
            HouseData *d = [self convertToHouseData:data];
            
            [dlist addObject:d];
        }
        
        hdatas.datas=dlist;
        vo.result=hdatas;
        
        onCompletion(vo,nil);
    }
}

+(void)getListSearch:(NSDictionary *)location filterparams:(NSDictionary *)filterparams page:(NSInteger)page complete:(void (^)(HouseVo *, NSError *))onCompletion
{
    NSString *url=[self getUrlByKey:@"getListSearch"];
    
    NSError *error=nil;
    
    NSData *locationdata=[NSJSONSerialization dataWithJSONObject:location options:NSJSONWritingPrettyPrinted error:&error];
    if ([locationdata length]>0 && error==nil) {
        NSString *json= [[NSString alloc]initWithData:locationdata encoding:NSUTF8StringEncoding];
        url=[url stringByReplacingOccurrencesOfString:@"{location}" withString:json];
    }else{
        onCompletion(nil,error);
        return;
    }
    
    NSData *paramsdata=[NSJSONSerialization dataWithJSONObject:filterparams options:NSJSONWritingPrettyPrinted error:&error];
    if ([paramsdata length]>0 && error==nil) {
        NSString *json=[[NSString alloc]initWithData:paramsdata encoding:NSUTF8StringEncoding];
        url=[url stringByReplacingOccurrencesOfString:@"{filterparams}" withString:json];
    }else{
        onCompletion(nil,error);
        return;
    }
    
    url=[url stringByReplacingOccurrencesOfString:@"{page}" withString:[NSString stringWithFormat:@"%d",page]];
    
    
    NSDictionary *dict=[self request:url];
    if ([dict objectForKey:NSLocalizedDescriptionKey]!=nil) {
        NSError *err=[NSError errorWithDomain:WebErrorDomain code:FWTimeoutFailed userInfo:dict];
        onCompletion(nil,err);
    }else{
        HouseVo *vo=[HouseVo new];
        [vo setStatus:[dict objectForKey:@"status"]];
        
        HouseDatas *hdatas=[HouseDatas new];
        
        NSDictionary *result = [dict objectForKey:@"result"];
        hdatas.totalPage=[result objectForKey:@"totalPage"];
        hdatas.totalCount=[result objectForKey:@"totalCount"];
        NSArray *datas =[result objectForKey:@"datas"];
        
        NSMutableArray *dlist = [[NSMutableArray alloc]init];
        for (NSDictionary *data in datas) {
            //每个下拉框定义
            HouseData *d = [self convertToHouseData:data];
            
            [dlist addObject:d];
        }
        
        hdatas.datas=dlist;
        vo.result=hdatas;
        
        onCompletion(vo,nil);
    }
}

+(HouseData *)convertToHouseData:(NSDictionary *)dict
{
    HouseData *data=[HouseData new];
    data.id=dict[@"id"];
    data.rentImages=dict[@"rentImages"];
    data.agencyType=dict[@"agencyType"];
    data.city=dict[@"city"];
    data.contacterName=dict[@"contacterName"];
    data.contacterPhone=dict[@"contacterPhoneDisplay"];
    data.deposit=dict[@"deposit"];
    data.gatherTime=dict[@"gatherTime"];
    data.houseAddress=dict[@"houseAddress"];
    data.houseArea=dict[@"houseArea"];
    data.houseAreaUnit=dict[@"houseAreaUnit"];
    data.houseDecoration=dict[@"houseDecoration"];
    data.houseFacility=dict[@"houseFacility"];
    data.houseImg=dict[@"houseImg"];
    data.houseFloor=dict[@"houseFloor"];
    data.houseType=dict[@"houseType"];
    data.infoSource=dict[@"infoSource"];
    data.infoChannel=dict[@"infoChannel"];
    data.infoUrl=dict[@"infoUrl"];
    data.publishContent=dict[@"publishContent"];
    data.publishTime=dict[@"publishTime"];
    data.publishTitle=dict[@"publishTitle"];
    data.region1=dict[@"region1"];
    data.region2=dict[@"region2"];
    data.rentMoney=dict[@"rentMoney"];
    data.rentType=dict[@"rentType"];
    data.resident=dict[@"resident"];
    data.residentType=dict[@"residentType"];
    data.roomDirection=dict[@"roomDirection"];
    data.sex=dict[@"sex"];
    data.updateTime=dict[@"updateTime"];
    data.latitude=dict[@"latitude"];
    data.longitude=dict[@"longitude"];
    data.distance=dict[@"distance"];
    data.mapImage=dict[@"mapImage"];
    
    return data;
    
}
//+(void)chkupdate:(void (^)(NSData *, NSError *))complete
//{
//    NSString *url=[self getUrlByKey:@"chkupdate"];
//
//    url=[url stringByReplacingOccurrencesOfString:@"{version}" withString:[self getVersion]];
//    DLog(url);
//
//    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]init];
//    [request setURL:[NSURL URLWithString:url]];
//    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
//    [request setTimeoutInterval:30];
//    [request setHTTPShouldHandleCookies:false];
//    [request setHTTPMethod:@"GET"];
//
//
//    NSError *error1;
//
//    NSHTTPURLResponse *response;
//
//    NSData *data= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error1];
//    NSInteger statusCode= response.statusCode;
//    if (statusCode==200 || statusCode==206) {
//
//    }else{
//        NSDictionary *dict = [NSDictionary dictionaryWithObject:@"数据取得失败" forKey:NSLocalizedDescriptionKey];
//        error1=[NSError errorWithDomain:WebErrorDomain code:statusCode userInfo:dict];
//    }
//
//
//    complete(data,error1);
//
//}
@end
