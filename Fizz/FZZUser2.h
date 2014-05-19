//
//  FZZUser2.h
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FZZUser2 : NSManagedObject

@property (nonatomic, retain) NSNumber * facebookID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSNumber * userID;
@property (nonatomic, retain) NSManagedObject *coords;
@property (nonatomic, retain) NSManagedObject *creator;
@property (nonatomic, retain) NSManagedObject *guests;
@property (nonatomic, retain) NSManagedObject *invitees;
@property (nonatomic, retain) NSManagedObject *presentAtEvent;

@end
