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

#import "BCNInviteGuestButton.h"

#import "PhoneNumberFormatter.h"

static NSMutableArray *instances;

@interface BCNInviteViewController ()

@property NSArray *invitableFriends;
@property NSMutableArray *phoneNumbers;
@property NSMutableSet *selected;

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
        
        _phoneNumberFormat = [[PhoneNumberFormatter alloc] init];
        _country = @"us";
        
        self.tableView.separatorColor = [UIColor clearColor];
        
        UINib *inviteNib = [UINib nibWithNibName:@"BCNInviteCell" bundle:nil];
        [[self tableView] registerNib:inviteNib forCellReuseIdentifier:@"InviteCell"];
        
        UINib *phoneNib = [UINib nibWithNibName:@"BCNPhoneInputCell" bundle:nil];
        [[self tableView] registerNib:phoneNib forCellReuseIdentifier:@"PhoneInputCell"];
        
        _phoneNumbers = [[NSMutableArray alloc] init];
        _selected = [[NSMutableSet alloc] init];
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

-(void)inviteButtonPress{
    [_eventCell enterInviteMode];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) return NO;
    else if (indexPath.section == 1) return NO;
    
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
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [_eventCell exitInviteMode];
    
    NSArray *inviteRefs = [_selected allObjects];
    NSMutableArray *userInvites = [[NSMutableArray alloc] init];
    NSMutableArray *phoneInvites = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [inviteRefs count]; ++i){
        int index = [self lengthOfOptions] -
                    [(NSNumber *)[inviteRefs objectAtIndex:i] integerValue];
        
        if (index < [_phoneNumbers count]){
            NSString *phoneNumber = [_phoneNumbers objectAtIndex:index];
            NSString *stripped = [_phoneNumberFormat strip:phoneNumber];
            phoneNumber = [NSString stringWithFormat:@"+%@", stripped];
            [phoneInvites addObject:phoneNumber];
        } else {
            index -= [_phoneNumbers count];
            BCNUser *friend = [_invitableFriends objectAtIndex:index];
            [userInvites addObject:friend];
        }
    }
    
    if ([userInvites count] > 0 || [phoneInvites count] > 0){
        [_event socketIOInviteWithInviteList:userInvites
                             InvitePhoneList:phoneInvites
                              AndAcknowledge:nil];
    }
}

- (int)lengthOfOptions{
    return [_invitableFriends count] + [_phoneNumbers count];
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
        [((BCNInviteViewController *)[instances objectAtIndex:0]) updateFriends];
    }
}

-(void)updateFriends{
    // Worry about selected indices when this happens
    // OR simply remove everything from the selection. That'll do for now
    _selected = [[NSMutableSet alloc] init];
    
    NSMutableArray *friends = [[BCNUser getFriends] mutableCopy];
    [friends removeObjectsInArray:[_event invitees]];
    
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
        
        _phoneTextField = cell.textField;
        _confirmPhoneButton = cell.button;
        [cell.button setEnabled:NO];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(phoneStartEdit)
         name:UITextFieldTextDidBeginEditingNotification
         object:_phoneTextField];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(phoneStopEdit)
         name:UITextFieldTextDidEndEditingNotification
         object:_phoneTextField];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(phoneChange)
         name:UITextFieldTextDidChangeNotification
         object:_phoneTextField];
        
        UIButton *btn = cell.button;
        [btn addTarget:self action:@selector(addPhoneNumber:) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
    
    [cell setIsSelected:[_selected containsObject:cellReference]];
    
    // Configure the cell...
    if (indexPath.row < [_phoneNumbers count]){
        int index = indexPath.row;
        
        [cell.label setText:[_phoneNumbers objectAtIndex:index]];
    } else {
        int index = indexPath.row - [_phoneNumbers count];
        
        [cell.label setText:[[_invitableFriends objectAtIndex:index] name]];
    }
    
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

- (void) addPhoneNumber:(UIButton *)button{
    [button setEnabled:NO];
    [self movePhoneToFriends];
    
    [_phoneTextField setText:@""];
    [_phoneTextField deleteBackward];
    [self phoneChange];
}

- (void) movePhoneToFriends{
    
    [_phoneNumbers insertObject:_phoneTextField.text
                   atIndex:0];
    
    NSNumber *cellRef = [self getSelectedReferenceFromIndexPath:
                         [NSIndexPath indexPathForRow:0 inSection:2]];
    
    [_selected addObject:cellRef];
    
//    NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:1
//                                                      inSection:0];
//    NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:0
//                                                           inSection:1];
//    
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//    
//    [self.tableView moveRowAtIndexPath:sourceIndexPath
//                           toIndexPath:destinationIndexPath];

    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    
}

-(void)phoneStartEdit{
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 190);
    
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:0 inSection:1];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)phoneStopEdit{
    self.tableView.frame = [UIScreen mainScreen].bounds;
}

-(void)phoneChange{
    _phoneTextField.text = [_phoneNumberFormat format:_phoneTextField.text withLocale:_country];
    
    if ([self isValidUSPhoneNumber:_phoneTextField.text]){
        [_confirmPhoneButton setEnabled:YES];
        return;
    }
    
    [_confirmPhoneButton setEnabled:NO];
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSNumber *)getSelectedReferenceFromIndexPath:(NSIndexPath *)indexPath{
    return [NSNumber numberWithInt:[self lengthOfOptions] - indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BCNInviteCell *cell = (BCNInviteCell* )[tableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.section != 0)
    {
        NSNumber *cellReference = [self getSelectedReferenceFromIndexPath:indexPath];
        if([cell isSelected])
        {
            [_selected removeObject:cellReference];
            [cell setIsSelected:NO];
        }
        else
        {
            [_selected addObject:cellReference];
            [cell setIsSelected:YES];
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
