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

@dynamic users;

-(NSEntityDescription *)getEntityDescription{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    return [NSEntityDescription entityForName:@"FZZCluster" inManagedObjectContext:moc];
}

-(id)initPrivateWithUserArray:(NSArray *)users{
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDescription = [self getEntityDescription];
    self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
 
    if (self){
        [self setUsers:[NSOrderedSet orderedSetWithArray:users]];
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
