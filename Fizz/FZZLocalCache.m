//
//  FZZLocalCache.m
//  Fizz
//
//  Created by Andrew Sweet on 7/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZLocalCache.h"

#import "FZZUser.h"
#import "FZZEvent.h"

static BOOL hasLoadedData = NO;
static FZZLocalCache *cache;

@implementation FZZLocalCache

+(FZZLocalCache *)cache{
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        // Code to run once
        cache = [[FZZLocalCache alloc] init];
    });
    
    return cache;
}

+(NSString *)getCacheDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    FZZUser *user = [FZZUser me];
    NSNumber *userID = [user userID];
    
    [documentsDirectory stringByAppendingPathComponent:[userID stringValue]];
    
    return documentsDirectory;
}

+(NSString *)getUrlForEvents{
    NSString *cacheDirectory = [FZZLocalCache getCacheDirectory];
    
    NSString* fileName = [cacheDirectory stringByAppendingPathComponent:@"events.out"];
    
    return fileName;
}

+(NSString *)getUrlForUsers{
    NSString *cacheDirectory = [FZZLocalCache getCacheDirectory];
    
    NSString* fileName = [cacheDirectory stringByAppendingPathComponent:@"users.out"];
    
    return fileName;
}

+(BOOL)updateCache{
    return [[FZZLocalCache cache] updateCache];
}

-(BOOL)updateCache{
    @synchronized(self){
        NSString *bundlePath = [FZZLocalCache getCacheDirectory];
        
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:bundlePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error != nil) {
            NSLog(@"error creating directory: %@", error);
            //..
        }
        
        if ([FZZUser saveUsersToFile:[FZZLocalCache getUrlForUsers]]){
            if ([FZZEvent saveEventsToFile:[FZZLocalCache getUrlForEvents]]){
                return YES;
            }
            
            NSLog(@"Saved users!");
        }
        
        NSLog(@"Cache update failed!");
        
        return NO;
    }
}

+(BOOL)loadFromCache{
    hasLoadedData = YES;
    
    return [[FZZLocalCache cache] loadFromCache];
}

-(BOOL)loadFromCache{
    @synchronized(self){
        NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[FZZLocalCache getUrlForEvents]];
        
        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[FZZLocalCache getUrlForUsers]];
        
        if ((eventDict == nil) && (userDict == nil)) return NO;
        if (([eventDict count] == 0) && ([userDict count] == 0)) return NO;
        
        NSLog(@"Load events...");
        [FZZEvent parseEventsJSONForCache:eventDict];
        
        NSLog(@"Load users...");
        [FZZUser parseUsersJSONForCache:userDict];
        
        NSLog(@"Complete users.");
    }
    
    return YES;
}

+(void)clearCache{
    [[FZZLocalCache cache] clearCache];
}

/*
 Delete all cache files
 */
-(void)clearCache{
    @synchronized(self){
        NSFileManager *manager = [NSFileManager defaultManager];
        
        // Events Cache
        NSError *error = nil;
        
        [manager removeItemAtPath:[FZZLocalCache getUrlForEvents] error:&error];
        
        if (error != nil) {
            NSLog(@"error deleting events cache: %@", error);
            //..
        }
        
        // Users Cache
        error = nil;
        
        [manager removeItemAtPath:[FZZLocalCache getUrlForUsers]  error:&error];
        
        if (error != nil) {
            NSLog(@"error deleting users cache: %@", error);
            //..
        }
    }
}

+(BOOL)containsInvalidData{
    NSArray *events = [FZZEvent getEvents];
    
    for (int i = 0; i < [events count]; ++i){
        FZZEvent *event = [events objectAtIndex:i];
        
        if ([event description] == nil){
            // TODOAndrew read the print statement
            NSLog(@"NULL DATA IS BAD DATA FIX THIS!!");
            
            return YES;
        }
    }
    
    return NO;
}

+(BOOL)hasLoadedDataFromCache{
    return hasLoadedData;
}

@end
