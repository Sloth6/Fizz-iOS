//
//  FZZCluster.m
//  Fizz
//
//  Created by Andrew Sweet on 5/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZCluster.h"
#import "FZZUser.h"
#import "FZZAppDelegate.h"

@implementation FZZCluster

- (NSArray *)userIDs{
    NSArray *usersCopy = [_users copy];
    NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:[usersCopy count]];
    
    for (int i = 0; i < [usersCopy count]; ++i){
        FZZUser *user = [usersCopy objectAtIndex:i];
        
        [mutArray addObject:[user userID]];
    }
    
    return mutArray;
}

+ (FZZCluster *)clusterFromUserIDs:(NSArray *)userIDs{
    NSMutableArray *users = [[NSMutableArray alloc] initWithCapacity:[userIDs count]];
    
    for (int i = 0; i < [userIDs count]; ++i){
        NSNumber *userID = [userIDs objectAtIndex:i];
        FZZUser *user = [FZZUser userWithUID:userID];
        
        [users addObject:user];
    }
    
    FZZCluster *cluster = [[FZZCluster alloc] initPrivateWithUserArray:users];
    
    return cluster;
}

-(id)initPrivateWithUserArray:(NSArray *)users{
    
    self = [super init];
 
    if (self){
        [self setUsers:users];
    }
    
    return self;
}

+ (FZZCluster *)parseJSON:(NSArray *)clusterJSON{
    
    NSMutableArray *users = [clusterJSON mutableCopy];
    
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *userJSON = obj;
        
        [users setObject:[FZZUser parseJSON:userJSON] atIndexedSubscript:idx];
    }];
    
    FZZCluster *cluster = [[FZZCluster alloc] initPrivateWithUserArray:users];
    
    return cluster;
}

+ (NSArray *)parseClusterJSONList:(NSArray *)clusterJSONlist{
    NSMutableArray *result = [clusterJSONlist mutableCopy];
    
    [clusterJSONlist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSArray *clusterJSON = obj;
        
        [result setObject:[FZZCluster parseJSON:clusterJSON] atIndexedSubscript:idx];
    }];
    
    return result;
}

@end
