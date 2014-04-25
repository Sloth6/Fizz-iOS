//
//  FZZCoordinate.h
//  Fizz
//
//  Created by Andrew Sweet on 1/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZZCoordinate : NSObject

- (id)initWithLongitude:(float)lng andLatitude:(float)lat;
- (float)longitude;
- (float)latitude;
- (NSDictionary *)jsonDict;

+ (FZZCoordinate *)parseJSON:(NSDictionary *)coordJSON;

@end
