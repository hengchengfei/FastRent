//
//  BaiduSuggestion.h
//  FastRent
//
//  Created by heng chengfei on 14-5-23.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchSuggestion : NSObject

@property(nonatomic,retain)NSString *key;
@property(nonatomic,retain)NSNumber *count;//一定要设置为retain，否则在table cell再次显示时会冲掉

@end
