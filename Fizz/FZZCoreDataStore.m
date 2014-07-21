//
//  FZZCoreDataStore.m
//  Fizz
//
//  Created by Andrew Sweet on 6/28/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FZZCoreDataStore.h"

static NSString *const TBCoreDataModelFileName = @"Fizz";

@interface FZZCoreDataStore ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSManagedObjectContext *mainQueueContext;
@property (strong, nonatomic) NSManagedObjectContext *privateQueueContext;

@end

@implementation FZZCoreDataStore

+ (void)deleteCache{
    NSURL *storeURL = [[FZZCoreDataStore applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fizz.sqlite"];
    
    NSString *path = [storeURL path];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager fileExistsAtPath:path];
    
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:path];
    
    if (fileExists)
    {
        FZZCoreDataStore *dataStore = [FZZCoreDataStore defaultStore];
        
        @synchronized(dataStore){
            dataStore.persistentStoreCoordinator = nil;
            dataStore.mainQueueContext = nil;
            dataStore.privateQueueContext = nil;
            dataStore.managedObjectModel = nil;
        
            BOOL success = [fileManager removeItemAtPath:path error:&error];
            if (!success) {
                NSLog(@"Error trying to delete cache: %@", [error localizedDescription]);
            }
        }
    }
}

+ (instancetype)defaultStore
{
    static FZZCoreDataStore *_defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultStore = [[FZZCoreDataStore alloc] init];
    });
    
    return _defaultStore;
}

#pragma mark - Singleton Access

+ (NSManagedObjectContext *)mainQueueContext
{
    return [[self defaultStore] mainQueueContext];
}

+ (NSManagedObjectContext *)privateQueueContext
{
    return [[self defaultStore] privateQueueContext];
}

+ (NSManagedObjectID *)managedObjectIDFromString:(NSString *)managedObjectIDString
{
    return [[[self defaultStore] persistentStoreCoordinator] managedObjectIDForURIRepresentation:[NSURL URLWithString:managedObjectIDString]];
}

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSavePrivateQueueContext:)name:NSManagedObjectContextDidSaveNotification object:[self privateQueueContext]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSaveMainQueueContext:) name:NSManagedObjectContextDidSaveNotification object:[self mainQueueContext]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.mainQueueContext performBlockAndWait:^{
            [self.mainQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
    @synchronized(self) {
        [self.privateQueueContext performBlockAndWait:^{
            [self.privateQueueContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark - Getters

+ (NSManagedObjectContext *)getAppropriateManagedObjectContext{
//    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//    moc.persistentStoreCoordinator = [FZZCoreDataStore defaultStore].persistentStoreCoordinator;
//    
//    return moc;
    
    if ([NSThread isMainThread]) {
        return [FZZCoreDataStore mainQueueContext];
    } else {
        return [FZZCoreDataStore privateQueueContext];
    }
}

- (NSManagedObjectContext *)mainQueueContext
{
    if (!_mainQueueContext) {
        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _mainQueueContext;
}

- (NSManagedObjectContext *)privateQueueContext
{
    if (!_privateQueueContext) {
        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _privateQueueContext;
}

#pragma mark - Stack Setup

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        NSError *error = nil;
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self persistentStoreURL] options:[self persistentStoreOptions] error:&error]) {
            NSLog(@"Error adding persistent store. %@, %@", error, error.userInfo);
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:TBCoreDataModelFileName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}

+ (NSURL *)applicationDocumentsDirectory{
    return [[FZZCoreDataStore defaultStore] applicationDocumentsDirectory];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)persistentStoreURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fizz.sqlite"];
}

- (NSDictionary *)persistentStoreOptions
{
    return @{NSInferMappingModelAutomaticallyOption: @YES, NSMigratePersistentStoresAutomaticallyOption: @YES, NSSQLitePragmasOption: @{@"synchronous": @"OFF"}};
}


//static FZZCoreDataStore *defaultStore;
//
//static NSString *const TBCoreDataModelFileName = @"Fizz";
//
//@interface FZZCoreDataStore ()
//
//@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//
//@property (strong, nonatomic) NSManagedObjectContext *mainQueueContext;
//@property (strong, nonatomic) NSManagedObjectContext *privateQueueContext;
//
//@end
//
//@implementation FZZCoreDataStore
//
//#pragma mark - Singleton Access
//
//+ (NSManagedObjectContext *)mainQueueContext
//{
//    return [[self defaultStore] mainQueueContext];
//}
//
//+ (NSManagedObjectContext *)privateQueueContext
//{
//    return [[self defaultStore] privateQueueContext];
//}
//
//#pragma mark - Getters
//
//#pragma mark - Application's Documents directory
//
//// Returns the URL to the application's Documents directory.
//- (NSURL *)applicationDocumentsDirectory
//{
//    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//}
//
//- (NSManagedObjectModel *)managedObjectModel
//{
//    if (!_managedObjectModel) {
//        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:TBCoreDataModelFileName withExtension:@"momd"];
//        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    }
//    
//    return _managedObjectModel;
//}
//
//
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (!_persistentStoreCoordinator) {
//        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
//        NSError *error = nil;
//        
//        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self persistentStoreURL] options:[self persistentStoreOptions] error:&error]) {
//            NSLog(@"Error adding persistent store. %@, %@", error, error.userInfo);
//        }
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//// Returns the persistent store coordinator for the application.
//// If the coordinator doesn't already exist, it is created and the application's store added to it.
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Fizz.sqlite"];
//    
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    
//    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
//    NSNumber *didCrash = [pref objectForKey:@"didCrash"];
//    
//    if ([didCrash boolValue]){ // Delete the old cache if you've crashed recently
//        
//    }
//    
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        /* TODOAndrew (get rid of all abort() calls before launch)
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         
//         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//         * Simply deleting the existing store:
//         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
//         
//         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
//         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
//         
//         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//         
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//- (NSManagedObjectContext *)mainQueueContext
//{
//    if (!_mainQueueContext) {
//        _mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
//        _mainQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
//    }
//    
//    return _mainQueueContext;
//}
//
//- (NSManagedObjectContext *)privateQueueContext
//{
//    if (!_privateQueueContext) {
//        _privateQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        _privateQueueContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
//    }
//    
//    return _privateQueueContext;
//}
//
//+ (FZZCoreDataStore *)defaultStore{
//    if (!defaultStore){
//        defaultStore = [[FZZCoreDataStore alloc] init];
//    }
//    
//    return defaultStore;
//}
//
//+ (NSManagedObjectContext *)getAppropriateManagedObjectContext{
//    if ([NSThread isMainThread]) {
//        return [FZZCoreDataStore mainQueueContext];
//    } else {
//        return [FZZCoreDataStore privateQueueContext];
//    }
//}



@end