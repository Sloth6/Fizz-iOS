//
//  FZZCoordinate.m
//  Fizz
//
//  Created by Andrew Sweet on 1/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZCoordinate.h"
#import "FZZEvent.h"

static NSString *FZZ_NEW_MARKER = @"newMarker";

@interface FZZCoordinate ()

//@property (retain, nonatomic) NSNumber *longitude;
//@property (retain, nonatomic) NSNumber *latitude;

@end

@implementation FZZCoordinate

@dynamic longitude;
@dynamic latitude;
@dynamic message;

- (id)initWithLongitude:(float)lng andLatitude:(float)lat
{
    self = [super init];
//    self = (FZZCoordinate *)[FZZDataStore insertNewObjectForEntityForName:@"FZZCoordinate"];
    
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
    [json setObject:coord forKey:@"latlng"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_MARKER withData:json andAcknowledge:function];
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

//+ (NSArray *)fetchAll{
//    
//    NSString *className = @"FZZCoordinate";
//    
//    return [FZZDataStore fetchAllWithClassName:className];
//}

@end
