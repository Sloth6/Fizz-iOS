//
//  FZZDescriptionScreenTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZDescriptionScreenTableViewCell.h"
#import "FZZEvent.h"
#import "FZZAppDelegate.h"
#import "FZZUtilities.h"

@interface FZZDescriptionScreenTableViewCell ()

@property NSIndexPath *eventIndexPath;

@end

@implementation FZZDescriptionScreenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupBackground];
        [self setupTextview];
        [self setupOptionsButton];
    }
    return self;
}

- (void)setupBackground{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
}

- (void)setupTextview{
    CGFloat leftBorder   = 4;
    CGFloat topBorder    = 50;
    CGFloat rightBorder  = 4;
    CGFloat bottomBorder = 4;
    
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
    NSLog(@"COLOUR: %@", kFZZWhiteTextColor());
    [_textView setTextColor:kFZZWhiteTextColor()];
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
    UIButton *optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [UIImage imageNamed:@"optionsButtonImage"];
    
    [optionsButton setImage:image forState:UIControlStateNormal];
    
    [optionsButton addTarget:self action:@selector(optionsButtonHit) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth = image.size.width;
    
    CGFloat xOffsetFromRight = 15;
    CGFloat yOffsetFromTop = 15;
    
    CGFloat bufferSpace = 8;
    
    frame.origin.x = frame.size.width - (imageWidth + xOffsetFromRight + bufferSpace);
    frame.origin.y = yOffsetFromTop + bufferSpace;
    
    CGFloat frameDimension = MAX(imageWidth, imageHeight);
    
    frame.size.width = frameDimension + (bufferSpace * 2);
    frame.size.height = frameDimension + (bufferSpace * 2);
    
    NSLog(@"xy:(%f, %f) wh:(%f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    [optionsButton setFrame:frame];
    [self.contentView addSubview:optionsButton];
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
    
    [_textView setText:title];
    NSLog(@"event: <%@>", title);
    [_textView setNeedsDisplay];
}

@end
