//
//  BCNInternalUtils.h
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCNInternalUtils : NSObject

+ (id)parseDictionaryIntoObject:(NSDictionary *)dictionary;

+ (NSDictionary *)encodeObjectIntoDictionary:(id)object;

@end
