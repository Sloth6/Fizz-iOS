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

-(NSString *)getUrlForEvents;
-(NSString *)getUrlForUsers;
//-(void)savePictureForUser:(FZZUser *)user;
//-(NSData *)loadPictureForUser:(FZZUser *)user;
-(void)loadFromCache;
-(void)clearCache;

@end
