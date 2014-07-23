//
//  FZZLocalCache.h
//  Fizz
//
//  Created by Andrew Sweet on 7/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZZUser, FZZEvent;

/*
 
 A simple read/write from jsons saved to text files and pictures saved as binaries
 
 */

@interface FZZLocalCache : NSObject

+(NSString *)getUrlForEvents;
+(NSString *)getUrlForUsers;

+(void)updateCache;
+(BOOL)loadFromCache;
+(void)clearCache;

+(BOOL)hasLoadedDataFromCache;

@end
