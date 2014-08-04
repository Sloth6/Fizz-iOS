//
//  FZZExpandedVerticalTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 5/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZExpandedVerticalTableViewController.h"

#import "FZZChatScreenCell.h"

@interface FZZExpandedVerticalTableViewController ()

@property UIView *middleView;
@property UIView *bottomView;

@end

@implementation FZZExpandedVerticalTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        
        [self.tableView registerClass:[FZZChatScreenCell class] forCellReuseIdentifier:@"chatCell"];
    }
    return self;
}

- (FZZChatScreenCell *)getChatScreenCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    return (FZZChatScreenCell *)[self tableView:[self tableView] cellForRowAtIndexPath:indexPath];
}

- (void)setEvent:(FZZEvent *)event{
    _event = event;
    NSLog(@"RELOAD DATA NOWSS");
    [[self tableView] reloadData];
    
    FZZChatScreenCell *cell = [self getChatScreenCell];
    
    [cell setEvent:event];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// TODOAndrew figure out what else I'm missing when I override this
// Overriding viewWillAppear to stop the view from jumping around on Keyboard show/hide
- (void)viewWillAppear:(BOOL)animated{
    
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
            [(FZZChatScreenCell *)cell setEvent:_event];
        }
            break;
            
        default:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        }
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
    backView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = backView;
    
//    // Configure the cell...
//    [cell.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIView *view = obj;
//        [view removeFromSuperview];
//    }];
    
    return cell;
}

- (UIView *)middleCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    return [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (UIView *)bottomCell{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    return [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
}

- (void)updateMessages{
    FZZChatScreenCell *cell = [self getChatScreenCell];
    [cell updateMessages];
}

- (void)updateMiddleView:(UIView *)view{
    if (_middleView != view){
        [_middleView removeFromSuperview];
        _middleView = view;
        [[self middleCell] addSubview:view];
    }
}

- (void)updateBottomView:(UIView *)view{
    if (_bottomView != view){
        [_bottomView removeFromSuperview];
        _bottomView = view;
        [[self bottomCell] addSubview:view];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [UIScreen mainScreen].bounds.size.height;
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
