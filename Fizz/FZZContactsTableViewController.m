//
//  FZZContactsTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZContactsTableViewController.h"

#import "FZZContactTableViewCell.h"

#import "FZZUser.h"
#import "FZZEvent.h"

#import "FZZUtilities.h"

#import "FZZContactDelegate.h"
#import "FZZContactSelectionDelegate.h"

NSString *kFZZContactCellIdentifer = @"contactCell";

@interface FZZContactsTableViewController ()

@property (nonatomic) NSIndexPath *eventIndexPath;

@end

@implementation FZZContactsTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [[self tableView] registerClass:[FZZContactTableViewCell class] forCellReuseIdentifier:kFZZContactCellIdentifer];
        
        [[self tableView] setSeparatorColor:[UIColor clearColor]];
        [[self tableView] setBackgroundColor:[UIColor clearColor]];
        [[self tableView] setOpaque:NO];
        [[self tableView] setScrollEnabled:NO];
        [[self tableView] setExclusiveTouch:NO];
        
        _invitationDelegate = [[FZZContactSelectionDelegate alloc] init];
        
        [_invitationDelegate setCurrentTableView:self.tableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateContacts)
                                                     name:FZZ_CONTACTS_SAVED
                                                   object:nil];
        
        [[self tableView] setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
    }
    return self;
}


- (void)updateContacts{
    [FZZContactSelectionDelegate invalidateInvitables];
    NSLog(@"UPDATE CONTACTS MESSAGE RECIEVED");
    [_invitationDelegate searchChange];
}

- (void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    [_invitationDelegate setEventIndexPath:indexPath];
}

- (void)setTextField:(UITextField *)textField{
    [_invitationDelegate setTextField:textField];
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//        [[self tableView] registerClass:[FZZContactTableViewCell class] forCellReuseIdentifier:kFZZContactCellIdentifer];
//    }
//    return self;
//}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}

//-(void)viewWillAppear:(BOOL)animated{
//    // Override to avoid auto scrolling
//    
//}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_invitationDelegate numberOfInvitableOptions];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FZZContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFZZContactCellIdentifer];
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:[self eventIndexPath]];
    
    if (cell == nil) {
        cell = [[FZZContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFZZContactCellIdentifer];
    }
    
    // Configure the cell...
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    BOOL selected;
    
    NSDictionary *dict = [_invitationDelegate userOrContactAtIndexPath:indexPath];
    
    FZZUser *user = [dict objectForKey:@"user"];
    NSString *name = [dict objectForKey:@"name"];
    
    if (user){
        [[cell textLabel] setText:name];
        
        [cell setUserID:[user userID]];
        [cell setPhoneNumber:nil];
        
        selected = [event isUserSelected:user];
    } else {
        NSDictionary *contact = [dict objectForKey:@"contact"];
        
        NSString *phoneNumber = [contact objectForKey:@"pn"];
        
        if ([name isEqualToString:@""]){
            [cell.textLabel setText:phoneNumber];
        } else {
            [cell.textLabel setText:name];
        }
        
        [cell setUserID:nil];
        [cell setPhoneNumber:phoneNumber];
        
        selected = [event isContactSelected:contact];
    }
    
    [cell setTvc:(UITableViewController *)self];
    [cell setIndexPath:indexPath];
    
    [[cell textLabel] setNeedsDisplay];
    
    [cell setSelectionState:selected];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FZZContactTableViewCell *cell = (FZZContactTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSNumber *userID = [cell userID];
    
    FZZUser *user;
    FZZEvent *event = [FZZEvent getEventAtIndexPath:[self eventIndexPath]];
    
    if (userID){
        user = [FZZUser userWithUID:userID];
    } else {
        NSString *phoneNumber = [cell phoneNumber];
        
        user = [FZZUser userFromPhoneNumber:phoneNumber];
    }
    
    if (user){
        if ([event isUserSelected:user]){
            [event deselectUser:user];
            [cell setSelectionState:NO];
            
            NSLog(@"DESELECT %@", user);
            NSLog(@"PHONE: %@", [user phoneNumber]);
        } else {
            [event selectUser:user];
            [cell setSelectionState:YES];
            
            NSLog(@"SELECT %@", user);
            NSLog(@"PHONE: %@", [user phoneNumber]);
        }
    } else {
        NSDictionary *userOrContact = [_invitationDelegate userOrContactAtIndexPath:indexPath];
        
        NSLog(@"GOT: %@", userOrContact);
        
        if ([event userOrContactIsSelected:userOrContact]){
            [event deselectUserOrContact:userOrContact];
            [cell setSelectionState:NO];
            
            NSLog(@"DESELECT %@", userOrContact);
        } else {
            [event selectUserOrContact:userOrContact];
            [cell setSelectionState:YES];
            
            NSLog(@"SELECT %@", userOrContact);
        }
    }
    
    [cell setNeedsDisplay];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}


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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
