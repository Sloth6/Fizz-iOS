//
//  FZZDescriptionScreenTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZDescriptionScreenTableViewCell.h"
#import "FZZEvent.h"
#import "FZZUser.h"
#import "FZZAppDelegate.h"
#import "FZZUtilities.h"

#import "FZZExpandedVerticalTableViewController.h"

@interface FZZDescriptionScreenTableViewCell ()

@property NSIndexPath *eventIndexPath;
@property FZZExpandedVerticalTableViewController *evtvc;

@property UIButton *optionsButton;
@property (strong, nonatomic) UILabel *hostLabel;

@end

@implementation FZZDescriptionScreenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupBackground];
        [self setupTextview];
        [self setupHostName];
    }
    return self;
}

-(void)setTableViewController:(FZZExpandedVerticalTableViewController *)evtvc{
    _evtvc = evtvc;
    
    [self setupOptionsButton];
    [self updateTextview];
    [self updateHostName];
}

- (void)setupBackground{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
}

- (void)setupTextview{
    CGFloat leftBorder   = -8 + kFZZHorizontalMargin();
    CGFloat topBorder    = 0;
    CGFloat rightBorder  = 0;
    CGFloat bottomBorder = 0;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    frame.size.width  -= (leftBorder + rightBorder);
    frame.size.height -= (topBorder + bottomBorder);
    
    _textView = [[UITextView alloc] initWithFrame:frame];
    [self addSubview:_textView];
    
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setOpaque:NO];
    [_textView setUserInteractionEnabled:NO];
    
    UIFont *font = kFZZHeadingsFont();
    
    [_textView setFont:font];
    [_textView setTextColor:kFZZWhiteTextColor()];
}

- (void)setupHostName{
    CGFloat leftBorder   = kFZZHorizontalMargin();
    CGFloat topBorder    = 0;
    CGFloat rightBorder  = 0;
    CGFloat bottomBorder = 0;
    
    CGRect frame = [_textView bounds];
    
    frame.origin.y = frame.size.height;
    frame.size.height = kFZZGuestListLineHeight();
    
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    frame.size.width  -= (leftBorder + rightBorder);
    frame.size.height -= (topBorder + bottomBorder);
    
    _hostLabel = [[UILabel alloc] initWithFrame:frame];
    [self addSubview:_hostLabel];
    
    [_hostLabel setBackgroundColor:[UIColor clearColor]];
    [_hostLabel setOpaque:NO];
    
    UIFont *font = kFZZHostNameFont();
    
    [_hostLabel setFont:font];
    [_hostLabel setTextColor:kFZZWhiteTextColor()];
}

- (void)updateTextview{
    CGFloat cellOffset = [_evtvc descriptionCellOffset];
    
    CGRect frame = [_textView frame];
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    frame.size.height = screenFrame.size.height - cellOffset - kFZZInputRowHeight();
    
    frame.size.height -= (frame.origin.y);
    
    [_textView setFrame:frame];
}

- (void)updateHostName{
    CGRect oldFrame = [_hostLabel frame];
    
    CGRect frame = [_textView frame];
    frame.origin.x = oldFrame.origin.x;
    
    frame.origin.y = frame.size.height;
    
    frame.origin.y -= kFZZGuestListPeak();
    frame.origin.y += kFZZVerticalMargin();
    
    frame.size.height = oldFrame.size.height;
    
    [_hostLabel setFrame:frame];
}

- (void)optionsButtonHit{
    // Don't let optionsButtonHit
    //if (the scroll view is not all the way at the bottom)
    // or maybe if (more than one finger is on the screen)
    // Don't pop this up
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Event"
                                                    otherButtonTitles:nil];
    
    [actionSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Event"
                                                            message:@"Are you sure you want to delete the event?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Delete Event", nil];
        
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [self deleteEvent];
    }
}

- (void)deleteEvent{    
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    [event socketIODeleteEventWithAcknowledge:nil];
}

- (void)setupOptionsButton{
    [_optionsButton removeFromSuperview];
    
    _optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [UIImage imageNamed:@"optionsButtonImage"];
    
    [_optionsButton setImage:image forState:UIControlStateNormal];
    
    [_optionsButton addTarget:self action:@selector(optionsButtonHit) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    
    // Magic Number 32
    CGFloat xOffsetFromRight = kFZZRightMargin();
    CGFloat yOffsetFromTop = -[_evtvc descriptionCellOffset] - 32 + kFZZInputRowHeight();
    
    CGFloat bufferSpace = 8;
    
    frame.origin.x = frame.size.width - (imageWidth + xOffsetFromRight + bufferSpace);
    frame.origin.y = yOffsetFromTop + bufferSpace;
    
    CGFloat frameDimension = MAX(imageWidth, imageHeight);
    
    frame.size.width = frameDimension + (bufferSpace * 2);
    frame.size.height = frameDimension + (bufferSpace * 2);
    
    NSLog(@"xy:(%f, %f) wh:(%f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    [_optionsButton setFrame:frame];
    [self.contentView addSubview:_optionsButton];
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

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    FZZEvent *event = [FZZEvent getEventAtIndexPath:_eventIndexPath];
    NSString *title = [event eventDescription];
    
    NSString *hostName = [[[event creator] name] uppercaseString];
    
    [_textView setText:title];
    [_hostLabel setText:hostName];
    NSLog(@"event: <%@>", title);
    [_textView setNeedsDisplay];
}

@end
