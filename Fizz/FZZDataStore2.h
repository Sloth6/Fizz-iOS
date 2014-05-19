//
//  FZZDataStore.h
//  Fizz
//
//  Created by Andrew Sweet on 4/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface FZZDataStore : NSObject

+ (NSManagedObject *)insertNewObjectForEntityForName:(NSString *)name;

+ (NSError *)synchronize;

@end
