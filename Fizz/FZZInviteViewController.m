//
//  FZZInviteViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteViewController.h"
#import "FZZPhoneInputCell.h"
#import "FZZInviteCell.h"
#import "FZZUser.h"
#import "FZZEvent.h"
#import "FZZEventsViewController.h"
#import "FZZAppDelegate.h"
#import "FZZExpandedEventCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FZZNavIcon.h"
#import <CoreData/CoreData.h>

#import "FZZInviteGuestButton.h"

#import "PhoneNumberFormatter.h"

/*
 
 While horribly named, this cell was repurposed from inputting a phone number to add a friend by cell phone number to just a search field for finding your desired friends among the list.
 
 [TODOAndrew (5/13/14)] DO NOT DELETE JUST YET. This cell is currently unused. Due to the server not being online, I'm not sure if its because A) I'm using some other search input. B) We removed search/cell phone input functionality. If it's determined that the app in its current state supports searching for friends AND we decide that we don't want users to be able to add people to an event/to the app via phone number, then this can be deleted. Otherwise, this have a lot of useful code for adding people by phone number, or could easily be repurposed and used as a search field for friends.
 
 */

static NSMutableArray *instances;

static int kFZZNumRecentInvites = 30;

@interface FZZInviteViewController ()

@property NSArray *invitableFriends;
@property NSArray *recentInvites;

@property NSArray *filteredRecents;
@property NSArray *filteredFriends; // Fizz Friends
@property NSArray *filteredContacts;
@property NSMutableSet *invitedContacts;

@property NSMutableSet *selectedFriends;
@property NSMutableSet *selectedContacts;

@property BOOL needsUpdateFriends;

@property NSMutableArray *contacts;

@property NSString *country;

@property PhoneNumberFormatter *phoneNumberFormat;

@end

@implementation FZZInviteViewController

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
        
        _invitedContacts = [[NSMutableSet alloc] init];
        
        [self setupKeyboard];
//        [self setupSearchField];
        
        UINib *inviteNib = [UINib nibWithNibName:@"FZZInviteCell" bundle:nil];
        [[self tableView] registerNib:inviteNib forCellReuseIdentifier:@"InviteCell"];
        
        UINib *phoneNib = [UINib nibWithNibName:@"FZZPhoneInputCell" bundle:nil];
        [[self tableView] registerNib:phoneNib forCellReuseIdentifier:@"PhoneInputCell"];
        
        _selectedFriends = [[NSMutableSet alloc] init];
        _selectedContacts = [[NSMutableSet alloc] init];
    }
    
    [instances addObject:self];
    
    return self;
}

//- (void)setupSearchField{
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    _searchTextField = appDelegate.searchTextField;
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(searchStartEdit)
//     name:UITextFieldTextDidBeginEditingNotification
//     object:_searchTextField];
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(searchStopEdit)
//     name:UITextFieldTextDidEndEditingNotification
//     object:_searchTextField];
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(searchChange)
//     name:UITextFieldTextDidChangeNotification
//     object:_searchTextField];
//    
//    [_searchTextField setDelegate:self];
//}

- (void)setupInterface{
//    [self setupSeats];
    [self setupInvite];
}

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    [self filterContentForSearchText:searchString];
//    return YES;
//}
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
//{
//    NSString *searchString = controller.searchBar.text;
//    [self filterContentForSearchText:searchString];
//    return YES;
//}


// You can always add a seat
//- (void)addSeat{
//    [_event addSeat];
//    [self updateBubbleUI];
//}

// Attempt to subtract an empty seat. If no empty seats, no subtraction
//- (void)removeSeat{
//    if ([_event removeSeat]){
//        [self updateBubbleUI];
//    }
//}

//- (void)setupSeats{
//    // Get TextView positions
//    float textX = _textView.frame.origin.x;
//    float textXEnd = _textView.frame.size.width + textX;
//    
//    float textY = _textView.frame.origin.y;
////    float textYEnd = textY + _textView.frame.size.height;
//    
//    float midX = (textX + textXEnd)/2;
//    
//    // AddSeatButton
//    float addSeatWidth = 44;
//    float addSeatX = midX + 110;
//    float addSeatY = textY - 160;
//    float addSeatHeight = addSeatWidth;
//    CGRect addSeatFrame = CGRectMake(addSeatX, addSeatY, addSeatWidth, addSeatHeight);
//    
//    _addSeatButton = [FZZInviteGuestButton buttonWithType:UIButtonTypeSystem];//UIButtonTypeContactAdd];
//    
//    [_addSeatButton setFrame:addSeatFrame];
//    
//    //[_inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
//    
//    [_addSeatButton addTarget:self
//                      action:@selector(addSeat)
//            forControlEvents:UIControlEventTouchUpInside];
//    
////    
////    _addSeatButton = [UIButton buttonWithType:UIButtonTypeSystem];//UIButtonTypeContactAdd];
////    _removeSeatButton = [UIButton buttonWithType:UIButtonTypeSystem];
////    
////    [_addSeatButton setFrame:seatsPlusFrame];
////    [_removeSeatButton setFrame:seatsMinusFrame];
////    
////    [_addSeatButton setTitle:@"ADD" forState:UIControlStateNormal];
////    [_removeSeatButton setTitle:@"DEL" forState:UIControlStateNormal];
////    
////    [_addSeatButton addTarget:self action:@selector(addSeat)
////             forControlEvents:UIControlEventTouchUpInside];
////    
////    [_removeSeatButton addTarget:self action:@selector(removeSeat)
////             forControlEvents:UIControlEventTouchUpInside];
//}

- (void)setupInvite{
    // Get TextView positions
    float textX = _textView.frame.origin.x;
    float textXEnd = _textView.frame.size.width + textX;
    
    float textY = _textView.frame.origin.y;
    float textYEnd = textY + _textView.frame.size.height;
    
    float midX = (textX + textXEnd)/2;
    
    // InviteButton
//    float inviteWidth = 44;
//    float inviteX = midX + 110;
//    float inviteY = textYEnd + 60;
//    float inviteHeight = inviteWidth;
//    CGRect inviteFrame = CGRectMake(inviteX, inviteY, inviteWidth, inviteHeight);
    
//    _inviteButton = [FZZInviteGuestButton buttonWithType:UIButtonTypeSystem];//UIButtonTypeContactAdd];
    
//    [_inviteButton setFrame:inviteFrame];
    
    //[_inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
    
//    [_inviteButton addTarget:self
//                      action:@selector(inviteButtonPress)
//            forControlEvents:UIControlEventTouchUpInside];
}

/*
 
 TODOAndrew perhaps use InviteButtonPress transitional stuff
 
 */

//-(void)inviteButtonPress{
//    [self takeBubbleView];
//    
//    [_eventCell enterInviteMode];
//    
//    [self getContacts];
//    [self filterInvitables];
//}

-(void)filterContentForSearchText:(NSString*)searchText {
    if (searchText == NULL || [searchText isEqualToString:@""]){
        _filteredFriends = _invitableFriends;//[[_invitableFriends
        
        _filteredContacts = _contacts;
        return;
    }
    
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", [NSString stringWithFormat:@" %@", searchText]];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@", searchText];
    
    NSArray *predicates = [[NSArray alloc] initWithObjects:predicate, predicate2, nil];
    NSPredicate *fullPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
    
    
//    NSPredicate *dictionaryPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//        return [(NSString *)[(NSDictionary *)evaluatedObject objectForKey:@"name"] hasPrefix:searchText];
//    }];
    
//    NSPredicate *dictionaryPredicateEither = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//        
//        NSString *name = (NSString *)[(NSDictionary *)evaluatedObject objectForKey:@"name"];
//        
//        if (!name){
//            name =
//        }
//        
//        return [name hasPrefix:searchText];
//    }];
//    
//    _filteredRecents = [_recentInvites filteredArrayUsingPredicate:];
    _filteredFriends = [_invitableFriends filteredArrayUsingPredicate:fullPredicate];
    _filteredContacts = [_contacts filteredArrayUsingPredicate:fullPredicate];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (indexPath.section == 1) return NO;
    
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
    if (tableView == self.tableView)
    {
        // Return the number of sections.
        return 2;
    } else {
        return 1;
    }
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
    
    _recentInvites = sortedValues;
}

-(void)updateRecentInvitedFriends:(NSArray *)invitedFriends
                      andContacts:(NSArray *)invitedContacts{
    
    int numInvitedFriends = [invitedFriends count];
    int numInvitedContacts = [invitedContacts count];
    
    // Save recents
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *savedInvites = [[pref objectForKey:@"recentInvites"] mutableCopy];
    
    NSMutableDictionary *updateInvites;
    
    int capacity = 0;
    
    if (savedInvites){
        capacity = MIN(MIN([savedInvites count], kFZZNumRecentInvites), numInvitedFriends + numInvitedContacts);
        updateInvites = [[NSMutableDictionary alloc] initWithCapacity:capacity];
    } else {
        capacity = MIN(numInvitedContacts + numInvitedFriends, kFZZNumRecentInvites);
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
    [sortedKeys subarrayWithRange:NSMakeRange(0, MIN(kFZZNumRecentInvites, sortedKeys.count))];
    
    NSDictionary *toSave = [updateInvites dictionaryWithValuesForKeys:sortedKeys];
    updateInvites = NULL;
    
    [pref setObject:toSave forKey:@"recentInvites"];
    [pref synchronize];
}

-(void)sendInvitations{
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
//    [_eventCell exitInviteMode];
    [self setIsOnTimeline:YES];
    [_searchTextField setText:@""];
    [self filterContentForSearchText:@""];
    [_searchTextField resignFirstResponder];
    
//    NSArray *inviteRefs = [_selected allObjects];
    NSMutableArray *userInvites = [[NSMutableArray alloc] init];
    NSMutableArray *phoneInvites = [[NSMutableArray alloc] init];
    
    NSArray *invitedFriends  = [_selectedFriends allObjects];
    NSArray *invitedContacts = [_selectedContacts allObjects];
    
    [_selectedContacts removeAllObjects];
    [_selectedFriends removeAllObjects];
    
//    NSPredicate *invitedPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//        return ![_invitedContacts containsObject:evaluatedObject];
//    }];
//    
//    _contacts = [[_contacts filteredArrayUsingPredicate:invitedPredicate] mutableCopy];
    
    [_invitedContacts addObjectsFromArray:invitedContacts];
    
    int numInvitedFriends = [invitedFriends count];
    
    for (int i = 0; i < numInvitedFriends; ++i){
        FZZUser *friend = [invitedFriends objectAtIndex:i];
        
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
    
    [self updateRecentInvitedFriends:invitedFriends andContacts:invitedContacts];
    
    NSLog(@"\n\nUser Invites: %@\nPhone Invites: %@\n\n", userInvites, phoneInvites);
    
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
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        if (appDelegate.evc.viewMode == kInvite){
            return 0;
        } else {
            return 1;
        }
    }
    
//    if (section == 1) { // "Search" cell
//        return 1;
//    }
    
    // Return the number of rows in the section.
    return [self lengthOfOptions];
}

-(void)dealloc {
    [instances removeObject:self];
}

+(void)updateFriends{
    [instances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZInviteViewController *ivc = obj;
        [ivc setNeedsUpdateFriends];
    }];
}

-(void)setNeedsUpdateFriends{
    _needsUpdateFriends = YES;
}


/*
 
 TODOAndrew this is probably called too often, every time I setEvent for FZZExpandedEventCell. Reduce to "updating friends" when you get new FZZUsers from the server. Also load all users from the cache on launch.
 
 */
-(void)updateFriends{
    _needsUpdateFriends = NO;
    
    NSMutableArray *friends = [[FZZUser getFriends] mutableCopy];
    [friends removeObjectsInArray:[_event invitees]];
    
    _invitableFriends = friends;
    [self filterInvitables];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
//    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)setTopCellSubviews:(UITableViewCell *)cell{
    [cell addSubview:_textView];
    [cell addSubview:_inviteButton];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self setIsOnTimeline:appDelegate.evc.viewMode == kTimeline];
}

- (void)searchChange{
//    if (self.tableView.delegate != self){
//        [self.tableView setDelegate:self];
//        [self.tableView setDataSource:self];
//    }
    
//    [self searchDisplayController];
    [self filterContentForSearchText:_searchTextField.text];
    [self.tableView reloadData];
//    int lastSection = [self.tableView numberOfSections] - 1;
//    
//    [UIView setAnimationsEnabled:NO];
//    
//    if ([self.tableView numberOfRowsInSection:0] == 1){
//        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//    }
//
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:lastSection] withRowAnimation:UITableViewRowAnimationNone];
//    
//    [UIView setAnimationsEnabled:YES];
}

- (void)setupKeyboard{
    //set notification for when keyboard shows/hides
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableView)
    {
        if (indexPath.section == 0){ // BIG top cell
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Configure the cell...
            FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
            
            if (appDelegate.evc.viewMode == kInvite){
                
            } else if (appDelegate.evc.viewMode == kChat){
                
            } else { // Timeline or otherwise
                [self setTopCellSubviews:cell];
            }
            
            return cell;
        }
    }
    
    // This was for the Search Field Cell
//    if (indexPath.section == 1){
//        // New Phone Number Cell
//        
//        static NSString *CellIdentifier = @"PhoneInputCell";
//        FZZPhoneInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[FZZPhoneInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        
//        // Configure the cell...
//        
//        return cell;
//    }
    
    // All other cells
    
    static NSString *CellIdentifier = @"InviteCell";
    FZZInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FZZInviteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
//    NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
    
    BOOL selected;
    
    NSInteger numInvitableFriends = [_filteredFriends count];
    
    // Configure the cell...
    if (indexPath.row < numInvitableFriends) {
        NSInteger index = indexPath.row;
        
        FZZUser *friend = [_filteredFriends objectAtIndex:index];
        
        [cell.label setText:[friend name]];
        
        selected = [_selectedFriends containsObject:friend];
        
        [cell setHasFriend:YES];
    } else {
        NSInteger index = indexPath.row - numInvitableFriends;
        
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
    
    [[cell label] setNeedsDisplay];
    
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
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.navigationBar.navIcon setIsEditingText:YES];
    [appDelegate.evc setActiveTextField:_searchTextField];
//    [appDelegate.esvc setActiveSearchBar:_searchBar];
    
//    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:0 inSection:1];
//    
//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

-(void)searchStopEdit{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.navigationBar.navIcon setIsEditingText:NO];
    [appDelegate.evc setActiveTextField:NULL];
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
    FZZInviteCell *cell = (FZZInviteCell* )[tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@">><<Dickfingers (2");
    
    if(indexPath.section == [self numberOfSectionsInTableView:tableView] - 1)
    {
        
        NSLog(@">><<Dickfingers 2)a");
//        NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
        NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
        
        if([cell isSelected])
        {
            if ([cell hasFriend]){
                FZZUser *friend = [_filteredFriends objectAtIndex:[cellReference integerValue]];
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
                FZZUser *friend = [_filteredFriends objectAtIndex:[cellReference integerValue]];
                [_selectedFriends addObject:friend];
                
            } else {
                NSDictionary *contact = [_filteredContacts objectAtIndex:[cellReference integerValue]];
                [_selectedContacts addObject:contact];
            }
            
            [cell setIsSelected:YES];
            
//            [_selected addObject:cellReference];
//            [cell setIsSelected:YES];
        }
    }
//    else if (indexPath.section == 1){
//        [_searchTextField becomeFirstResponder];
//    }
    else {
        
        NSLog(@">><<Dickfingers 2)b");
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        if (_canBeSelected && appDelegate.evc.viewMode == kTimeline){
            if ([_event isUserInvited:[FZZUser me]]){ // Chat Mode
                [cell setSelected:NO];
                [cell setHighlighted:NO];
//                [_eventCell enterChatMode];
                NSLog(@"TODOAndrew WOOPDEEDOO: Update code to make it Scroll to chat mode please");
                
                [self setIsOnTimeline:NO];
            }
//            else { // TODOAndrew Express Interest
//                [_event expressInterest];
//            }
        }
    }
}

-(void)setIsOnTimeline:(BOOL)isTimeline{
    if (!isTimeline){
        [_inviteButton setHidden:YES];
        
    } else {
        
        FZZUser *me = [FZZUser me];
        
        if ([_event isUserGuest:me]){ // If I'm attending
            [_inviteButton setHidden:NO];
            
        } else if ([_event isUserInvited:me]){ // If I'm invited
            [_inviteButton setHidden:YES];
            
        } else { // If I'm not invited
            [_inviteButton setHidden:YES];
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
    
    return 48;
}

-(void)getContacts{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    _contacts = [pref objectForKey:@"contacts"];
    [self.tableView reloadData];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.gotAddressBook) {
        [self filterInvitables];
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
            [self searchChange];
            [self.tableView reloadData];
        });
    });
}

// Remove anybody who's already invited to the event
-(void)filterInvitables{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![_event isUserInvited:evaluatedObject];
    }];
    
    _invitableFriends = [_invitableFriends filteredArrayUsingPredicate:predicate];
    
    NSPredicate *predicate2 = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![_invitedContacts containsObject:evaluatedObject];
    }];
    
    _contacts = [[_contacts filteredArrayUsingPredicate:predicate2] mutableCopy];
    
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
