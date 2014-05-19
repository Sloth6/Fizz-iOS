//
//  FZZEvent2.h
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FZZUser2;

@interface FZZEvent2 : NSManagedObject

@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSNumber * numSeats;
@property (nonatomic, retain) FZZUser2 *creator;
@property (nonatomic, retain) NSSet *guests;
@property (nonatomic, retain) NSSet *invitees;
@property (nonatomic, retain) FZZUser2 *presentAtEvent;
@end

@interface FZZEvent2 (CoreDataGeneratedAccessors)

- (void)addGuestsObject:(FZZUser2 *)value;
- (void)removeGuestsObject:(FZZUser2 *)value;
- (void)addGuests:(NSSet *)values;
- (void)removeGuests:(NSSet *)values;

- (void)addInviteesObject:(FZZUser2 *)value;
- (void)removeInviteesObject:(FZZUser2 *)value;
- (void)addInvitees:(NSSet *)values;
- (void)removeInvitees:(NSSet *)values;

@end
