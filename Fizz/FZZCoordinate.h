//
//  FZZCoordinate.h
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SocketIO.h"

/*
 
 Referred to as a "latlng" on the server, the Coordinate is a simple object containing a longitude and latitude. Post a new marker from this class.
 
 WithAcknowledge should generally accept a null object. Whatever SocketIOCallback function is passed to that parameter will be called when the socket object is successfully sent. It may actually be when a callback from the server occurs; I believe it to be the first, and so I don't think it's nearly as useful.
 
 */

@class FZZEvent;

@interface FZZCoordinate :  NSObject

@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;

- (id)initWithLongitude:(float)lng andLatitude:(float)lat;
- (NSNumber *)longitude;
- (NSNumber *)latitude;
- (NSDictionary *)jsonDict;

-(NSDictionary *)asDictionaryForCache;
+(FZZCoordinate *)fromDictionaryForCache:(NSDictionary *)jsonMarker;

+(void)socketIONewMarker:(FZZCoordinate *)coord
                ForEvent:(FZZEvent *)event
         WithAcknowledge:(SocketIOCallback)function;

+(void)socketIOUpdateLocationWithAcknowledge:(SocketIOCallback)function;

+ (FZZCoordinate *)parseJSON:(NSDictionary *)coordJSON;


@end
