//
//  BCNMarker.m
//  Beacon
//
//  Created by Andrew Sweet on 2/1/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNMarker.h"

@interface BCNMarker ()

@property (strong, nonatomic) BCNCoordinate *coord;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *date;

@end

@implementation BCNMarker

- (BCNCoordinate *)coordinate{
    return [_coord copy];
}

- (NSString *)name{
    return [_name copy];
}

- (NSDate *)date{
    return [_date copy];
}

+ (BCNMarker *)parseJSON:(NSDictionary *)markerJSON{
    if (markerJSON == NULL){
        return NULL;
    }
    
    // Latitude and Longitude
    NSDictionary *latlngJSON = [markerJSON objectForKey:@"latlng"];
    BCNCoordinate *coord = [BCNCoordinate parseJSON:latlngJSON];
    
    // Name of the Marker
    NSString *name = [markerJSON objectForKey:@"name"];
    
    // Time assigned to the Marker
    NSDate *date;
    {
        NSNumber *dateNum = [markerJSON objectForKey:@"time"];
        date = [NSDate dateWithTimeIntervalSince1970:[dateNum integerValue]];
    }
    
    BCNMarker *marker = [[BCNMarker alloc] init];
    marker.coord = coord;
    marker.name = name;
    marker.date = date;
    
    return marker;
}

- (NSDictionary *)jsonDict{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[_coord jsonDict] forKey:@"latlng"];
    [dict setObject:_name forKey:@"name"];
    
    NSNumber *timeInterval = [NSNumber numberWithInt:[_date timeIntervalSince1970]];
    
    [dict setObject:timeInterval forKey:@"time"];
    
    return dict;
}

@end
