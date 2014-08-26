//
//  FZZContactSearchDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZContactSearchDelegate.h"

#import "FZZAppDelegate.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "FZZUser.h"
#import "FZZEvent.h"

#import "PhoneNumberFormatter.h"

static FZZContactSearchDelegate *searchDelegate;

static int kFZZNumRecentInvites = 10;
static int kFZZNumRecentInvitesSaved = 20;
static NSString *kFZZAddressBookPermission = @"addressBookPermission";

static UITableView *tableView;

@interface FZZContactSearchDelegate ()

@property (nonatomic) UITextField *textField;

@property NSArray *invitableUsersAndContacts;

@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@property NSArray *filteredRecents;
@property NSArray *filteredUsersAndContacts; // Fizz Users and Contacts
@property NSMutableSet *invitedContacts;

@property NSMutableSet *selectedUsers; // FZZUsers
@property NSMutableSet *selectedContacts; // pn + name

@property NSMutableArray *contacts;
@property NSArray *recentInvites;

@property NSString *country;

@property PhoneNumberFormatter *phoneNumberFormat;

@end

@implementation FZZContactSearchDelegate

+(void)initialize{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        searchDelegate = [[FZZContactSearchDelegate alloc] init];
        
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        
        NSNumber *addressBookAccess = [pref objectForKey:kFZZAddressBookPermission];
        
        if ([addressBookAccess boolValue]){
            [searchDelegate getContacts];
        }
    });
}

+ (void)promptForAddressBook{
    [searchDelegate getContacts];
}

+ (void)setCurrentTableView:(UITableView *)currentTableView{
    tableView = currentTableView;
}

+ (void)setTextField:(UITextField *)textField;{
    NSLog(@"TEXTFIELD::: %@", textField);
    
    [searchDelegate setTextField:textField];
    [searchDelegate searchChange];
}

- (void)setTextField:(UITextField *)textField{
    _textField = textField;
}

-(void)filterContentForSearchText:(NSString*)searchText {
    
    NSLog(@"FILTERING! %@", _invitableUsersAndContacts);
    if (searchText == NULL || [searchText isEqualToString:@""]){
        NSLog(@"meh <%@>", searchText);
        
        _filteredUsersAndContacts = _invitableUsersAndContacts;
        return;
    }
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", [NSString stringWithFormat:@" %@", searchText]];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(name BEGINSWITH[cd] %@)", searchText];
    
    NSArray *predicates = [[NSArray alloc] initWithObjects:predicate, predicate2, nil];
    NSPredicate *fullPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
    _filteredUsersAndContacts = [_invitableUsersAndContacts filteredArrayUsingPredicate:fullPredicate];
    
    NSLog(@"filtered: <<%@>>", _filteredUsersAndContacts);
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
}

-(void)updateRecentInvitedUsers:(NSArray *)invitedFriends
                    andContacts:(NSArray *)invitedContacts{
    
    int numInvitedFriends = [invitedFriends count];
    int numInvitedContacts = [invitedContacts count];
    
    // Save recents
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *savedInvites = [[pref objectForKey:@"recentInvites"] mutableCopy];
    
    NSMutableDictionary *updateInvites;
    
    int capacity = 0;
    
    if (savedInvites){
        capacity = MIN(MIN([savedInvites count], kFZZNumRecentInvitesSaved), numInvitedFriends + numInvitedContacts);
        updateInvites = [[NSMutableDictionary alloc] initWithCapacity:capacity];
    } else {
        capacity = MIN(numInvitedContacts + numInvitedFriends, kFZZNumRecentInvitesSaved);
        updateInvites = [[NSMutableDictionary alloc] initWithCapacity:capacity];
    }
    
    // Update recent users
    for (int i = 0; i < numInvitedFriends; ++i){
        FZZUser *user = (FZZUser *)[invitedFriends objectAtIndex:i];
        NSString *phoneNumber = [user phoneNumber];
        NSNumber *userID = [user userID];
        
        NSDictionary *dict = [savedInvites objectForKey:phoneNumber];
        NSNumber *count;
        
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
    
    // Update recent contacts
    for (int i = 0; i < numInvitedContacts; ++i){
        NSDictionary *contact = [invitedContacts objectAtIndex:i];
        NSString *phoneNumber = [contact objectForKey:@"pn"];
        NSString *name = [contact objectForKey:@"name"];
        
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
    
    // Update unused recent values
    [savedInvites enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableDictionary *dict = [(NSDictionary *)obj mutableCopy];
        
        NSNumber *count = [dict objectForKey:@"count"];
        count = [NSNumber numberWithInteger:([count integerValue] / 2) + 1];
        NSString *phoneNumber = [dict objectForKey:@"pn"];
        
        [dict setObject:count forKey:@"count"];
        
        [updateInvites setObject:dict forKey:phoneNumber];
    }];
    
    // Sort by count
    NSArray *sortedKeys =
    [updateInvites keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *val1 = obj1;
        NSDictionary *val2 = obj2;
        
        NSNumber *count1 = [val1 objectForKey:@"count"];
        NSNumber *count2 = [val2 objectForKey:@"count"];
        
        return [count2 compare:count1];
    }];
    
    // Keep only the allowed amount
    sortedKeys =
    [sortedKeys subarrayWithRange:NSMakeRange(0, MIN(kFZZNumRecentInvitesSaved, sortedKeys.count))];
    
    NSDictionary *toSave = [updateInvites dictionaryWithValuesForKeys:sortedKeys];
    updateInvites = NULL;
    
    [pref setObject:toSave forKey:@"recentInvites"];
    [pref synchronize];
}

+ (NSDictionary *)userOrContactAtIndexPath:(NSIndexPath *)indexPath{
    return [searchDelegate userOrContactAtIndexPath:indexPath];
}

// TODOAndrew Sort friends alphabetically with a recent count in front
// Filter out all users who are currently invited
- (NSDictionary *)userOrContactAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > [self lengthOfOptions] || indexPath.row < 0){
        return nil;
    }
    
    NSDictionary *dict = [_filteredUsersAndContacts objectAtIndex:indexPath.row];
    
    return dict;
}

-(void)sendInvitations{
    [_textField setText:[_textField placeholder]];
    [self filterContentForSearchText:@""];
    [_textField resignFirstResponder];
    [_textField setEnabled:NO];
    
    NSMutableArray *userInvites = [[NSMutableArray alloc] init];
    NSMutableArray *phoneInvites = [[NSMutableArray alloc] init];
    
    NSArray *invitedUsers  = [_selectedUsers allObjects];
    NSArray *invitedContacts = [_selectedContacts allObjects];
    
    [_selectedContacts removeAllObjects];
    [_selectedUsers removeAllObjects];
    
    [_invitedContacts addObjectsFromArray:invitedContacts];
    
    int numInvitedUsers = [invitedUsers count];
    
    for (int i = 0; i < numInvitedUsers; ++i){
        FZZUser *user = [invitedUsers objectAtIndex:i];
        
        [userInvites addObject:user];
    }
    
    int numInvitedContacts = [invitedContacts count];
    
    for (int i = 0; i < numInvitedContacts; ++i){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        NSDictionary *contact = [invitedContacts objectAtIndex:i];
        [dict setObject:[contact objectForKey:@"pn"] forKey:@"pn"];
        [dict setObject:[contact objectForKey:@"name"] forKey:@"name"];
        
        [phoneInvites addObject:dict];
    }
    
    [self updateRecentInvitedUsers:invitedUsers
                       andContacts:invitedContacts];
    
    NSLog(@"\n\nUser Invites: %@\nPhone Invites: %@\n\n", userInvites, phoneInvites);
    
    if ([userInvites count] > 0 || [phoneInvites count] > 0){
        
        FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
        
        [event socketIOInviteWithInviteList:userInvites
                          InviteContactList:phoneInvites
                             AndAcknowledge:nil];
    }
}

+ (BOOL)isContactSelected:(NSDictionary *)contact{
    return [[searchDelegate selectedContacts] containsObject:contact];
}

+ (BOOL)isUserSelected:(FZZUser *)user{
    return [[searchDelegate selectedUsers] containsObject:user];
}

+ (BOOL)isUserOrContactUser:(NSDictionary *)userOrContact{
    return [userOrContact objectForKey:@"user"] != nil;
}

+ (BOOL)userOrContactIsSelected:(NSDictionary *)userOrContact{
    if ([FZZContactSearchDelegate isUserOrContactUser:userOrContact]){
        FZZUser *user = [userOrContact objectForKey:@"user"];
        
        return [FZZContactSearchDelegate isUserSelected:user];
    } else {
        NSDictionary *contact = [userOrContact objectForKey:@"contact"];
        
        return [FZZContactSearchDelegate isContactSelected:contact];
    }
}

+ (void)deselectUserOrContact:(NSDictionary *)userOrContact{
    if ([FZZContactSearchDelegate isUserOrContactUser:userOrContact]){
        FZZUser *user = [userOrContact objectForKey:@"user"];
        
        [[searchDelegate selectedUsers] removeObject:user];
    } else {
        NSDictionary *contact = [userOrContact objectForKey:@"contact"];
        
        [[searchDelegate selectedContacts] removeObject:contact];
    }
}

+ (void)selectUserOrContact:(NSDictionary *)userOrContact{
    if ([FZZContactSearchDelegate isUserOrContactUser:userOrContact]){
        FZZUser *user = [userOrContact objectForKey:@"user"];
        
        [[searchDelegate selectedUsers] addObject:user];
    } else {
        NSDictionary *contact = [userOrContact objectForKey:@"contact"];
        
        [[searchDelegate selectedContacts] addObject:contact];
    }
}

+ (int)numberOfInvitableOptions{
    return [searchDelegate lengthOfOptions];
}

- (int)lengthOfOptions{
    return [_filteredUsersAndContacts count];
}

+ (void)setEventIndexPath:(NSIndexPath *)eventIndexPath{
    [searchDelegate setEventIndexPath:eventIndexPath];
}

- (void)setEventIndexPath:(NSIndexPath *)eventIndexPath{
    _eventIndexPath = eventIndexPath;
}

+(void)updateFriendsAndContacts{
    [searchDelegate updateFriendsAndContacts];
}

/*
 
 TODOAndrew this is probably called too often, every time I setEvent for FZZExpandedEventCell. Reduce to "updating friends" when you get new FZZUsers from the server. Also load all users from the cache on launch.
 
 */
-(void)updateFriendsAndContacts{
    NSMutableArray *usersAndContacts;
    
    NSMutableArray *users = [[FZZUser getFriends] mutableCopy];
    NSMutableArray *contacts = [_contacts mutableCopy];
    
    NSArray *usersEnum = [users copy];
    [usersEnum enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        FZZUser *user = obj;
        
        [dict setObject:user forKey:@"user"];
        [dict setObject:[user name] forKey:@"name"];
        
        [users setObject:dict atIndexedSubscript:idx];
    }];
    
    NSArray *contactsEnum = [contacts copy];
    [contactsEnum enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        NSDictionary *contact = obj;
        
        [dict setObject:contact forKey:@"contact"];
        [dict setObject:[contact objectForKey:@"name"] forKey:@"name"];
        
        [contacts setObject:dict atIndexedSubscript:idx];
    }];
    
    usersAndContacts = [[users arrayByAddingObjectsFromArray:contacts] mutableCopy];
    
    NSLog(@"All you people: %@", usersAndContacts);
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    [usersAndContacts removeObjectsInArray:[event invitees]];
    
    [usersAndContacts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *user1 = obj1;
        NSDictionary *user2 = obj2;
        
        return [[user1 objectForKey:@"name"] caseInsensitiveCompare:[user2 objectForKey:@"name"]];
    }];
    
    _invitableUsersAndContacts = usersAndContacts;
    [self filterInvitables];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [tableView reloadData];
    });
    
    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

+ (void)searchFieldTextChanged{
    [searchDelegate searchChange];
}

- (void)searchChange{
    NSLog(@">>%@<<", _textField);
    
    [self filterContentForSearchText:[_textField text]];
    [tableView reloadData];
}

-(void)getContacts{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    _contacts = [pref objectForKey:@"contacts"];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.gotAddressBook) {
        [self filterInvitables];
        [tableView reloadData];
        return;
    }
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);//&err);
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted){
            NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
            
            ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, NULL, kABPersonSortByLastName);
            
            NSLog(@"\n\nADDRESSBOOK\n\n%@\n\n", allContacts);
            
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
                
                //                NSLog(@"%@: (%@)", name, phoneNumber);
                
                if (phoneNumber != NULL && ![phoneNumber isEqualToString:@""]){
                    NSMutableDictionary *contact = [[NSMutableDictionary alloc] init];
                    [contact setObject:name forKey:@"name"];
                    [contact setObject:phoneNumber forKey:@"pn"];
                    
                    if (![contacts containsObject:contact]){
                        [contacts addObject:contact];
                    }
                }
            }
        }
        
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        //        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"
        //                                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        _contacts = [[contacts sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
        [self filterInvitables];
        
        //        [_contacts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        //            NSDictionary *d1 = obj1;
        //            NSDictionary *d2 = obj2;
        //
        //            NSString *name1 = [d1 objectForKey:@"name"];
        //            NSString *name2 = [d1 objectForKey:@"name"];
        //
        //            if ([name1 isEqualToString:@""]){
        //                name1 = [d1 objectForKey:@"pn"];
        //            }
        ////            } else {
        ////                NSArray *terms = [name1 componentsSeparatedByString: @" "];
        ////                name1 = [terms lastObject];
        ////            }
        //
        //            if ([name2 isEqualToString:@""]){
        //                name2 = [d2 objectForKey:@"pn"];
        //            }
        ////            } else {
        ////                NSArray *terms = [name2 componentsSeparatedByString: @" "];
        ////                name2 = [terms lastObject];
        ////            }
        //
        //            return [name1 compare:name2];
        //        }];
        
        [pref setObject:_contacts forKey:@"contacts"];
        [pref synchronize];
        
        appDelegate.gotAddressBook = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
            [pref setObject:[NSNumber numberWithBool:YES] forKey:kFZZAddressBookPermission];
            [pref synchronize];
            
            [self searchChange];
            [tableView reloadData];
        });
    });
}

// Remove anybody who's already invited to the event
-(void)filterInvitables{
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSDictionary *dict = evaluatedObject;
        
        FZZUser *user = [dict objectForKey:@"user"];
        
        if (user){
            return ![event isUserInvited:user];
        } else {
            NSDictionary *contact = [dict objectForKey:@"contact"];
            NSString *phoneNumber = [contact objectForKey:@"pn"];
            
            FZZUser *user = [FZZUser userFromPhoneNumber:phoneNumber];
            
            if (user){
                return ![event isUserInvited:user];
            } else {
                return YES;
            }
        }
    }];
    
    _invitableUsersAndContacts = [_invitableUsersAndContacts filteredArrayUsingPredicate:predicate];
}

-(NSString *)handlePhones:(ABRecordRef)person{
    ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSString* phoneNumber = NULL;
    NSString* mobileLabel;
    
    int savedPriority = -1;
    
    for (int i=0; i < ABMultiValueGetCount(phones); i++) {
        //NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phones, i);
        //NSLog(@"%@", phone);
        int priority = -1;
        
        mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
        if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
            NSLog(@"iphone:");
            priority = 4;
        } else if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
            NSLog(@"mobile:");
            priority = 3;
        } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMainLabel]) {
            priority = 2;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneOtherFAXLabel]){
            priority = -2;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneWorkFAXLabel]){
            priority = -2;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhoneHomeFAXLabel]){
            priority = -2;
        } else if ([mobileLabel isEqualToString:(NSString *)kABPersonPhonePagerLabel]){
            priority = -2;
        } else {
            NSLog(@"other:");
            priority = 1;
        }
        
        if (priority > savedPriority){
            savedPriority = priority;
            phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
        }
    }
    
    if (phoneNumber == NULL) return NULL;
    
    phoneNumber = [_phoneNumberFormat strip:phoneNumber];
    
    return [NSString stringWithFormat:@"+%@", phoneNumber];
}


@end
