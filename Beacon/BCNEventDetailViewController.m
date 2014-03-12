//
//  BCNEventDetailViewController.m
//  Beacon
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

/*
 
 SMS-style Chat Window based of Brett Schumann (January 2010)
 http://brettschumann.com/blog/2010/01/15/iphone-multiline-textbox-for-sms-style-chat
 
 */

#import "BCNEventDetailViewController.h"
#import "BCNDetailTextCell.h"
#import "BCNMessage.h"
#import "BCNUser.h"
#import "BCNEventStreamViewController.h"

#import "BCNTestViewController.h"

static int kBCNNumCellsBeforeMessages = 1;

@interface BCNEventDetailViewController ()

@property BOOL nibTextCellLoaded;
@property float pictureDimension;
@property float textLabelWidth;
@property BOOL didGetDimensionsFromCell;
@property CGRect keyboardRect;

@end

@implementation BCNEventDetailViewController

@synthesize viewForm;
@synthesize chatBox;
@synthesize chatButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        _nibTextCellLoaded = NO;
        
        _didGetDimensionsFromCell = NO;
        
        _pictureDimension = 52;
        
        NSLog(@"ZZZ2");
        
        
//        [[self collectionView] scrollToItemAtIndexPath:
//         [NSIndexPath indexPathForItem:kBCNNumCellsBeforeMessages inSection:0]
//                                      atScrollPosition:UICollectionViewScrollPositionTop
//                                              animated:NO];
        
    }
    return self;
}

- (void)setupViewForm{
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = 30 + 6;
    float x = 0;
    float y = self.collectionView.bounds.size.height - height + statusBarHeight;
    
    //Magic Number 68
    _textLabelWidth = [UIScreen mainScreen].bounds.size.width - _pictureDimension - 68;
    
    CGRect viewFormRect = CGRectMake(x, y, width, height);
    
    BCNTestViewController *tvc = [[BCNTestViewController alloc] initWithNibName:@"BCNTestViewController" bundle:nil];
    viewForm   = tvc.view;
    chatBox    = tvc.textView;
    chatButton = tvc.rightButton;
    
//    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [tvc.view setFrame:viewFormRect];
    
    [chatButton addTarget:self
                   action:@selector(chatButtonClick)
         forControlEvents:UIControlEventTouchUpInside];
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *) layout{
    self = [super initWithCollectionViewLayout:layout];
    
    NSLog(@"OOPSIE");
    
    if (self) {
        // Custom initialization
        
        _nibTextCellLoaded = NO;
        
        _didGetDimensionsFromCell = NO;
        
        _pictureDimension = 52;
        
        NSLog(@"ZZZ2");
        
        //        [[self collectionView] scrollToItemAtIndexPath:
        //         [NSIndexPath indexPathForItem:kBCNNumCellsBeforeMessages inSection:0]
        //                                      atScrollPosition:UICollectionViewScrollPositionTop
        //                                              animated:NO];
        
    }
    return self;
}

- (void)viewDidLoad
{
    //set notification for when keyboard shows/hides
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //set notification for when a key is pressed.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(keyPressed:)
                                                 name: UITextViewTextDidChangeNotification
                                               object: nil];

    
    
    //turn off scrolling and set the font details.
    chatBox.scrollEnabled = NO;
    chatBox.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    [super viewDidLoad];
}

-(CGRect) getKeyboardBoundsFromNote:(NSNotification *)note{
    CGRect _keyboardEndFrame;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    
    // (x,y) is irrelevant for the use
    return CGRectMake(0, 0, 0, _keyboardEndFrame.size.height);
}

-(void) keyboardWillShow:(NSNotification *)note{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    
//    // work
//    
//    [UIView commitAnimations];
    
    
    // get keyboard size and loction
	CGRect keyboardBounds = [self getKeyboardBoundsFromNote:note];
    
    _keyboardRect = keyboardBounds;
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = self.collectionView.frame;
	tableFrame.size.height -= kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y -= kbSizeH;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
	// set views with new info
	self.collectionView.frame = tableFrame;
	viewForm.frame = formFrame;
    
	// commit animations
	[UIView commitAnimations];
    
//    // get keyboard size and loction
//	CGRect keyboardBounds = [self getKeyboardBoundsFromNote:note];
//    
//	// get the height since this is the main value that we need.
//	NSInteger kbSizeH = keyboardBounds.size.height;
//    
//	// get a rect for the table/main frame
//	CGRect tableFrame = self.collectionView.frame;
//	tableFrame.size.height -= kbSizeH;
//    
//	// get a rect for the form frame
//	CGRect formFrame = viewForm.frame;
//	formFrame.origin.y -= kbSizeH;
//    
//	// animations settings
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:0.3f];
//    
//	// set views with new info
//	self.collectionView.frame = tableFrame;
//	viewForm.frame = formFrame;
//    
//	// commit animations
//	[UIView commitAnimations];
}

-(void) keyPressed: (NSNotification*) notification{
    float screenY = [UIScreen mainScreen].bounds.size.height;
    
	// get the size of the text block so we can work our magic
	
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14];
    
    NSString *text = chatBox.text;
    
    /* Space the empty one as if it had some text */
    if ([text isEqualToString:@""]){
        text = @"i";
    }
    
    CGFloat width = [chatBox bounds].size.width - 19;
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: font
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];

    CGSize newSize = rect.size;
    
	NSInteger newSizeH = newSize.height;
	NSInteger newSizeW = newSize.width;
    
    // I output the new dimensions to the console
    // so we can see what is happening
	NSLog(@"NEW SIZE : %d X %d", newSizeW, newSizeH);

    // if the height of our new chatbox is
    // below 90 we can set the height
    
    if (newSizeH <= 90)
    {
        [chatBox scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
        
        // chatbox
        CGRect chatBoxFrame = chatBox.frame;
        NSInteger chatBoxH = chatBoxFrame.size.height;
        NSInteger chatBoxW = chatBoxFrame.size.width;
        NSLog(@"CHAT BOX SIZE : %d X %d", chatBoxW, chatBoxH);
        chatBoxFrame.size.height = newSizeH + 12;
        chatBox.frame = chatBoxFrame;
        
        // form view
        CGRect formFrame = viewForm.frame;
        NSInteger viewFormH = formFrame.size.height;
        NSLog(@"FORM VIEW HEIGHT : %d", viewFormH);
        formFrame.size.height = 20 + newSizeH;
        //formFrame.origin.y = 199 - (newSizeH - 18);
        formFrame.origin.y = screenY - formFrame.size.height - _keyboardRect.size.height;
        viewForm.frame = formFrame;
        
        // table view
        CGRect tableFrame = self.collectionView.frame;
        NSInteger viewTableH = tableFrame.size.height;
        NSLog(@"TABLE VIEW HEIGHT : %d", viewTableH);
        tableFrame.size.height = formFrame.origin.y;
        //tableFrame.size.height = 199 - (newSizeH - 18);
        self.collectionView.frame = tableFrame;
    }
    
    // if our new height is greater than 90
    // sets not set the height or move things
    // around and enable scrolling
    if (newSizeH > 90)
    {
        chatBox.scrollEnabled = YES;
    }
}

- (void)chatButtonClick{
	// hide the keyboard, we are done with it.
	[chatBox resignFirstResponder];
	chatBox.text = nil;
    
    float screenY = [UIScreen mainScreen].bounds.size.height;
    
	// chatbox
	CGRect chatBoxFrame = chatBox.frame;
	chatBoxFrame.size.height = 20;
	chatBox.frame = chatBoxFrame;
	// form view
	CGRect formFrame = viewForm.frame;
	formFrame.size.height = 30 + 6; // Helvetica font line height is 6
	formFrame.origin.y = screenY - formFrame.size.height;
	viewForm.frame = formFrame;
    
	// table view
	CGRect tableFrame = self.collectionView.frame;
	tableFrame.size.height = formFrame.origin.y;
	self.collectionView.frame = tableFrame;
}

+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view {
    UIWindow *window = [view isKindOfClass:[UIWindow class]] ? (UIWindow *) view : [view window];
    return [view convertRect:[window convertRect:rect fromWindow:nil] fromView:nil];
}

-(void) keyboardWillHide:(NSNotification *)note{
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    //    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    //    [UIView setAnimationBeginsFromCurrentState:YES];
    //
    //    // work
    //
    //    [UIView commitAnimations];
    
    // get keyboard size and loction
    
	CGRect keyboardBounds;
    
    keyboardBounds = [self getKeyboardBoundsFromNote:note];
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = self.collectionView.frame;
	tableFrame.size.height += kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y += kbSizeH;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
	// set views with new info
	self.collectionView.frame = tableFrame;
	viewForm.frame = formFrame;
    
	// commit animations
	[UIView commitAnimations];
    
//    // get keyboard size and loction
//    
//	CGRect keyboardBounds;
//    
//    keyboardBounds = [self getKeyboardBoundsFromNote:note];
//    
//	// get the height since this is the main value that we need.
//	NSInteger kbSizeH = keyboardBounds.size.height;
//    
//	// get a rect for the table/main frame
//	CGRect tableFrame = self.collectionView.frame;
//	tableFrame.size.height += kbSizeH;
//    
//	// get a rect for the form frame
//	CGRect formFrame = viewForm.frame;
//	formFrame.origin.y += kbSizeH;
//    
//	// animations settings
//	[UIView beginAnimations:nil context:NULL];
//	[UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationDuration:0.3f];
//    
//	// set views with new info
//	self.collectionView.frame = tableFrame;
//	viewForm.frame = formFrame;
//    
//	// commit animations
//	[UIView commitAnimations];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[_event messages] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int index = [indexPath item];// - kBCNNumCellsBeforeMessages
    
    BCNMessage *message = [[_event messages] objectAtIndex:index];
    
    NSString *text = [message text];
    
    float labelWidth = [UIScreen mainScreen].bounds.size.width - 120;
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = [BCNDetailTextCell getTextBoxForText:text withLabelWidth:labelWidth].height;
    
    height = MAX(height, 52);
    
    return CGSizeMake(width, height + 14);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(20, 0, 0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = @"TextCell";
    
    if(!_nibTextCellLoaded)
    {
        UINib *nib = [UINib nibWithNibName:@"BCNDetailTextCell" bundle: nil];
        [cv registerNib:nib forCellWithReuseIdentifier:cellID];
        _nibTextCellLoaded = YES;
    }
    
    BCNDetailTextCell *cell = [cv dequeueReusableCellWithReuseIdentifier:cellID
                                                            forIndexPath:indexPath];
    
    if (!_didGetDimensionsFromCell){
        _didGetDimensionsFromCell = YES;
        _textLabelWidth = cell.label.bounds.size.width;
        _pictureDimension = cell.imageView.bounds.size.width;
    }
    
    int index = [indexPath item];// - kBCNNumCellsBeforeMessages
    
    float x = cell.bounds.origin.x;
    float y = cell.bounds.origin.y;
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = cell.bounds.size.height;
    
    cell.bounds = CGRectMake(x, y, width, height);
    
    BCNMessage *message = [[_event messages] objectAtIndex:index];
    
    NSString *text = [message text];
    BCNUser  *user = [message user];
    
    //NSString *userName = [user name];
    
    [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
        if (image != NULL){
            // Set image
            [cell.imageView setImage:image];
            [BCNUser formatImageViewToCircular:cell.imageView withScalar:1.0];
        }
    }];
    
    [cell.label setText:text];
    
    return cell;
}

@end
