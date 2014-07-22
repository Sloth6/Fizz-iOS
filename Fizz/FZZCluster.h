//
//  FZZCluster.h
//  Fizz
//
//  Created by Andrew Sweet on 5/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

/*
 
 Creating a cluster object allows better logic for storing Events and clusters (or more what would be more difficult, arrays of arrays of users, becomes arrays of clusters)
 
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@class FZZEvent, FZZUser;

@interface FZZCluster : NSObject

@property (nonatomic, strong) FZZEvent *event;
@property (nonatomic, strong) NSArray *users;

- (NSArray *)userIDs;
+ (FZZCluster *)clusterFromUserIDs:(NSArray *)userIDs;

+ (FZZCluster *)parseJSON:(NSArray *)clusterJSON;
+ (NSArray *)parseClusterJSONList:(NSArray *)clusterJSONlist;

@end
