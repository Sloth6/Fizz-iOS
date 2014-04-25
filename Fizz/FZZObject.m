//
//  FZZObject.m
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZObject.h"

static FZZSocketIODelegate *ioSocketDelegate;

@interface FZZObject ()

@property BOOL hasBeenFetched;
@property (nonatomic) int objectID;
@property NSDate *lastUpdate;

@end

@implementation FZZObject

@synthesize objectID;

-(id)init{
    self = [super init];
    
    if (self){
    }
    
    return self;
}

+ (void)setIOSocketDelegate:(FZZSocketIODelegate *)socketDelegate{
    ioSocketDelegate = socketDelegate;
}

+ (FZZSocketIODelegate *)getIOSocketDelegate{
    return ioSocketDelegate;
}

@end
