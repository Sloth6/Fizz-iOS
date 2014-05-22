//
//  FZZCluster.h
//  Fizz
//
//  Created by Andrew Sweet on 5/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FZZEvent, FZZUser;

@interface FZZCluster : NSManagedObject

@property (nonatomic, retain) NSOrderedSet *users;
@property (nonatomic, retain) FZZEvent *event;
@end

@interface FZZCluster (CoreDataGeneratedAccessors)

- (void)insertObject:(FZZUser *)value inUsersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromUsersAtIndex:(NSUInteger)idx;
- (void)insertUsers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeUsersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInUsersAtIndex:(NSUInteger)idx withObject:(FZZUser *)value;
- (void)replaceUsersAtIndexes:(NSIndexSet *)indexes withUsers:(NSArray *)values;
- (void)addUsersObject:(FZZUser *)value;
- (void)removeUsersObject:(FZZUser *)value;
- (void)addUsers:(NSOrderedSet *)values;
- (void)removeUsers:(NSOrderedSet *)values;

+ (FZZCluster *)parseJSON:(NSArray *)clusterJSON;
+ (NSArray *)parseClusterJSONList:(NSArray *)clusterJSONlist;

@end
