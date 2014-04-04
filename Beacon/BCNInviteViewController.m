//
//  BCNInviteViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNInviteViewController.h"
#import "BCNPhoneInputCell.h"
#import "BCNInviteCell.h"
#import "BCNUser.h"
#import "BCNEvent.h"
#import "BCNEventStreamViewController.h"
#import "BCNAppDelegate.h"
#import "BCNNewEventCell.h"
#import "BCNBubbleViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "BCNNavButton.h"

#import "BCNInviteGuestButton.h"

#import "PhoneNumberFormatter.h"

static NSMutableArray *instances;

@interface BCNInviteViewController ()

@property NSArray *invitableFriends;

@property NSArray *filteredFriends; // Fizz Friends
@property NSArray *filteredContacts;

@property NSMutableSet *selectedFriends;
@property NSMutableSet *selectedContacts;

@property BOOL needsUpdateFriends;

@property NSMutableArray *contacts;

@property NSString *country;

@property PhoneNumberFormatter *phoneNumberFormat;

@end

@implementation BCNInviteViewController

+ (void)setupClass{
    instances = [[NSMutableArray alloc] init];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _needsUpdateFriends = NO;
        _phoneNumberFormat = [[PhoneNumberFormatter alloc] init];
        _country = @"us";
        
        self.tableView.separatorColor = [UIColor clearColor];
        
        UINib *inviteNib = [UINib nibWithNibName:@"BCNInviteCell" bundle:nil];
        [[self tableView] registerNib:inviteNib forCellReuseIdentifier:@"InviteCell"];
        
        UINib *phoneNib = [UINib nibWithNibName:@"BCNPhoneInputCell" bundle:nil];
        [[self tableView] registerNib:phoneNib forCellReuseIdentifier:@"PhoneInputCell"];
        
        _selectedFriends = [[NSMutableSet alloc] init];
        _selectedContacts = [[NSMutableSet alloc] init];
    }
    
    [instances addObject:self];
    
    return self;
}

- (void)setupInterface{
    [self setupSeats];
    [self setupInvite];
}

- (void)updateSeatUI{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate.bvc updateBubblesForEvent:_event Animated:YES];
}

// You can always add a seat
- (void)addSeat{
    [_event addSeat];
    [self updateSeatUI];
}

// Attempt to subtract an empty seat. If no empty seats, no subtraction
- (void)removeSeat{
    if ([_event removeSeat]){
        [self updateSeatUI];
    }
}

- (void)setupSeats{
    // Get TextView positions
    float textX = _textView.frame.origin.x;
    float textXEnd = _textView.frame.size.width + textX;
    
    float textY = _textView.frame.origin.y;
//    float textYEnd = textY + _textView.frame.size.height;
    
    float midX = (textX + textXEnd)/2;
    
    // AddSeatButton
    float addSeatWidth = 44;
    float addSeatX = midX + 110;
    float addSeatY = textY - 160;
    float addSeatHeight = addSeatWidth;
    CGRect addSeatFrame = CGRectMake(addSeatX, addSeatY, addSeatWidth, addSeatHeight);
    
    _addSeatButton = [BCNInviteGuestButton buttonWithType:UIButtonTypeSystem];//UIButtonTypeContactAdd];
    
    [_addSeatButton setFrame:addSeatFrame];
    
    //[_inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    
    [_addSeatButton addTarget:self
                      action:@selector(addSeat)
            forControlEvents:UIControlEventTouchUpInside];
    
//    
//    _addSeatButton = [UIButton buttonWithType:UIButtonTypeSystem];//UIButtonTypeContactAdd];
//    _removeSeatButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    
//    [_addSeatButton setFrame:seatsPlusFrame];
//    [_removeSeatButton setFrame:seatsMinusFrame];
//    
//    [_addSeatButton setTitle:@"ADD" forState:UIControlStateNormal];
//    [_removeSeatButton setTitle:@"DEL" forState:UIControlStateNormal];
//    
//    [_addSeatButton addTarget:self action:@selector(addSeat)
//             forControlEvents:UIControlEventTouchUpInside];
//    
//    [_removeSeatButton addTarget:self action:@selector(removeSeat)
//             forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupInvite{
    // Get TextView positions
    float textX = _textView.frame.origin.x;
    float textXEnd = _textView.frame.size.width + textX;
    
    float textY = _textView.frame.origin.y;
    float textYEnd = textY + _textView.frame.size.height;
    
    float midX = (textX + textXEnd)/2;
    
    // InviteButton
    float inviteWidth = 44;
    float inviteX = midX + 110;
    float inviteY = textYEnd + 60;
    float inviteHeight = inviteWidth;
    CGRect inviteFrame = CGRectMake(inviteX, inviteY, inviteWidth, inviteHeight);
    
    _inviteButton = [BCNInviteGuestButton buttonWithType:UIButtonTypeSystem];//UIButtonTypeContactAdd];
    
    [_inviteButton setFrame:inviteFrame];
    
    //[_inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    
    [_inviteButton addTarget:self
                      action:@selector(inviteButtonPress)
            forControlEvents:UIControlEventTouchUpInside];
}

-(void)takeBubbleView{
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [cell addSubview:(UIView *)appDelegate.bvc.bubbleView];
}

-(void)inviteButtonPress{
    [self takeBubbleView];
    
    [_eventCell enterInviteMode];
    
    [self getContacts];
    [self filterInvitables];
}

-(void)filterContentForSearchText:(NSString*)searchText {
    if (searchText == NULL || [searchText isEqualToString:@""]){
        _filteredFriends = _invitableFriends;//[[_invitableFriends
        _filteredContacts = _contacts;
        return;
    }
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", searchText];
    
    NSPredicate *dictionaryPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [(NSString *)[(NSDictionary *)evaluatedObject objectForKey:@"name"] hasPrefix:searchText];
    }];
    
    _filteredFriends = [_invitableFriends filteredArrayUsingPredicate:predicate];
    _filteredContacts = [_contacts filteredArrayUsingPredicate:dictionaryPredicate];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) return NO;
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// Need to override in order to avoid awkward forced scroll on textField selection
- (void)viewWillAppear:(BOOL)animated{
    if (_needsUpdateFriends){
        [self updateFriends];
    }
    
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

-(void)sendInvitations{
//    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [_eventCell exitInviteMode];
    
//    NSArray *inviteRefs = [_selected allObjects];
    NSMutableArray *userInvites = [[NSMutableArray alloc] init];
    NSMutableArray *phoneInvites = [[NSMutableArray alloc] init];
    
    int numInvitableFriends = [_invitableFriends count];
    
    NSArray *invitedFriends  = [_selectedFriends allObjects];
    NSArray *invitedContacts = [_selectedContacts allObjects];
    
    int numInvitedFriends = [invitedFriends count];
    
    for (int i = 0; i < numInvitedFriends; ++i){
        BCNUser *friend = [invitedFriends objectAtIndex:i];
        
        [userInvites addObject:friend];
    }
    
    int numInvitedContacts = [invitedContacts count];
    
    for (int i = 0; i < numInvitedContacts; ++i){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        NSDictionary *contact = [invitedContacts objectAtIndex:i];
        [dict setObject:[contact objectForKey:@"pn"] forKey:@"pn"];
        [dict setObject:[contact objectForKey:@"name"] forKey:@"name"];
        
        [phoneInvites addObject:dict];
    }
    
//    for (int i = 0; i < [inviteRefs count]; ++i){
//        int index = [self lengthOfOptions] -
//                    [(NSNumber *)[inviteRefs objectAtIndex:i] integerValue];
//        
//        if (index < numInvitableFriends){
//            BCNUser *friend = [_invitableFriends objectAtIndex:index];
//            [userInvites addObject:friend];
//        } else {
//            index -= numInvitableFriends;
//            NSDictionary *contact = [_contacts objectAtIndex:index];
//            NSString *phoneNumber = [contact objectForKey:@"pn"];
//            
//            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//            [dict setObject:phoneNumber forKey:@"pn"];
//            [dict setObject:[contact objectForKey:@"name"] forKey:@"name"];
//            
//            [phoneInvites addObject:dict];
//        }
//    }
    
    NSLog(@"\n\n%@\n%@\n\n", userInvites, phoneInvites);
    
    if ([userInvites count] > 0 || [phoneInvites count] > 0){
        [_event socketIOInviteWithInviteList:userInvites
                             InviteContactList:phoneInvites
                              AndAcknowledge:nil];
    }
}

- (int)lengthOfOptions{
    return [_filteredFriends count] + [_filteredContacts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){ // Title cell
        return 1;
    }
    
    if (section == 1) { // "+ Add By Phone Number" cell
        return 1;
    }
    
    // Return the number of rows in the section.
    return [self lengthOfOptions];
}

-(void)dealloc {
    [instances removeObject:self];
}

+(void)updateFriends{
    for (int i = 0; i < [instances count]; ++i){
        BCNInviteViewController *ivc = (BCNInviteViewController *)[instances objectAtIndex:i];
        [ivc setNeedsUpdateFriends];
    }
}

-(void)setNeedsUpdateFriends{
    _needsUpdateFriends = YES;
}

-(void)updateFriends{
    _needsUpdateFriends = NO;
    
    NSMutableArray *friends = [[BCNUser getFriends] mutableCopy];
    [friends removeObjectsInArray:[_event invitees]];
    
    NSLog(@"PENISS\n\n%@\n\n%@", _event, [_event invitees]);
    
    NSLog(@"\n\n%@", friends);
    
    _invitableFriends = friends;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
//    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setTopCellSubviews:(UITableViewCell *)cell{
    [cell addSubview:_textView];
    [cell addSubview:_addSeatButton];
    [cell addSubview:_inviteButton];
}

- (void)searchChange{
    [self filterContentForSearchText:_searchTextField.text];
    int lastSection = [self.tableView numberOfSections] - 1;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:lastSection] withRowAnimation:UITableViewRowAnimationNone];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){ // BIG top cell
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // Configure the cell...
        
        [self setTopCellSubviews:cell];
        
        return cell;
    }
    
    if (indexPath.section == 1){
        // New Phone Number Cell
        
        static NSString *CellIdentifier = @"PhoneInputCell";
        BCNPhoneInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BCNPhoneInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        
        _searchTextField = cell.textField;
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(searchStartEdit)
         name:UITextFieldTextDidBeginEditingNotification
         object:_searchTextField];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(searchStopEdit)
         name:UITextFieldTextDidEndEditingNotification
         object:_searchTextField];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(searchChange)
         name:UITextFieldTextDidChangeNotification
         object:_searchTextField];
        
        [cell.textField setDelegate:self];
        
        return cell;
    }
    
    // All other cells
    
    static NSString *CellIdentifier = @"InviteCell";
    BCNInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BCNInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
//    NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
    
    BOOL selected;
    
    int numInvitableFriends = [_filteredFriends count];
    
    // Configure the cell...
    if (indexPath.row < numInvitableFriends) {
        int index = indexPath.row;
        
        BCNUser *friend = [_filteredFriends objectAtIndex:index];
        
        [cell.label setText:[friend name]];
        
        selected = [_selectedFriends containsObject:friend];
        
        [cell setHasFriend:YES];
    } else {
        int index = indexPath.row - numInvitableFriends;
        
        NSDictionary *contact = [_filteredContacts objectAtIndex:index];
        
        NSString *name = [contact objectForKey:@"name"];
        
        if ([name isEqualToString:@""]){
            [cell.label setText:[contact objectForKey:@"pn"]];
        } else {
            [cell.label setText:name];
        }
        
        selected = [_selectedContacts containsObject:contact];
        
        [cell setHasFriend:NO];
    }
    
    [cell setIsSelected:selected];
    
    return cell;
}

- (BOOL)isValidUSPhoneNumber:(NSString *)phoneNumber{
    
    // Not Using Strip incase strip decides to keep other characters
    NSString *digits = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    // require area code
    if ([digits length] < 10){
        NSLog(@"TOO SHORT");
        return NO;
    }
    
    NSString *testExtra = [NSString stringWithFormat:@"%@5", digits];
    
    NSString *formattedOneExtra = [_phoneNumberFormat format:testExtra
                                                  withLocale:_country];
    
    // It was unformatted, and thus unmatched as a correct number
    if ([digits length] == [phoneNumber length]){
        NSLog(@"NOT FORMATTED");
        return NO;
    }
    
    // Adding a digit still counted as a match for a valid substring
    // Meaning we're still missing digits until we have a valid match
    if ([testExtra length] != [formattedOneExtra length]){
        NSLog(@"PROPER FORMAT BUT NOT COMPLETE");
        return NO;
    }
    
    NSLog(@"VALID");
    
    return YES;
}

-(void)searchStartEdit{
//    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 190);
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.esvc.navIcon setIsEditingText:YES];
    [appDelegate.esvc setActiveTextField:_searchTextField];
    
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:0 inSection:1];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)searchStopEdit{
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.esvc.navIcon setIsEditingText:NO];
    [appDelegate.esvc setActiveTextField:NULL];
//    self.tableView.frame = [UIScreen mainScreen].bounds;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSNumber *)getSelectedReferenceFromIndexPath:(NSIndexPath *)indexPath{
    int numFriends = [_filteredFriends count];
    
    int index = indexPath.row;
    
    if (indexPath.row >= numFriends){
        index -= numFriends;
    }
    
    return [NSNumber numberWithInt:index];
    
//    return [NSNumber numberWithInt:[self lengthOfOptions] - indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BCNInviteCell *cell = (BCNInviteCell* )[tableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.section != 0)
    {
//        NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
        NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
        
        if([cell isSelected])
        {
            if ([cell hasFriend]){
                BCNUser *friend = [_filteredFriends objectAtIndex:[cellReference integerValue]];
                [_selectedFriends removeObject:friend];
                
            } else {
                NSDictionary *contact = [_filteredContacts objectAtIndex:[cellReference integerValue]];
                [_selectedContacts removeObject:contact];
            }
            
            [cell setIsSelected:NO];
//            [_selected removeObject:cellReference];
//            [cell setIsSelected:NO];
        }
        else
        {
            if ([cell hasFriend]){
                BCNUser *friend = [_filteredFriends objectAtIndex:[cellReference integerValue]];
                [_selectedFriends addObject:friend];
                
            } else {
                NSDictionary *contact = [_filteredContacts objectAtIndex:[cellReference integerValue]];
                [_selectedContacts addObject:contact];
            }
            
            [cell setIsSelected:YES];
            
//            [_selected addObject:cellReference];
//            [cell setIsSelected:YES];
        }
    } else {
        if (_canBeSelected){
            [cell setSelected:NO];
            [cell setHighlighted:NO];
            [_eventCell enterChatMode];
        }
    }
}

//-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0){
        return [UIScreen mainScreen].bounds.size.height;
    }
    
    return 65;
}

-(void)getContacts{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    _contacts = [pref objectForKey:@"contacts"];
    [self.tableView reloadData];
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.gotAddressBook) return;
    
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
        
        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
        _contacts = [[contacts sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        
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
            [self.tableView reloadData];
        });
    });
}

// Remove anybody who's already invited to the event
-(void)filterInvitables{
//    @property NSArray *invitableFriends;
//    @property NSMutableArray *phoneNumbers;
//    
//    @property NSMutableArray *contacts;
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
            priority = 5;
        } else if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
            NSLog(@"mobile:");
            priority = 4;
        } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneMainLabel]) {
            NSLog(@"main:");
            priority = 3;
        } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneHomeFAXLabel]) {
            NSLog(@"home:");
            priority = 2;
        } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneWorkFAXLabel]) {
            NSLog(@"work:");
            priority = 1;
        } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneOtherFAXLabel]) {
            NSLog(@"other:");
            priority = 0;
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


/* Use these methods to handle persistent bubbles across all interfaces */
/*-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
 
 }
 
 -(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
 
 }*/




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
