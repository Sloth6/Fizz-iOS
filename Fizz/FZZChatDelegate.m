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
#import "FZZEventsViewController.h"
#import "FZZInviteViewController.h"

#import "FZZEnterMessagePrototypeViewController.h"

#import "FZZNavIcon.h"

#import "FZZBounceTableView.h"

#import "FZZExpandedEventCell.h"
#import "FZZExpandedVerticalTableViewController.h"



@interface FZZChatDelegate ()

@end

@implementation FZZChatDelegate

- (id)init
{
//    NSLog(@"<<2<<");
    self = [super init];
    if (self) {
        // Custom initialization
        
//        _placeholder = YES;
//        _nibTextCellLoaded = [[NSMutableSet alloc] init];
//        
//        _didGetDimensionsFromCell = NO;
//        
//        [self setupKeyboard];
//        
//        [self setupView];
//        
        
        //        [[self collectionView] scrollToItemAtIndexPath:
        //         [NSIndexPath indexPathForItem:kFZZNumCellsBeforeMessages inSection:0]
        //                                      atScrollPosition:UICollectionViewScrollPositionTop
        //                                              animated:NO];
        
    }
    
//    NSLog(@">>2>>");
    
    return self;
}

@end
