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

static NSString *FZZ_NEW_MARKER = @"newMarker";
static NSString *FZZ_LOCATION_CHANGE = @"locationChange";

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

+(void)socketIONewMarker:(FZZCoordinate *)coord
                ForEvent:(FZZEvent *)event
         WithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:[event eventID] forKey:@"eid"];
    
    /* latlng : latlng */
    [json setObject:[coord jsonDict] forKey:@"latlng"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_MARKER withData:json andAcknowledge:function];
}

+(void)socketIOUpdateLocationWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    // TODOAndrew get my actual location
    NSDictionary *coord = Nil;
    
    /* latlng : latlng */
    [json setObject:coord forKey:@"latlng"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_LOCATION_CHANGE withData:json andAcknowledge:function];
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
