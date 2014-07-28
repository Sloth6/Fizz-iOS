//
//  FZZCoordinate.m
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZCoordinate.h"
#import "FZZEvent.h"
#import "FZZSocketIODelegate.h"
#import "FZZAppDelegate.h"
#import "FZZLocationManager.h"

static NSString *FZZ_UPDATE_LOCATION = @"postUpdateLocation";

@implementation FZZCoordinate

-(NSDictionary *)asDictionaryForCache{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:self.latitude  forKey:@"latitude"];
    [dict setObject:self.longitude forKey:@"longitude"];
    
    return dict;
}

+(FZZCoordinate *)fromDictionaryForCache:(NSDictionary *)jsonMarker{
    NSNumber *latitude = [jsonMarker objectForKey:@"latitude"];
    NSNumber *longitude = [jsonMarker objectForKey:@"longitude"];
    
    return [[FZZCoordinate alloc] initWithLongitude:[longitude floatValue]
                                        andLatitude:[latitude floatValue]];
}

- (id)initWithLongitude:(float)lng andLatitude:(float)lat;
{
    self = [super init];
    
    if (self) {
        self.longitude = [NSNumber numberWithFloat:lng];
        self.latitude  = [NSNumber numberWithFloat:lat];
    }
    return self;
}

- (NSNumber *)longitude{
    return self.longitude;
}

- (NSNumber *)latitude{
    return self.latitude;
}

- (NSDictionary *)jsonDict{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:self.longitude forKey:@"lng"];
    [dict setObject:self.latitude forKey:@"lat"];
    
    return dict;
}

+(void)socketIOUpdateLocationWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    CLLocation *location = [FZZLocationManager currentLocation];
    
    CLLocationCoordinate2D locationCord = [location coordinate];
    
    NSNumber *longitude = [NSNumber numberWithFloat:locationCord.longitude];
    NSNumber *latitude = [NSNumber numberWithFloat:locationCord.latitude];
    
    NSDictionary *coord = [[NSDictionary alloc] initWithObjectsAndKeys:
                           longitude, @"lng",
                           latitude,  @"lat", nil];
    
    /* latlng : latlng */
    [json setObject:coord forKey:@"latlng"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_UPDATE_LOCATION withData:json andAcknowledge:function];
}

+ (FZZCoordinate *)parseJSON:(NSDictionary *)coordJSON{
    if (coordJSON == NULL){
        return NULL;
    }
    
    float longitude, latitude;
    
    NSNumber *lng = [coordJSON objectForKey:@"lng"];
    NSNumber *lat = [coordJSON objectForKey:@"lat"];
    
    longitude = [lng floatValue];
    latitude  = [lat floatValue];
    
    return [[FZZCoordinate alloc] initWithLongitude:longitude
                                        andLatitude:latitude];
}

@end
