//
//  FZZDataStore.m
//  Fizz
//
//  Created by Andrew Sweet on 4/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

//
// Based on materials from http://www.codigator.com/tutorials/ios-core-data-tutorial-with-example/
//
// Ankit Aggarwal 7/30/13
//


#import "FZZDataStore2.h"

static NSPersistentStore *store;
//static NSPersistentStoreCoordinator *coordinator;

static NSManagedObjectModel *managedObjectModel;
static NSManagedObjectContext *managedObjectContext;
static NSPersistentStoreCoordinator *persistentStoreCoordinator ;

static NSURL *dataStoreURL;

@interface FZZDataStore ()

@end

@implementation FZZDataStore

+ (void)initialize{
    dataStoreURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                             stringByAppendingPathComponent: @"FizzDataStore.sqlite"]];
    
    persistentStoreCoordinator = [self persistentStoreCoordinator];
    
    NSDictionary *pragmaOptions = @{ @"synchronous": @"OFF" };
    NSDictionary *storeOptions = @{ NSSQLitePragmasOption: pragmaOptions };
    NSError *error = nil;
    
    NSPersistentStoreCoordinator *coordinator = persistentStoreCoordinator;
    
    store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                      configuration:nil
                                                URL:dataStoreURL
                                            options:storeOptions
                                              error:&error];
}

- (id)init{
    self = [super init];
    
    if (self){
        
    }
    
    return self;
}

+ (NSManagedObjectContext *) managedObjectContext {
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return managedObjectContext;
}

+ (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return managedObjectModel;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:dataStoreURL options:nil error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return persistentStoreCoordinator;
}

+ (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)name{
    return [NSEntityDescription insertNewObjectForEntityForName:name
                                         inManagedObjectContext:[self managedObjectContext]];
}

+ (NSError *)synchronize{
    NSError *error;
    
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return error;
    } else {
        NSLog(@"Saved successfully!");
    }
    
    return NULL;
}

+ (NSArray *)fetchAllWithClassName:(NSString *)className{
    
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:className
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Returning Fetched Records
    return fetchedRecords;
}

@end
