//
//  FZZUtilities.h
//  Fizz
//
//  Created by Andrew Sweet on 7/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

static float kFZZTimerDelay = 1.0;
static float kFZZMinPageScrollVelocity = 0.5;

extern NSString * const FZZ_CONTACTS_SAVED;
extern NSString * const FZZ_RELOADED_CHAT;

static NSString *kFZZScrollToMessagesNotification = @"kFZZScrollToMessagesNotification";
static NSString *kFZZPageUpdateNotification = @"kFZZPageUpdateNotification";

@interface FZZUtilities : NSObject

void runOnMainQueueWithoutDeadlocking(void (^block)(void));
UIImage *centeredCrop(UIImage *image);
UIImage *crop(UIImage *image, CGRect rect);

UIColor *kFZZWhiteTextColor();
UIColor *kFZZGrayTextColor();

UIColor *kFZZDefaultTopColor();
UIColor *kFZZDefaultBottomColor();

NSString *kFZZConfirmationCodeJustSentPrompt();

UIFont *kFZZBodyFont();
UIFont *kFZZSmallFont();
UIFont *kFZZLabelsFont();
UIFont *kFZZNameFont();
UIFont *kFZZHostNameFont();
UIFont *kFZZHostBodyFont();
UIFont *kFZZCapsulesFont();
UIFont *kFZZInputFont();
UIFont *kFZZHeadingsFont();
UIFont *kFZZPinInputFont();

CGFloat kFZZHorizontalMargin(); //4
CGFloat kFZZVerticalMargin(); //8
CGFloat kFZZRightMargin();

CGFloat kFZZHeadingBaselineToTop(); //120
//Line height is container around the text
CGFloat kFZZHeadingLineHeight(); //72

CGFloat kFZZHeadingMinFontSize();
CGFloat kFZZHeadingMaxFontSize();

CGFloat kFZZChatInputBoxInsetBottom();
CGFloat kFZZChatInputBoxInsetLeft();

CGFloat kFZZGuestListLineHeight(); // 40
CGFloat kFZZGuestListPeak();
CGFloat kFZZGuestListOffset();

CGFloat kFZZInputRowHeight(); //48

CGFloat kFZZMinChatCellHeight(); // 48

CGFloat kFZZBodyLineHeight(); //24

//"add a comment" etc.
CGFloat kFZZTopTextTopPadding(); // 24
CGFloat kFZZMessageTopPadding(); // 16
CGFloat kFZZCapsuleTopPadding(); // 12

CGFloat kFZZMessagesExtraPeak();

CGFloat kFZZPinPadding(); //16

CGFloat kFZZInviteViewPeak();
CGFloat kFZZInviteConfirmButtonDiameter(); // 32

CGFloat kFZZTextInputBottomPadding(); // 8

CGFloat kFZZCancelInviteFacebookFriendsButton(); // 9

float kFZZButtonBuffer();

+(CGRect)getKeyboardBoundsFromNote:(NSNotification *)note;

//UIFont *kFZZHeadingsFontWithScale(CGFloat scale);

+(NSString *)formatPhoneNumber:(NSString *)phoneNumber;

@end
