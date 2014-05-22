//
//  BCNInternalUtils.h
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

/*
 
 This currently unused class may end up being used for caching.
 
 [TODOAndrew (5/13/14)] Decide if this is useful for caching. Use it or lose it.
 
 */

#import <Foundation/Foundation.h>

@interface BCNInternalUtils : NSObject

+ (id)parseDictionaryIntoObject:(NSDictionary *)dictionary;

+ (NSDictionary *)encodeObjectIntoDictionary:(id)object;

@end