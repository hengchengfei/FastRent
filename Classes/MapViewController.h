//
//  MapViewController.h
//  FastRent
//
//  Created by heng chengfei on 14-5-9.
//  Copyright (c) 2014年 cf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController<MKMapViewDelegate>

@property(nonatomic,retain)NSNumber *lat;
@property(nonatomic,retain)NSNumber *lng;
@property(nonatomic,retain)NSString *address;
@property(nonatomic,retain)NSString *tel;
@property(nonatomic,retain)NSString *contacter;

@property(nonatomic,retain)IBOutlet MKMapView *mapView;
@end
