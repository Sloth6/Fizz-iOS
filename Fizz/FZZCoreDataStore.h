//
//  FZZCoreDataStore.h
//  Fizz
//
//  Created by Andrew Sweet on 6/28/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZZCoreDataStore : NSObject

+ (NSManagedObjectContext *)mainQueueContext;
+ (NSManagedObjectContext *)privateQueueContext;
+ (NSManagedObjectContext *)getAppropriateManagedObjectContext;
+ (NSURL *)applicationDocumentsDirectory;

+ (FZZCoreDataStore *)defaultStore;
+ (void)deleteCache;

@end