//
//  FZZContactSelectionDelegate.m
//  Let's
//
//  Created by Andrew Sweet on 10/5/14.
//  Copyright (c) 2014 Off Brand. All rights reserved.
//

#import "FZZContactSelectionDelegate.h"
#import "FZZContactDelegate.h"

#import "FZZSocketIODelegate.h"

#import "FZZUser.h"
#import "FZZEvent.h"

NSMutableArray *instances;

@interface FZZContactSelectionDelegate ()

@property (nonatomic) NSIndexPath *eventIndexPath;

@property NSArray *invitableUsersAndContacts;

@property NSArray *filteredRecents;
@property NSArray *filteredUsersAndContacts; // Fizz Users and Contacts

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
        
        NSString *eventName = FZZ_INCOMING_NEW_INVITEES;
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(recievedNewInvitees)
         name:eventName
         object:nil];
    }
    
    return self;
}

-(void)dealloc{
    [instances removeObject:self];
}

-(void)recievedNewInvitees{
    [self invalidateInvitables];
    [_textField setText:@""];
    [self filterContentForSearchText:@""];
}

-(void)filterContentForSearchText:(NSString*)searchText {
    if (!_validInvitables){
        [self filterInvitables];
    }
    
//    NSLog(@"FILTERING! %@", _invitableUsersAndContacts);
    if (searchText == NULL || [searchText isEqualToString:@""]){
//        NSLog(@"meh <%@>", searchText);
        
        _filteredUsersAndContacts = _invitableUsersAndContacts;
        return;
    }
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", [NSString stringWithFormat:@" %@", searchText]];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(name BEGINSWITH[cd] %@)", searchText];
    
    NSArray *predicates = [[NSArray alloc] initWithObjects:predicate, predicate2, nil];
    NSPredicate *fullPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
    _filteredUsersAndContacts = [_invitableUsersAndContacts filteredArrayUsingPredicate:fullPredicate];
}

// TODOAndrew Sort friends alphabetically with a recent count in front
// Filter out all users who are currently invited
- (NSDictionary *)userOrContactAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"index: %d, total: %d", indexPath.row, [self numberOfInvitableOptions]);
    
    if (indexPath.row > [self numberOfInvitableOptions] || indexPath.row < 0){
        NSLog(@"failure to retrieve");
        return nil;
    }
    
    NSDictionary *dict = [_filteredUsersAndContacts objectAtIndex:indexPath.row];
    
//    NSLog(@"retrieved %@", dict);
    
    return dict;
}

-(void)sendInvitations{
    NSLog(@"SENDING INVITATIONS");
    
    if (_eventIndexPath == nil){
        return;
    }
    
    FZZEvent *event = [self event];
    
    NSString *notificationName = [NSString stringWithFormat:@"SendInvitations%@", _eventIndexPath];

    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil];
    
//    [_textField setText:[_textField placeholder]];
    [_textField setText:@""];
    [_textField resignFirstResponder];
//    [_textField setEnabled:NO];
    
    NSMutableArray *phoneInvites = [[NSMutableArray alloc] init];
    
    NSArray *invitedUsers  = [[event selectedUsers] allObjects];
    NSArray *invitedContacts = [[event selectedContacts] allObjects];
    
    [event clearSelectedUsersAndContacts];
    
//    [_invitedContacts addObjectsFromArray:invitedContacts];
    
    int numInvitedUsers = [invitedUsers count];
    
    for (int i = 0; i < numInvitedUsers; ++i){
        FZZUser *user = [invitedUsers objectAtIndex:i];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[user phoneNumber] forKey:@"pn"];
        [dict setObject:[user name] forKey:@"name"];
        
        [phoneInvites addObject:dict];
    }
    
    int numInvitedContacts = [invitedContacts count];
    
    for (int i = 0; i < numInvitedContacts; ++i){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        NSDictionary *contact = [invitedContacts objectAtIndex:i];
        [dict setObject:[contact objectForKey:@"pn"] forKey:@"pn"];
        [dict setObject:[contact objectForKey:@"name"] forKey:@"name"];
        
        [phoneInvites addObject:dict];
    }
    
    /*[FZZContactDelegate updateRecentInvitedUsers:invitedUsers
                                     andContacts:invitedContacts];*/
    
    NSLog(@"\n\nPhone Invites: %@\n\n", phoneInvites);
    
    if ([phoneInvites count] > 0){
        [event socketIOInviteWithInviteList:phoneInvites
                             AndAcknowledge:nil];
    }
}

- (FZZEvent *)event{
    return [FZZEvent getEventAtIndexPath:_eventIndexPath];
}

- (int)numberOfInvitableOptions{
    return [_filteredUsersAndContacts count];
}

- (void)setEventIndexPath:(NSIndexPath *)eventIndexPath{
    _eventIndexPath = eventIndexPath;
    [self searchChange];
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
    
//    NSLog(@"event: %@\n\ninvitees: %@", event, [event invitees]);
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSDictionary *dict = evaluatedObject;
        
        FZZUser *user = [dict objectForKey:@"user"];
        
        if (user){
//            NSLog(@"USER: %@ <%@>", user, [user phoneNumber]);
            
            return ![event isUserInvited:user];
        } else {
            NSDictionary *contact = [dict objectForKey:@"contact"];
            NSString *phoneNumber = [contact objectForKey:@"pn"];
            
//            NSLog(@"%@", contact);
            
            FZZUser *user = [FZZUser userFromPhoneNumber:phoneNumber];
            
            if (user){
                return ![event isUserInvited:user];
            } else {
//                NSLog(@"NO USER EXISTS");
                
                return YES;
            }
        }
    }];
    
    NSArray *usersAndContacts = [FZZContactDelegate usersAndContacts];
    
//    NSLog(@"USERS AND CONTACTS: %@", usersAndContacts);
    
//    NSLog(@"Filter away!");
    
    _invitableUsersAndContacts = [usersAndContacts filteredArrayUsingPredicate:predicate];
    
    _validInvitables = YES;
    
//    NSLog(@"FILTERED DOWN TO: %@", _invitableUsersAndContacts);
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
