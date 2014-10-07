//
//  FZZContactSelectionDelegate.m
//  Let's
//
//  Created by Andrew Sweet on 10/5/14.
//  Copyright (c) 2014 Off Brand. All rights reserved.
//

#import "FZZContactSelectionDelegate.h"
#import "FZZContactDelegate.h"

#import "FZZUser.h"
#import "FZZEvent.h"

NSMutableArray *instances;

@interface FZZContactSelectionDelegate ()

@property (nonatomic) NSIndexPath *eventIndexPath;

@property NSArray *invitableUsersAndContacts;

@property NSArray *filteredRecents;
@property NSArray *filteredUsersAndContacts; // Fizz Users and Contacts
@property NSMutableSet *invitedContacts;

@property NSMutableSet *selectedUsers; // FZZUsers
@property NSMutableSet *selectedContacts; // pn + name

@property (strong, nonatomic) UITextField *textField;

@property UITableView *tableView;

@property BOOL validInvitables;

@end


@implementation FZZContactSelectionDelegate

+(void)initialize{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instances = [[NSMutableArray alloc] init];
    });
}

-(id)init{
    self = [super init];
    
    if (self){
        [instances addObject:self];
        _validInvitables = NO;
        
        _selectedContacts = [[NSMutableSet alloc] init];
        _selectedUsers = [[NSMutableSet alloc] init];
    }
    
    return self;
}

-(void)dealloc{
    [instances removeObject:self];
}

-(void)filterContentForSearchText:(NSString*)searchText {
    if (!_validInvitables){
        [self filterInvitables];
    }
    
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

// TODOAndrew Sort friends alphabetically with a recent count in front
// Filter out all users who are currently invited
- (NSDictionary *)userOrContactAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"index: %d, total: %d", indexPath.row, [self numberOfInvitableOptions]);
    
    if (indexPath.row > [self numberOfInvitableOptions] || indexPath.row < 0){
        NSLog(@"failture to retrieve");
        return nil;
    }
    
    NSDictionary *dict = [_filteredUsersAndContacts objectAtIndex:indexPath.row];
    
    NSLog(@"retrieved %@", dict);
    
    return dict;
}

-(void)sendInvitations{
//    [_textField setText:[_textField placeholder]];
    [self filterContentForSearchText:@""];
    [_textField resignFirstResponder];
//    [_textField setEnabled:NO];
    
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
    
    [FZZContactDelegate updateRecentInvitedUsers:invitedUsers
                                     andContacts:invitedContacts];
    
    NSLog(@"\n\nUser Invites: %@\nPhone Invites: %@\n\n", userInvites, phoneInvites);
    
    if ([userInvites count] > 0 || [phoneInvites count] > 0){
        
        FZZEvent *event = [self event];
        
        [event socketIOInviteWithInviteList:userInvites
                          InviteContactList:phoneInvites
                             AndAcknowledge:nil];
    }
}

- (FZZEvent *)event{
    return [FZZEvent getEventAtIndexPath:_eventIndexPath];
}

- (BOOL)isContactSelected:(NSDictionary *)contact{
    return [_selectedContacts containsObject:contact];
}

- (BOOL)isUserSelected:(FZZUser *)user{
    return [_selectedUsers containsObject:user];
}

+ (BOOL)isUserElseContactUser:(NSDictionary *)userOrContact{
    return [userOrContact objectForKey:@"user"] != nil;
}

- (BOOL)userOrContactIsSelected:(NSDictionary *)userOrContact{
    if ([FZZContactSelectionDelegate isUserElseContactUser:userOrContact]){
        FZZUser *user = [userOrContact objectForKey:@"user"];
        
        return [self isUserSelected:user];
    } else {
        NSDictionary *contact = [userOrContact objectForKey:@"contact"];
        
        return [self isContactSelected:contact];
    }
}

- (void)deselectUserOrContact:(NSDictionary *)userOrContact{
    if ([FZZContactSelectionDelegate isUserElseContactUser:userOrContact]){
        FZZUser *user = [userOrContact objectForKey:@"user"];
        
        [_selectedUsers removeObject:user];
    } else {
        NSDictionary *contact = [userOrContact objectForKey:@"contact"];
        
        [_selectedContacts removeObject:contact];
    }
}

- (void)selectUserOrContact:(NSDictionary *)userOrContact{
    if ([FZZContactSelectionDelegate isUserElseContactUser:userOrContact]){
        FZZUser *user = [userOrContact objectForKey:@"user"];
        
        NSLog(@"ADDING USER: %@", user);
        
        [_selectedUsers addObject:user];
    } else {
        NSDictionary *contact = [userOrContact objectForKey:@"contact"];
        
        NSLog(@"ADDING CONTACT: %@", contact);
        
        [_selectedContacts addObject:contact];
    }
    
    NSLog(@"contacts: %@", _selectedContacts);
}

- (int)numberOfInvitableOptions{
    return [_filteredUsersAndContacts count];
}

- (void)setEventIndexPath:(NSIndexPath *)eventIndexPath{
    _eventIndexPath = eventIndexPath;
}

- (void)setTextField:(UITextField *)textField{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:_textField];
    
    _textField = textField;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_textField];
    
    [_textField setText:@""];
    [self searchChange];
}

- (void)searchChange{
    NSLog(@">>%@<<", _textField);
    
    NSString *text = [_textField text];
    
    if (!text){
        text = @"";
    }
    
    [self filterContentForSearchText:text];
    [_tableView reloadData];
}

// Remove anybody who's already invited to the event
-(void)filterInvitables{
    FZZEvent *event = [self event];
    
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
    
    NSArray *usersAndContacts = [FZZContactDelegate usersAndContacts];
    _validInvitables = YES;
    
    _invitableUsersAndContacts = [usersAndContacts filteredArrayUsingPredicate:predicate];
}

- (void)setCurrentTableView:(UITableView *)tableView{
    _tableView = tableView;
}

+ (void)invalidateInvitables{
    [instances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZContactSelectionDelegate *delegate = obj;
        
        [delegate invalidateInvitables];
    }];
}

- (void)invalidateInvitables{
    _validInvitables = NO;
}

@end
