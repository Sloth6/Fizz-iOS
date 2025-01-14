//
//  FZZChatScreenCell.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZChatScreenCell.h"
#import "FZZEvent.h"
#import "FZZMessage.h"
#import "FZZEnterMessagePrototypeViewController.h"
#import "FZZChatScreenTableViewController.h"
#import "FZZAppDelegate.h"
#import "FZZExpandedVerticalTableViewController.h"
#import "FZZPage.h"

#import "FZZScrollDetector.h"

#import "FZZUtilities.h"

@interface FZZChatScreenCell ()

@property CGRect keyboardRect;
@property (strong, nonatomic) NSIndexPath *eventIndexPath;

@property FZZChatScreenTableViewController *ctvc;

// Whether or nor placeholder text is showing
@property BOOL placeholder;
@property BOOL lastTextBoxTooBig;
@property UITextView *placeholderView;
@property UIButton *scrollToPageButton;

@property BOOL isKeyboardShown;

@end

@implementation FZZChatScreenCell

@synthesize viewForm;
@synthesize chatBox;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _placeholder = YES;
        
        [self setupView];
    }
    return self;
}

-(UIScrollView *)scrollView{
    return [_ctvc tableView];
}

- (void)handleAddACommentOnScroll:(UIScrollView *)scrollView
                andScrollDetector:(FZZScrollDetector *)scrollDetector{
    
    NSIndexPath *indexPath = [FZZExpandedVerticalTableViewController descriptionCellIndexPath];
    
    FZZPage *page = [scrollDetector getPageForIndexPath:indexPath];
    
    CGFloat buffer = 4;
    
    CGFloat maxOffset = -180;
    
    CGFloat offset = scrollView.contentOffset.y - (page.pageOffset.y + maxOffset + buffer);
    
    CGFloat progress = MIN(1, MAX(offset/maxOffset, 0));
    
    if (progress > 0.9){
        [viewForm setUserInteractionEnabled:YES];
    } else {
        [viewForm setUserInteractionEnabled:NO];
    }
    
    [viewForm setAlpha:progress];
}

- (void)handleMessagesOnScroll:(UIScrollView *)scrollView
             andScrollDetector:(FZZScrollDetector *)scrollDetector{
    
    NSIndexPath *indexPath = [FZZExpandedVerticalTableViewController descriptionCellIndexPath];
    
    FZZPage *page = [scrollDetector getPageForIndexPath:indexPath];
    
    CGFloat buffer = 4;
    
    float offset = scrollView.contentOffset.y;
    float maxOffset = [FZZExpandedVerticalTableViewController descriptionScreenScrollPosition];
    
    CGFloat progress = MIN(1, MAX(offset/maxOffset, 0));
    
    float dY = MAX([[_ctvc tableView] bounds].size.height - [[_ctvc tableView] contentSize].height, 0.0);
    
    float travelDistance = dY + kFZZMessagesExtraPeak();
    
    CGRect updateFrame = [[_ctvc tableView] bounds];
    
    float initialY = kFZZVerticalMargin();
    
    updateFrame.origin.y = initialY + ((travelDistance - initialY) * progress);
    
    NSLog(@"[%f] %f", progress, updateFrame.origin.y);
    
    [[_ctvc tableView] setFrame:updateFrame];
    [[_ctvc tableView] setAlpha:0.5 + (0.5 * (1 - progress))];
    
//    [_placeholderView setAlpha:progress];
}

-(void)onVerticalEventScroll:(UIScrollView *)scrollView
           andScrollDetector:(FZZScrollDetector *)scrollDetector{
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    if ([[event messages] count] != 0){
        [self handleAddACommentOnScroll:scrollView
                      andScrollDetector:scrollDetector];
        
        [self handleMessagesOnScroll:scrollView
                   andScrollDetector:scrollDetector];
    } else {
        [viewForm setAlpha:1.0];
    }
}

- (void)updateMessages{
    [_ctvc updateMessages];
}

- (void)setupView{
    NSLog(@"[FZZChatScreenCell setupView]");
    
    //set notification for when keyboard shows/hides
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self setupViewForm];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    float viewFormHeight = self.viewForm.bounds.size.height;
    
    // Full screen minus viewForm
    CGFloat xOffset = -13 + kFZZHorizontalMargin();
    CGFloat yOffset = kFZZVerticalMargin();
    
    frame.origin.x = xOffset;
    frame.origin.y = yOffset;
    
    frame.size.height = frame.size.height - viewFormHeight;
    frame.size.width  = frame.size.width - kFZZHorizontalMargin(); //xOffset
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
    
    _ctvc = [[FZZChatScreenTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [[_ctvc tableView] setFrame:frame];
    [(FZZFadedEdgeTableViewController *)_ctvc updateMask];
    
    [self addSubview:[_ctvc tableView]];
    [[_ctvc tableView] setUserInteractionEnabled:NO];
    
//    self.viewForm.inputAccessoryView
    
    [self.contentView addSubview:self.viewForm];
    
    [self setupEventListener];
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
////    if ([textField isEqual:chatBox]){
////        exit(2);
////    textField.inputAccessoryView = YOURCustomView;
////    }
//    [viewForm removeFromSuperview];
//    chatBox.inputAccessoryView = viewForm;
//    
//    return YES;
//}

- (void)setupEventListener{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messagesUpdated)
                                                 name:FZZ_INCOMING_NEW_MESSAGE
                                               object:nil];
}

- (void)messagesUpdated{
    [[_ctvc tableView] reloadData];
    
    [_ctvc scrollToBottomAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:FZZ_RELOADED_CHAT
                                                        object:nil];
}

/*
 
 Returns the frame of the remaining space on the screen above the viewform
 
 */
- (void)setupViewForm{
    _lastTextBoxTooBig = NO;
    
    UIFont *inputFont = kFZZInputFont();
    
    float lineHeight = inputFont.lineHeight;
    
    float width = [UIScreen mainScreen].bounds.size.width;
    float height = lineHeight + 6; // + 30
    float x = 0;
    float y = [UIScreen mainScreen].bounds.size.height - height;
    
    CGRect viewFormRect = CGRectMake(x, y, width, height);
    
    FZZEnterMessagePrototypeViewController *mProtoTVC = [[FZZEnterMessagePrototypeViewController alloc] initWithNibName:@"FZZEnterMessagePrototypeViewController" bundle:nil];
    viewForm = mProtoTVC.view;
    chatBox  = mProtoTVC.textView;
    
    UITextView *textView = mProtoTVC.textView;
    
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setOpaque:NO];
    [textView setTextColor:kFZZWhiteTextColor()];
    [textView setFont:kFZZInputFont()];
    [textView setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    _placeholderView = mProtoTVC.placeholderTV;
    [chatBox setBackgroundColor:[UIColor clearColor]];
    [chatBox setOpaque:NO];
    
    [_placeholderView setBackgroundColor:[UIColor clearColor]];
    [_placeholderView setOpaque:NO];
    [_placeholderView setText:@"add a comment"];
    [_placeholderView setTextColor:kFZZGrayTextColor()];
    [_placeholderView setFont:kFZZInputFont()];
    [_placeholderView setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(-kFZZChatInputBoxInsetBottom(), kFZZChatInputBoxInsetLeft(),
                                           0, 0);
    
    [textView setContentInset:insets];
    [_placeholderView setContentInset:insets];
    
    [chatBox setDelegate:self];
    
    [mProtoTVC setFont:inputFont];
    
    //turn off scrolling and set the font details.
    [chatBox setReturnKeyType:UIReturnKeySend];
    [chatBox setEnablesReturnKeyAutomatically:YES];
    [chatBox setUserInteractionEnabled:YES];
    
    [self setOnPage:NO];
    [viewForm setUserInteractionEnabled:NO];
    
    _scrollToPageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_scrollToPageButton addTarget:self
                            action:@selector(scrollToPageButtonPress)
                  forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = viewFormRect;
    
    frame.size.width -= 150;
//    frame.size.height = chatBox.bounds.size.height;
////    frame.origin.x += viewForm.frame.origin.x;
//    frame.origin.y += viewForm.frame.origin.y;
    
    [_scrollToPageButton setFrame:frame];
    [self.contentView addSubview:_scrollToPageButton];
    
//    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [mProtoTVC.view setFrame:viewFormRect];
}

- (void)scrollToPageButtonPress{
    [self setOnPage:YES];
    [chatBox becomeFirstResponder];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:_eventIndexPath forKey:@"eventIndexPath"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFZZScrollToMessagesNotification
                                                        object:self
                                                      userInfo:dict];
}

-(void)handlePlaceholder{
    NSString *text = chatBox.text;
    
    if ([text isEqualToString:@""]){
        
        if (!_placeholder){
            _placeholder = YES;
            [_placeholderView setHidden:NO];
        }
    } else {
        if (_placeholder){
            _placeholder = NO;
            [_placeholderView setHidden:YES];
        }
    }
}

- (void)setOnPage:(BOOL)isOnPage{
    [viewForm setUserInteractionEnabled:isOnPage];
    [_scrollToPageButton setUserInteractionEnabled:!isOnPage];
}

-(void) keyPressed{
    NSLog(@"[FZZChatScreenCell keyPressed]");
    
    float screenY = [UIScreen mainScreen].bounds.size.height;
    
	// get the size of the text block so we can work our magic
    
    UIFont *font = chatBox.font;
    
    NSString *text = chatBox.text;
    
    /* Space the empty one as if it had some text */
    if ([text isEqualToString:@""]){
        text = @"i";
    }
    [self handlePlaceholder];
    
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
    
    newSizeH -= 11;
    
    if (newSizeH >= (font.lineHeight * 5)){
        
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
    chatBoxFrame.size.height = newSizeH;// + 12;
    [chatBox setFrame:chatBoxFrame];
    
    // form view
    CGRect formFrame = viewForm.frame;
    NSInteger viewFormH = formFrame.size.height;
    //NSLog(@"FORM VIEW HEIGHT : %d", viewFormH);
    formFrame.size.height = 20 + newSizeH;
    //formFrame.origin.y = 199 - (newSizeH - 18);
    formFrame.origin.y = screenY - formFrame.size.height - _keyboardRect.size.height - kFZZChatInputBoxInsetBottom();
    viewForm.frame = formFrame;
    
    // table view
    CGRect tableFrame = [_ctvc tableView].frame;
    NSInteger viewTableH = tableFrame.size.height;
    //NSLog(@"TABLE VIEW HEIGHT : %d", viewTableH);
    tableFrame.size.height = formFrame.origin.y;
    //tableFrame.size.height = 199 - (newSizeH - 18);
    [_ctvc tableView].frame = tableFrame;
}

-(void)textViewDidChange:(UITextView *)textView{
    [self keyPressed];
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    [_ctvc setEventIndexPath:indexPath];
}

- (void)sendMessage{
    [chatBox resignFirstResponder];
    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    
    NSLog(@"\n\n{%@}\n\n<%@>\n\n", chatBox.text, event);
    
    [FZZMessage socketIONewMessage:chatBox.text
                          ForEvent:event
                   WithAcknowledge:nil];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[appDelegate navigationBar] setIsEditingText:NO];
    
	// hide the keyboard, we are done with it.
	[chatBox resignFirstResponder];
	[chatBox setText:@""];
    [self handlePlaceholder];
    
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
    
    [_ctvc updateTableViewToHeight:formFrame.origin.y];
}

-(void) keyboardWillShow:(NSNotification *)note{ // DUPLICATE
    NSLog(@"WILL SHOW");
    
    if (![chatBox isFirstResponder]) {
        return;
    }
    
    if (_isKeyboardShown){
        return;
    }
    
    _isKeyboardShown = YES;
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[appDelegate navigationBar] setIsEditingText:YES];
    [appDelegate setNavigationScrollEnabled:NO];
    
    // get keyboard size and loction
	CGRect keyboardBounds = [FZZUtilities getKeyboardBoundsFromNote:note];
    
    _keyboardRect = keyboardBounds;
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = [_ctvc tableView].frame;
	tableFrame.size.height -= kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y -= kbSizeH;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
	// set views with new info
    [_ctvc updateTableViewToHeight:tableFrame.size.height];
    viewForm.frame = formFrame;
    
    NSInteger numSections = [[_ctvc tableView] numberOfSections];
    NSInteger numMessages = [[_ctvc tableView] numberOfRowsInSection:numSections - 1];
    
    if (numMessages > 0){
        
        NSIndexPath *lastPath = [NSIndexPath indexPathForItem:numMessages - 1 inSection:numSections - 1];
        
        [[_ctvc tableView] scrollToRowAtIndexPath:lastPath
                                atScrollPosition:UITableViewScrollPositionBottom
                                        animated:YES];
    }
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSLog(@"WILL HIDE");
    
    if (![chatBox isFirstResponder]) {
        return;
    }
    
    if (!_isKeyboardShown){
        return;
    }
    
    _isKeyboardShown = NO;
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[appDelegate navigationBar] setIsEditingText:NO];
    [appDelegate setNavigationScrollEnabled:YES];
    
    // get keyboard size and location
	CGRect keyboardBounds;
    
    keyboardBounds = [FZZUtilities getKeyboardBoundsFromNote:note];
    
	// get the height since this is the main value that we need.
	NSInteger kbSizeH = keyboardBounds.size.height;
    
	// get a rect for the table/main frame
	CGRect tableFrame = [_ctvc tableView].frame;
	tableFrame.size.height += kbSizeH;
    
	// get a rect for the form frame
	CGRect formFrame = viewForm.frame;
	formFrame.origin.y += kbSizeH;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
	// set views with new info
    [_ctvc updateTableViewToHeight:tableFrame.size.height];
	viewForm.frame = formFrame;
    
	// commit animations
	[UIView commitAnimations];
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

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (void)addIncomingMessage{
    [_ctvc addIncomingMessage];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
