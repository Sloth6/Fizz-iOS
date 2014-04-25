//
//  BCNMapViewController.h
//  Beacon
//
//  Created by Andrew Sweet on 12/24/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Mapbox/Mapbox.h>

@class BCNEventStreamViewController;

static NSString *kBCN_MAP_ID = @"beaconbeta.gknee3gd";

@interface BCNMapViewController : UIViewController <RMMapViewDelegate>

@property RMMapView *mapView;
@property BCNEventStreamViewController *esvc;

@end
