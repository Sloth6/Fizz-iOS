//
//  FZZContactDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZContactDelegate.h"

#import "FZZAppDelegate.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "FZZContactSelectionDelegate.h"

#import "FZZUtilities.h"

#import "FZZUser.h"

#import "PhoneNumberFormatter.h"

static FZZContactDelegate *searchDelegate;

static int kFZZNumRecentInvites = 10;
static int kFZZNumRecentInvitesSaved = 20;
static NSString *kFZZAddressBookPermission = @"addressBookPermission";

//static UITableView *tableView;

@interface FZZContactDelegate ()

//@property NSArray *invitableUsersAndContacts;

//@property NSArray *filteredRecents;
//@property NSArray *filteredUsersAndContacts; // Fizz Users and Contacts
//@property NSMutableSet *invitedContacts;
//
//@property NSMutableSet *selectedUsers; // FZZUsers
//@property NSMutableSet *selectedContacts; // pn + name

@property NSArray *usersAndContacts;
@property NSMutableArray *contacts;
@property NSArray *recentInvites;

@property NSString *country;

@property PhoneNumberFormatter *phoneNumberFormat;

@end

@implementation FZZContactDelegate

+(void)initialize{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        searchDelegate = [[FZZContactDelegate alloc] init];
        
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        
        NSNumber *addressBookAccess = [pref objectForKey:kFZZAddressBookPermission];
        
        if ((addressBookAccess != nil) && [addressBookAccess boolValue]){
            [searchDelegate getContacts];
        }
    });
}

- (instancetype)init{
    self = [super init];
    
    if (self){
        _phoneNumberFormat = [[PhoneNumberFormatter alloc] init];
    }
    
    return self;
}

+ (void)promptForAddressBook{
    [searchDelegate getContacts];
}

-(void)loadRecentInvites{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *savedInvites = [pref objectForKey:@"recentInvites"];
    
    NSMutableDictionary *update = [[NSMutableDictionary alloc] initWithCapacity:[savedInvites count]];
    
    [savedInvites enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
        NSString *phoneNumber = key;
        
        [dict setObject:phoneNumber forKey:@"pn"];
        
        NSNumber *userID = [dict objectForKey:@"uid"];
        
        if (userID){
            FZZUser *user = [FZZUser userWithUID:userID];
            
            [dict removeObjectForKey:@"uid"];
            [dict setObject:user forKey:@"user"];
        }
        
        [update setObject:dict forKey:key];
    }];
    
    // Sort by count
    NSArray *sortedValues =
    [[update allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *val1 = obj1;
        NSDictionary *val2 = obj2;
        
        NSNumber *count1 = [val1 objectForKey:@"count"];
        NSNumber *count2 = [val2 objectForKey:@"count"];
        
        return [count2 compare:count1];
    }];
    
    NSInteger numberOfItems = 10;
    
    numberOfItems = MIN(numberOfItems, [sortedValues count]);
    
    NSArray *subArray = [sortedValues subarrayWithRange:NSMakeRange(0, numberOfItems)];
    
    _recentInvites = subArray;
    
    [self doRecentsUpdate:update];
}

- (void)doRecentsUpdate:(NSDictionary *)update{
    // Sort by count
    NSArray *sortedValues =
    [[update allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *val1 = obj1;
        NSDictionary *val2 = obj2;
        
        NSNumber *count1 = [val1 objectForKey:@"count"];
        NSNumber *count2 = [val2 objectForKey:@"count"];
        
        return [count2 compare:count1];
    }];
    
    NSInteger numberOfItems = 10;
    
    numberOfItems = MIN(numberOfItems, [sortedValues count]);
    
    NSArray *subArray = [sortedValues subarrayWithRange:NSMakeRange(0, numberOfItems)];
    
    _recentInvites = subArray;
}

+(void)updateRecentInvitedUsers:(NSArray *)invitedFriends
                    andContacts:(NSArray *)invitedContacts{
    
    NSLog(@"invitedFriends: <<%@>>\n\ninvitedContacts: <<%@>>", invitedFriends, invitedContacts);
    
    int numInvitedFriends = [invitedFriends count];
    int numInvitedContacts = [invitedContacts count];
    
    // Save recents
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *savedInvites = [[pref objectForKey:@"recentInvites"] mutableCopy];
    
    NSMutableDictionary *updateInvites;
    
    int capacity = 0;
    
    NSLog(@"<<1>>");
    
    if (savedInvites){
        capacity = MIN(MIN([savedInvites count], kFZZNumRecentInvitesSaved), numInvitedFriends + numInvitedContacts);
        updateInvites = [[NSMutableDictionary alloc] initWithCapacity:capacity];
    } else {
        capacity = MIN(numInvitedContacts + numInvitedFriends, kFZZNumRecentInvitesSaved);
        updateInvites = [[NSMutableDictionary alloc] initWithCapacity:capacity];
    }
    
    NSLog(@"<<2>>");
    
    // Update recent users
    for (int i = 0; i < numInvitedFriends; ++i){
        
        NSLog(@"<<3>>");
        
        FZZUser *user = (FZZUser *)[invitedFriends objectAtIndex:i];
        NSString *phoneNumber = [user phoneNumber];
        NSNumber *userID = [user userID];
        
        NSDictionary *dict = [savedInvites objectForKey:phoneNumber];
        NSNumber *count;
        
        NSLog(@"dict: <<%@>>\n\nuser: <<%@>>", dict, user);
        
        if (dict){
            count = [dict objectForKey:@"count"];
            count = [NSNumber numberWithInteger:[count integerValue] + 1];
        } else {
            count = [NSNumber numberWithInteger:1];
        }
        
        NSDictionary *savedInfo =
        [[NSDictionary alloc] initWithObjectsAndKeys:count,  @"count",
         userID, @"uid", nil];
        
        [updateInvites setObject:savedInfo forKey:phoneNumber];
        
        [savedInvites removeObjectForKey:phoneNumber];
    }
    
    NSLog(@"<<4>>");
    
    // Update recent contacts
    for (int i = 0; i < numInvitedContacts; ++i){
        NSLog(@"<<6>>");
        
        NSDictionary *contact = [invitedContacts objectAtIndex:i];
        NSString *phoneNumber = [contact objectForKey:@"pn"];
        NSString *name = [contact objectForKey:@"name"];
        
        NSLog(@"<<5>>");
        
        NSDictionary *dict = [savedInvites objectForKey:phoneNumber];
        NSNumber *count;
        
        if (dict){
            count = [dict objectForKey:@"count"];
            count = [NSNumber numberWithInteger:[count integerValue] + 1];
        } else {
            count = [NSNumber numberWithInteger:1];
        }
        
        NSDictionary *savedInfo =
        [[NSDictionary alloc] initWithObjectsAndKeys:count, @"count",
         name,  @"name", nil];
        
        [updateInvites setObject:savedInfo forKey:phoneNumber];
        
        [savedInvites removeObjectForKey:phoneNumber];
    }
    
    NSLog(@"<<7>>");
    
    // Update unused recent values
    [savedInvites enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
        
        NSNumber *count = [dict objectForKey:@"count"];
        count = [NSNumber numberWithInteger:([count integerValue] / 2) + 1];
        NSString *phoneNumber = [dict objectForKey:@"pn"];
        
        [dict setObject:count forKey:@"count"];
        
        [updateInvites setObject:dict forKey:phoneNumber];
    }];
    
    NSLog(@"<<8>>");
    
    // Sort by count
    NSArray *sortedKeys =
    [updateInvites keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *val1 = obj1;
        NSDictionary *val2 = obj2;
        
        NSNumber *count1 = [val1 objectForKey:@"count"];
        NSNumber *count2 = [val2 objectForKey:@"count"];
        
        return [count2 compare:count1];
    }];
    
    NSLog(@"<<9>>");
    
    // Keep only the allowed amount
    sortedKeys =
    [sortedKeys subarrayWithRange:NSMakeRange(0, MIN(kFZZNumRecentInvitesSaved, sortedKeys.count))];
    
    NSDictionary *toSave = [updateInvites dictionaryWithValuesForKeys:sortedKeys];
    updateInvites = NULL;
    
    NSLog(@"<<10>>");
    
    [searchDelegate doRecentsUpdate:toSave];
    
    NSLog(@"RECENT INVITES: %@", toSave);
    
    [pref setObject:toSave forKey:@"recentInvites"];
    [pref synchronize];
}

+ (BOOL)isUserElseContactUser:(NSDictionary *)userOrContact{
    return [userOrContact objectForKey:@"user"] != nil;
}

+(void)updateFriendsAndContacts{
    [searchDelegate updateFriendsAndContacts];
}

/*
 
 TODOAndrew this is probably called too often, every time I setEvent for FZZExpandedEventCell. Reduce to "updating friends" when you get new FZZUsers from the server. Also load all users from the cache on launch.
 
 */

-(void)updateFriendsAndContacts{
    NSMutableArray *usersAndContacts;
    
    NSArray *usersEnum = [FZZUser getFriends];
    
    // Will not do anything if already have loaded contacts
    // Else attempts to get most recent address book
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSNumber *addressBookAccess = [pref objectForKey:kFZZAddressBookPermission];
    
    if ((addressBookAccess != nil) && [addressBookAccess boolValue]){
        [self getContacts];
    }
    
    NSMutableArray *users = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [usersEnum count]; ++i){
        FZZUser *user = [usersEnum objectAtIndex:i];
        
        if (user != nil){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            NSString *name = [user name];
            
            if (name != nil){
                [dict setObject:user forKey:@"user"];
                [dict setObject:name forKey:@"name"];
            
                [users addObject:dict];
            }
        }
    }
    
    NSArray *contactsEnum = [_contacts copy];
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [contactsEnum count]; ++i){
        NSDictionary *contact = [contactsEnum objectAtIndex:i];
        
        if (contact != nil){
            NSString *phoneNumber = [contact objectForKey:@"pn"];
            
            if (phoneNumber != nil){
                FZZUser *user = [FZZUser userFromPhoneNumber:phoneNumber];
                
                if (user == nil){
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                    
                    [dict setObject:contact forKey:@"contact"];
                    [dict setObject:[contact objectForKey:@"name"] forKey:@"name"];
                    
                    [contacts addObject:dict];
                }
            }
        }
    }
    
    usersAndContacts = [[users arrayByAddingObjectsFromArray:contacts] mutableCopy];
    
//    NSLog(@"All you people: %@", usersAndContacts);
    
//    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
//    
//    [usersAndContacts removeObjectsInArray:[event invitees]];
    
    [usersAndContacts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *user1 = obj1;
        NSDictionary *user2 = obj2;
        
        return [[user1 objectForKey:@"name"] caseInsensitiveCompare:[user2 objectForKey:@"name"]];
    }];
    
    _usersAndContacts = [NSArray arrayWithArray:usersAndContacts];
    
    NSLog(@"UPDATE CONTACTS:: %d", [_usersAndContacts count]);
    
//    _invitableUsersAndContacts = usersAndContacts;
//    
//    [self filterInvitables];
//    [tableView reloadData];
}

-(void)getContacts{
    @synchronized(self){
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.gotAddressBook) {
//        [self filterInvitables];
//        [tableView reloadData];
        return;
    }
        
    appDelegate.gotAddressBook = YES;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);//&err);
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted){
            NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
            
            ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, NULL, kABPersonSortByLastName);
            
//            NSLog(@"\n\nADDRESSBOOK\n\n%@\n\n", allContacts);
            NSLog(@"Retrieving contacts...");
            
            for (int i = 0; i < [allContacts count]; ++i){
                ABRecordRef person = (__bridge ABRecordRef)([allContacts objectAtIndex:i]);
                
                NSString * firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                NSString * lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
                
                NSString * nickname = (__bridge NSString *)ABRecordCopyValue(person, kABPersonNicknameProperty);
                
                NSString * organization = (__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
                
                NSString *name = @"";
                
                BOOL hasFirstName = !(firstName == NULL || [firstName isEqualToString:@""]);
                BOOL hasLastName  = !(lastName == NULL || [lastName isEqualToString:@""]);
                BOOL hasNickname  = !(nickname == NULL || [nickname isEqualToString:@""]);
                BOOL hasOrganization = !(organization == NULL || [organization isEqualToString:@""]);
                
                if (hasFirstName & hasLastName){
                    name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                } else if (hasFirstName){
                    name = firstName;
                } else if (hasNickname){
                    name = nickname;
                } else if (hasLastName){
                    name = lastName;
                } else if (hasOrganization){
                    name = organization;
                }
                
                NSString *phoneNumber = [self handlePhones:person];
                
                name = name.lowercaseString;
                
//                NSLog(@">>%@: (%@)", name, phoneNumber);
                
                if (phoneNumber != nil && ![phoneNumber isEqualToString:@""]){
                    NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
                    [contact setObject:name forKey:@"name"];
                    phoneNumber = [FZZUtilities formatPhoneNumber:phoneNumber];
                    
                    [contact setObject:phoneNumber forKey:@"pn"];
                    
                    if (![contacts containsObject:contact]){
                        [contacts addObject:contact];
                    }
                }
            }
            
            NSLog(@"Retrieved contacts.");
        } else {
            NSLog(@"Contacts access declined.");
        }
        
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        //        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"
        //                                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        _contacts = [[contacts sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
//        [self filterInvitables];
        
//        NSLog(@"Saved Contacts: %@", _contacts);
        
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        
        // Stored so users can be loaded earlier in app launch if we already were given access
        [pref setObject:[NSNumber numberWithBool:YES] forKey:kFZZAddressBookPermission];
        [pref synchronize];
        
        NSLog(@"%d contacts loaded.", [_contacts count]);
        
        [FZZContactDelegate updateFriendsAndContacts];
        [FZZContactSelectionDelegate invalidateInvitables];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FZZ_CONTACTS_SAVED
                                                            object:nil
                                                          userInfo:nil];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self searchChange];
//            [tableView reloadData];
//        });
    });
    }
}

-(NSString *)handlePhones:(ABRecordRef)person{
    ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString* phoneNumber = NULL;
    NSString* mobileLabel;
    
    int savedPriority = 0;
    
    for (int i=0; i < ABMultiValueGetCount(phones); i++) {
        //NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        //NSLog(@"%@", phone);
        int priority = 0;
        
        mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
        if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
//            NSLog(@"iphone:");
            priority = 4;
        } else if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
//            NSLog(@"mobile:");
            priority = 3;
        } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMainLabel]) {
            priority = 2;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneOtherFAXLabel]){
            priority = -1;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){
            priority = -1;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){
            priority = -1;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhonePagerLabel]){
            priority = -1;
        } else {
//            NSLog(@"other:");
            priority = 1;
        }
        
//        NSLog(@"TEMP: %@", (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i));
        
        if (priority > savedPriority){
            savedPriority = priority;
            phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
        }
    }
    
    if (phoneNumber == nil) return nil;
    
    phoneNumber = [_phoneNumberFormat strip:phoneNumber];
    
    return [NSString stringWithFormat:@"+%@", phoneNumber];
}

+ (NSArray *)usersAndContacts{
    // technically mutable
    return [searchDelegate usersAndContacts];
//    return [NSArray arrayWithArray:[searchDelegate contacts]];
}


@end
