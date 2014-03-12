//
//  BCNCoordinate.h
//  Beacon
//
//  Created by Andrew Sweet on 1/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCNCoordinate : NSObject

- (id)initWithLongitude:(float)lng andLatitude:(float)lat;
- (float)longitude;
- (float)latitude;
- (NSDictionary *)jsonDict;

+ (BCNCoordinate *)parseJSON:(NSDictionary *)coordJSON;

@end
