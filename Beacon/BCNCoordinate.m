//
//  BCNCoordinate.m
//  Beacon
//
//  Created by Andrew Sweet on 1/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNCoordinate.h"

@interface BCNCoordinate ()

@property (nonatomic) float longitude;
@property (nonatomic) float latitude;

@end

@implementation BCNCoordinate

- (id)initWithLongitude:(float)lng andLatitude:(float)lat
{
    self = [super init];
    if (self) {
        self.longitude = lng;
        self.latitude = lat;
    }
    return self;
}

- (float)longitude{
    return self.longitude;
}

- (float)latitude{
    return self.latitude;
}

- (NSDictionary *)jsonDict{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    NSNumber *lng = [NSNumber numberWithFloat:self.longitude];
    NSNumber *lat = [NSNumber numberWithFloat:self.latitude];
    
    [dict setObject:lng forKey:@"lng"];
    [dict setObject:lat forKey:@"lat"];
    
    return dict;
}

+ (BCNCoordinate *)parseJSON:(NSDictionary *)coordJSON{
    if (coordJSON == NULL){
        return NULL;
    }
    
    float longitude, latitude;
    
    NSNumber *lng = [coordJSON objectForKey:@"lng"];
    NSNumber *lat = [coordJSON objectForKey:@"lat"];
    
    longitude = [lng floatValue];
    latitude  = [lat floatValue];
    
    return [[BCNCoordinate alloc] initWithLongitude:longitude
                                        andLatitude:latitude];
}

@end
