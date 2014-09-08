//
//  FZZUtilities.h
//  Fizz
//
//  Created by Andrew Sweet on 7/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

static float kFZZTimerDelay = 1.0;

@interface FZZUtilities : NSObject

void runOnMainQueueWithoutDeadlocking(void (^block)(void));
UIImage *centeredCrop(UIImage *image);
UIImage *crop(UIImage *image, CGRect rect);

UIColor *kFZZWhiteTextColor();
UIColor *kFZZGrayTextColor();

UIFont *kFZZBodyFont();
UIFont *kFZZSmallFont();
UIFont *kFZZLabelsFont();
UIFont *kFZZHostNameFont();
UIFont *kFZZHostBodyFont();
UIFont *kFZZCapsulesFont();
UIFont *kFZZInputFont();
UIFont *kFZZHeadingsFont();
UIFont *kFZZPinInputFont();

CGFloat kFZZHorizontalMargin(); //4
CGFloat kFZZVerticalMargin(); //8

CGFloat kFZZHeadingBaselineToTop(); //120
//Line height is container around the text
CGFloat kFZZHeadingLineHeight(); //72
CGFloat kFZZGuestListLineHeight(); // 40

CGFloat kFZZColumnWidth(); //48

CGFloat kFZZBodyLineHeight(); //24

//"add a comment" etc.
CGFloat kFZZTopTextTopPadding(); // 24
CGFloat kFZZMessageTopPadding(); // 16
CGFloat kFZZCapsuleTopPadding(); // 12

CGFloat kFZZPinPadding(); //16

CGFloat kFZZInviteConfirmButtonDiameter(); // 32

CGFloat kFZZTextInputBottomPadding(); // 8

CGFloat kFZZCancelInviteFacebookFriendsButton(); // 9


+(CGRect)getKeyboardBoundsFromNote:(NSNotification *)note;

//UIFont *kFZZHeadingsFontWithScale(CGFloat scale);

@end