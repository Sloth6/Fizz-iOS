//
//  FZZChatDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 3/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

/*
 
 SMS-style Chat Window based of Brett Schumann (January 2010)
 http://brettschumann.com/blog/2010/01/15/iphone-multiline-textbox-for-sms-style-chat
 
 */

#import <AudioToolbox/AudioToolbox.h>

#import "FZZAppDelegate.h"

#import "FZZChatDelegate.h"
#import "FZZEvent.h"

#import "FZZUserMessageCell.h"
#import "FZZServerMessageCell.h"

#import "FZZMessage.h"
#import "FZZUser.h"
#import "FZZEvent.h"
#import "FZZEventsExpandedViewController.h"
#import "FZZInviteViewController.h"

#import "FZZEnterMessagePrototypeViewController.h"

#import "FZZNavIcon.h"

static int kFZZNumCellsBeforeMessages = 1;

@interface FZZChatDelegate ()

@property NSMutableSet *nibTextCellLoaded;
@property float pictureDimension;
@property float textLabelWidth;
@property BOOL didGetDimensionsFromCell;
@property CGRect keyboardRect;

// Whether or nor placeholder text is showing
@property BOOL placeholder;

@property BOOL lastTextBoxTooBig;

@end

@implementation FZZChatDelegate

@synthesize viewForm;
@synthesize chatBox;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        _placeholder = YES;
        _nibTextCellLoaded = [[NSMutableSet alloc] init];
        
        _didGetDimensionsFromCell = NO;
        
        _pictureDimension = 52;
        
        _numSectionsDeleted = 0;
        
        [self setupKeyboard];
        
        //        [[self collectionView] scrollToItemAtIndexPath:
        //         [NSIndexPath indexPathForItem:kFZZNumCellsBeforeMessages inSection:0]
        //                                      atScrollPosition:UICollectionViewScrollPositionTop
        //                                              animated:NO];
        
    }
    return self;
}

//- (void)popView{
//    [self.viewForm removeFromSuperview];
//    
//    _esvc.viewMode = kTimeline;
////    _esvc.collectionView.delegate   = _esvc;
////    _esvc.collectionView.dataSource = _esvc;
//    
//    // Offset by one to ignore the new event. Maybe make new event in it's own section?
//    int index = [_esvc.events indexOfObject:_event] + 1;
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
//    
//    [_esvc.collectionView scrollToItemAtIndexPath:indexPath
//                                 atScrollPosition:UICollectionViewScrollPositionTop
//                                         animated:NO];
//    
//    _event = NULL;
//}

- (void)setupViewForm{
    _lastTextBoxTooBig = NO;
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = 30 + 6;
    float x = 0;
    float y = [UIScreen mainScreen].bounds.size.height - height;
    
    //Magic Number 68
    _textLabelWidth = [UIScreen mainScreen].bounds.size.width - _pictureDimension - 68;
    
    CGRect viewFormRect = CGRectMake(x, y, width, height);
    
    FZZEnterMessagePrototypeViewController *tvc = [[FZZEnterMessagePrototypeViewController alloc] initWithNibName:@"FZZTestViewController" bundle:nil];
    viewForm = tvc.view;
    chatBox  = tvc.textView;
    
    [chatBox setDelegate:self];
    
    [tvc setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    //turn off scrolling and set the font details.
    [chatBox setReturnKeyType:UIReturnKeySend];
    [chatBox setEnablesReturnKeyAutomatically:YES];
    [chatBox setUserInteractionEnabled:YES];
    
    //    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [tvc.view setFrame:viewFormRect];
}

- (void)setupKeyboard{
    //set notification for when keyboard shows/hides
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardDidHide:)
//                                                 name:UIKeyboardDidHideNotification
//                                               object:nil];
    
    
    
//    //set notification for when a key is pressed.
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector: @selector(keyPressed:)
//                                                 name: UITextViewTextDidChangeNotification
//                                               object: nil];
}

//- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
//{
//    //CGPoint touchPoint = [gesture locationInView:self.collectionView];
//    [self popView];
//}

+(CGRect) getKeyboardBoundsFromNote:(NSNotification *)note{
    CGRect _keyboardEndFrame;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    
    // (x,y) is irrelevant for the use
    return CGRectMake(0, 0, 0, _keyboardEndFrame.size.height);
}

- (void)addIncomingMessageForEvent:(FZZEvent *)event{
    if (_esvc.viewMode == kChat){
        if (_ivc.event != event){
            return;
        }
        
        CGPoint offset = _ivc.tableView.contentOffset;
        CGRect bounds = _ivc.tableView.bounds;
        CGSize size = _ivc.tableView.contentSize;
        
        int lastSection = [_ivc.tableView numberOfSections] - 1;
        int nextRow = [_ivc.tableView numberOfRowsInSection:lastSection];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nextRow inSection:lastSection];
        NSArray *paths = [NSArray arrayWithObject:indexPath];
        
        float threshold = 30;
        
        BOOL scroll = NO;
        
        if (offset.y + bounds.size.height > size.height - threshold){
            [_ivc.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
            scroll = YES;
        } else {
            [_ivc.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        CGFloat newCellHeight = [self tableView:_ivc.tableView heightForRowAtIndexPath:indexPath];
        CGSize newContentSize = CGSizeMake(_ivc.tableView.contentSize.width, _ivc.tableView.contentSize.height + newCellHeight);
        
        [_ivc.tableView setContentSize:newContentSize];
        
        [_ivc.tableView layoutIfNeeded];
        
        if (scroll){
            [_ivc.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
        FZZMessage *newestMessage = [[_event messages] lastObject];
        
        if (!([newestMessage user] == [FZZUser me]) && // Not my message
            [newestMessage user]){                     // Not the server's message
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

-(void) keyboardWillShow:(NSNotification *)note{ // DUPLICATE
    
    if (![chatBox isFirstResponder]) {
        return;
    }
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate.navigationBar.navIcon setIsEditingText:YES];
    
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    //    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    //    [UIView setAnimationBeginsFromCurrentState:YES];
    //
    //    // work
    //
    //    [UIView commitAnimations];
    
    // get keyboard size and loction
	CGRect keyboardBounds = [FZZChatDelegate getKeyboardBoundsFromNote:note];
    
    _keyboardRect = keyboardBounds;
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = _ivc.tableView.frame;
	tableFrame.size.height -= kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y -= kbSizeH;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
	// set views with new info
	_ivc.tableView.frame = tableFrame;
	viewForm.frame = formFrame;
    
    int numSections = [_ivc.tableView numberOfSections];
    int numMessages = [_ivc.tableView numberOfRowsInSection:numSections - 1];
    
    NSIndexPath *lastPath = [NSIndexPath indexPathForItem:numMessages - 1 inSection:numSections - 1];
    
    [_ivc.tableView scrollToRowAtIndexPath:lastPath
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    
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

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([[textView text] length] > 0){
        if([text isEqualToString:@"\n"]){
            [self sendMessage];
            return NO;
        }
    }
    
    NSString *validText = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if ([validText length] != [text length]){
        
        UITextPosition *beginning = textView.beginningOfDocument;
        UITextPosition *start = [textView positionFromPosition:beginning offset:range.location];
        UITextPosition *end = [textView positionFromPosition:start offset:range.length];
        UITextRange *textRange = [textView textRangeFromPosition:start toPosition:end];
        
        [textView replaceRange:textRange withText:validText];
        
        return NO;
    } else {
        return YES;
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    [self keyPressed];
}

-(void) keyPressed{
    
    if (![chatBox isFirstResponder]) {
        return;
    }
    
    float screenY = [UIScreen mainScreen].bounds.size.height;
    
	// get the size of the text block so we can work our magic
    
    UIFont *font = chatBox.font;
    
    NSString *text = chatBox.text;
    
    /* Space the empty one as if it had some text */
    if ([text isEqualToString:@""]){
        if (!_placeholder){
            _placeholder = YES;
            [chatBox setBackgroundColor:[UIColor clearColor]];
        }
        text = @"i";
    } else {
        if (_placeholder){
            _placeholder = NO;
            [chatBox setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    [chatBox.layoutManager ensureLayoutForTextContainer:chatBox.textContainer];
    CGRect textBounds = [chatBox.layoutManager usedRectForTextContainer:chatBox.textContainer];
    CGFloat width = (CGFloat)(textBounds.size.width + chatBox.textContainerInset.left + chatBox.textContainerInset.right) - 10;
    
    
//    CGFloat width = [chatBox textContainer].size.width;
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
	//NSLog(@"NEW SIZE : %d X %d", newSizeW, newSizeH);
    
    // if the height of our new chatbox is
    // below 90 we can set the height
    
    if (newSizeH >= 90){
        
        text = @"i\n\n\n\ni";
        
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
        
        newSizeH = newSize.height;
        newSizeW = newSize.width;
        
        if (!_lastTextBoxTooBig){
            // if our new height is greater than 90
            // sets not set the height or move things
            // around and enable scrolling
            chatBox.scrollEnabled = YES;
            
            _lastTextBoxTooBig = YES;
            
            [chatBox scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
        }
    } else {
        [chatBox scrollRectToVisible:CGRectMake(0,0,1,1) animated:NO];
        _lastTextBoxTooBig = NO;
    }
    
    // chatbox
    CGRect chatBoxFrame = chatBox.frame;
    NSInteger chatBoxH = chatBoxFrame.size.height;
    NSInteger chatBoxW = chatBoxFrame.size.width;
    //NSLog(@"CHAT BOX SIZE : %d X %d", chatBoxW, chatBoxH);
    chatBoxFrame.size.height = newSizeH + 12;
    [chatBox setFrame:chatBoxFrame];
    
    // form view
    CGRect formFrame = viewForm.frame;
    NSInteger viewFormH = formFrame.size.height;
    //NSLog(@"FORM VIEW HEIGHT : %d", viewFormH);
    formFrame.size.height = 20 + newSizeH;
    //formFrame.origin.y = 199 - (newSizeH - 18);
    formFrame.origin.y = screenY - formFrame.size.height - _keyboardRect.size.height;
    viewForm.frame = formFrame;
    
    // table view
    CGRect tableFrame = _ivc.tableView.frame;
    NSInteger viewTableH = tableFrame.size.height;
    //NSLog(@"TABLE VIEW HEIGHT : %d", viewTableH);
    tableFrame.size.height = formFrame.origin.y;
    //tableFrame.size.height = 199 - (newSizeH - 18);
    _ivc.tableView.frame = tableFrame;
}

- (void)sendMessage{
    [FZZMessage socketIONewMessage:chatBox.text
                          ForEvent:_event
                   WithAcknowledge:nil];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate.navigationBar.navIcon setIsEditingText:NO];
    
	// hide the keyboard, we are done with it.
	[chatBox resignFirstResponder];
	[chatBox setText:@""];
    [self keyPressed];
    
    float screenY = [UIScreen mainScreen].bounds.size.height;
    
	// chatbox
	CGRect chatBoxFrame = chatBox.frame;
	chatBoxFrame.size.height = 20;
	[chatBox setFrame:chatBoxFrame];
	// form view
	CGRect formFrame = viewForm.frame;
	formFrame.size.height = 30 + 6; // Helvetica font line height is 6
	formFrame.origin.y = screenY - formFrame.size.height;
	viewForm.frame = formFrame;
    
	// table view
	CGRect tableFrame = _ivc.tableView.frame;
	tableFrame.size.height = formFrame.origin.y;
	_ivc.tableView.frame = tableFrame;
}

+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view {
    UIWindow *window = [view isKindOfClass:[UIWindow class]] ? (UIWindow *) view : [view window];
    return [view convertRect:[window convertRect:rect fromWindow:nil] fromView:nil];
}

-(void) keyboardWillHide:(NSNotification *)note{ // DUPLICATE
    if (![chatBox isFirstResponder]) {
        return;
    }
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate.navigationBar.navIcon setIsEditingText:NO];
    
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
    
    keyboardBounds = [FZZChatDelegate getKeyboardBoundsFromNote:note];
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = _ivc.tableView.frame;
	tableFrame.size.height += kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y += kbSizeH;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
	// set views with new info
	_ivc.tableView.frame = tableFrame;
	viewForm.frame = formFrame;
    
//    int numSections = [_ivc.tableView numberOfSections];
    
//    int section = numSections - 1;
    
//    int numMessages = [_ivc.tableView numberOfRowsInSection:section];
    
//    NSIndexPath *lastPath = [NSIndexPath indexPathForItem:numMessages - 1 inSection:section];
    
//    [_ivc.tableView scrollToRowAtIndexPath:lastPath
//                          atScrollPosition:UITableViewScrollPositionBottom
//                                  animated:YES];
    
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

//-(void) keyboardDidHide:(NSNotification *)note{
//    if (![chatBox isFirstResponder]) {
//        return;
//    }
//    
//    return;
//    
//    //    [UIView beginAnimations:nil context:NULL];
//    //    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//    //    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
//    //    [UIView setAnimationBeginsFromCurrentState:YES];
//    //
//    //    // work
//    //
//    //    [UIView commitAnimations];
//    
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
//	CGRect tableFrame = _ivc.tableView.frame;
//	tableFrame.size.height += kbSizeH;
//    
//	// get a rect for the form frame
//	CGRect formFrame = viewForm.frame;
//	formFrame.origin.y += kbSizeH;
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
//    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    
//	// set views with new info
//	_ivc.tableView.frame = tableFrame;
//	viewForm.frame = formFrame;
//    
//    //    int numSections = [_ivc.tableView numberOfSections];
//    
//    //    int section = numSections - 1;
//    
//    //    int numMessages = [_ivc.tableView numberOfRowsInSection:section];
//    
//    //    NSIndexPath *lastPath = [NSIndexPath indexPathForItem:numMessages - 1 inSection:section];
//    
//    //    [_ivc.tableView scrollToRowAtIndexPath:lastPath
//    //                          atScrollPosition:UITableViewScrollPositionBottom
//    //                                  animated:YES];
//    
//	// commit animations
//	[UIView commitAnimations];
//    
//    //    // get keyboard size and loction
//    //
//    //	CGRect keyboardBounds;
//    //
//    //    keyboardBounds = [self getKeyboardBoundsFromNote:note];
//    //
//    //	// get the height since this is the main value that we need.
//    //	NSInteger kbSizeH = keyboardBounds.size.height;
//    //
//    //	// get a rect for the table/main frame
//    //	CGRect tableFrame = self.collectionView.frame;
//    //	tableFrame.size.height += kbSizeH;
//    //
//    //	// get a rect for the form frame
//    //	CGRect formFrame = viewForm.frame;
//    //	formFrame.origin.y += kbSizeH;
//    //
//    //	// animations settings
//    //	[UIView beginAnimations:nil context:NULL];
//    //	[UIView setAnimationBeginsFromCurrentState:YES];
//    //    [UIView setAnimationDuration:0.3f];
//    //
//    //	// set views with new info
//    //	self.collectionView.frame = tableFrame;
//    //	viewForm.frame = formFrame;
//    //
//    //	// commit animations
//    //	[UIView commitAnimations];
//}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return [_ivc tableView:tableView numberOfRowsInSection:section];
    }
    
    //NSLog(@"\nmessages: %@\nevent: %@", [_event messages], _event);
    
    return [[_event messages] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2 - _numSectionsDeleted;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self popView];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return [_ivc tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    FZZMessage *message = [self getMessageAtIndexPath:indexPath];
    
    if ([message isServerMessage]){
        return 24;
    }
    
    NSString *text = [message text];
    
    float labelWidth = [UIScreen mainScreen].bounds.size.width - 120;
    
    //NSLog(@"\ntext: <%@>\nlabelWidth: %f", text, labelWidth);
    
    float height = [FZZUserMessageCell getTextBoxForText:text withLabelWidth:labelWidth].height;
    
    // Fit the profile picture at least
    height = MAX(height, 52 + 6);
    
    return height + 14;
}

-(FZZMessage *)getMessageAtIndexPath:(NSIndexPath *)indexPath{
    int index = [indexPath item]; // - kFZZNumCellsBeforeMessages;
    return [[_event messages] objectAtIndex:index];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){
        return [_ivc tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    if(![_nibTextCellLoaded containsObject:tableView])
    {
        NSString *cellID = @"TextCell";
        
        UINib *nib = [UINib nibWithNibName:@"FZZDetailTextCell" bundle: nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        
        cellID = @"ServerCell";
        
        nib = [UINib nibWithNibName:@"FZZServerMessageCell" bundle: nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellID];
        [_nibTextCellLoaded addObject:tableView];
    }
    
    FZZMessage *message = [self getMessageAtIndexPath:indexPath];
    
    if ([message isServerMessage]){
        NSString *cellID = @"ServerCell";
        
        FZZServerMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                                     forIndexPath:indexPath];
        
        [cell.serverLabel setText:[message text]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    
    NSString *cellID = @"TextCell";
    
    FZZUserMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                              forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!_didGetDimensionsFromCell){
        _didGetDimensionsFromCell = YES;
        _textLabelWidth = cell.label.bounds.size.width;
        _pictureDimension = cell.profileImageView.bounds.size.width;
    }
    
    float x = cell.bounds.origin.x;
    float y = cell.bounds.origin.y;
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = cell.bounds.size.height;
    
    cell.bounds = CGRectMake(x, y, width, height);
    
    
    
    NSString *text = [message text];
    FZZUser  *user = [message user];
    
    //NSString *userName = [user name];
    
    [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
        if (image != NULL){
            // Set image
            [cell.profileImageView removeFromSuperview];
            CGRect frame = cell.profileImageView.frame;
            
            cell.profileImageView = [user circularImageForRect:frame];
            [cell.profileImageView setImage:image];
            [cell addSubview:cell.profileImageView];
            [cell.profileImageView setFrame:frame];
        } else {
            [user formatImageView:cell.profileImageView
               ForInitialsForRect:cell.profileImageView.frame];
//            [user formatImageView:cell.profileImageView ForInitialsWithScalar:1.0];
        }
        
        [cell.profileImageView setNeedsDisplay];
    }];
    
    [cell.label setText:text];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

@end
