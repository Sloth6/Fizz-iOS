//
//  BCNObject.m
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNObject.h"

static BCN_IOSocketDelegate *ioSocketDelegate;

@interface BCNObject ()

@property BOOL hasBeenFetched;
@property (nonatomic) int objectID;
@property NSDate *lastUpdate;

@end

@implementation BCNObject

@synthesize objectID;

-(id)init{
    self = [super init];
    
    if (self){
    }
    
    return self;
}

+ (void)setIOSocketDelegate:(BCN_IOSocketDelegate *)socketDelegate{
    ioSocketDelegate = socketDelegate;
}

+ (BCN_IOSocketDelegate *)getIOSocketDelegate{
    return ioSocketDelegate;
}

@end
