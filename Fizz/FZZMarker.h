//
//  FZZMarker.h
//  Fizz
//
//  Created by Andrew Sweet on 2/1/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZZCoordinate.h"

@interface FZZMarker : NSObject

- (FZZCoordinate *)coordinate;
- (NSString *)name;
- (NSDate *)date;

- (NSDictionary *)jsonDict;

+ (FZZMarker *)parseJSON:(NSDictionary *)markerJSON;

@end
