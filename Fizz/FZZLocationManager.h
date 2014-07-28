//
//  FZZLocationManager.h
//  Fizz
//
//  Created by Andrew Sweet on 7/28/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FZZLocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

+ (CLLocation *)currentLocation;

@end
