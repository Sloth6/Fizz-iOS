//
//  BCFacebookConnection.m
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCFacebookConnection.h"
#import "BCNUser.h"

@implementation BCFacebookConnection

@synthesize facebookColor;

-(id)init{
    
    self = [super init];
    if (self) {
        // Custom initialization
        facebookColor = [UIColor colorWithRed:59.0/256.0 green:89.0/256.0 blue:152.0/256.0 alpha:1.0];
    }
    
    return self;
}


@end
