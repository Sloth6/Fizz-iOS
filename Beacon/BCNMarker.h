//
//  BCNMarker.h
//  Beacon
//
//  Created by Andrew Sweet on 2/1/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCNCoordinate.h"

@interface BCNMarker : NSObject

- (BCNCoordinate *)coordinate;
- (NSString *)name;
- (NSDate *)date;

- (NSDictionary *)jsonDict;

+ (BCNMarker *)parseJSON:(NSDictionary *)markerJSON;

@end
