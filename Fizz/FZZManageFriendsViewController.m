//
//  FZZManageFriendsViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 3/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZManageFriendsViewController.h"
#import "FZZManageFriendCell.h"

#import "FZZUser.h"

@interface FZZManageFriendsViewController ()

@property NSArray *friends;
@property NSMutableSet *friendsToRemove;

@end

@implementation FZZManageFriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        UINib *nib = [UINib nibWithNibName:@"FZZManageFriendCell" bundle:nil];
        
        [self.tableView registerNib:nib forCellReuseIdentifier:@"FriendCell"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    _friends = [FZZUser getFriends];
    _friendsToRemove = [[NSMutableSet alloc] init];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated{
    _friends = NULL;
    _friendsToRemove = NULL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_friends count];
}

- (FZZUser *)getFriendForIndexPath:(NSIndexPath *)indexPath{
    return [_friends objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FZZUser *user = [self getFriendForIndexPath:indexPath];
    
    if([_friendsToRemove containsObject:user]){
        NSLog(@"Friends");
        [_friendsToRemove removeObject:user];
        
        FZZManageFriendCell *cell = (FZZManageFriendCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.friendName setTextColor:[UIColor blackColor]];
        [cell.profilePic setAlpha:1.0];
//        [cell setNeedsDisplay];
    } else {
        NSLog(@"Not Friends");
        [_friendsToRemove addObject:user];
        
        FZZManageFriendCell *cell = (FZZManageFriendCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.friendName setTextColor:[UIColor grayColor]];
        [cell.profilePic setAlpha:0.33];
//        [cell setNeedsDisplay];
    }
    
//    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)isFriend:(FZZUser *)user{
    return ![_friendsToRemove containsObject:user];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FriendCell";
    FZZManageFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    FZZUser *user = [_friends objectAtIndex:indexPath.row];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // Configure the cell...
    [cell.friendName setText:[user name]];
    
    if ([self isFriend:user]){
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.imageView setAlpha:1.0];
    } else {
        [cell.textLabel setTextColor:[UIColor grayColor]];
        [cell.imageView setAlpha:0.5];
    }
    
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
