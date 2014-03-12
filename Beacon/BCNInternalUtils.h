//
//  BCNInternalUtils.h
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCNInternalUtils : NSObject

+ (id)parseDictionaryIntoObject:(NSDictionary *)dictionary;

+ (NSDictionary *)encodeObjectIntoDictionary:(id)object;

@end
