//
//  FZZUtilities.m
//  Fizz
//
//  Created by Andrew Sweet on 7/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZUtilities.h"

@implementation FZZUtilities

+ (void)initialize{
//    kFZZEventFont = [UIFont fontWithName:@"Futura-Heavy"
//                                    size:38];
    
//    kFZZGrayTextColor = [UIColor whiteColor];//[UIColor colorWithWhite:0.9 alpha:0.7];
//    kFZZWhiteTextColor = [UIColor redColor];//[UIColor colorWithWhite:1.0 alpha:0.98];
}

NSString *kFZZConfirmationCodeJustSentPrompt(){
    return @"enter the code we just sent you";
}

UIFont *kFZZHeadingsFont(){
    return [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:68];
//    return [UIFont fontWithName:@"Futura-MediumItalic" size:68];
}

UIFont *kFZZPinInputFont(){
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:68];
//    return [UIFont fontWithName:@"FuturaStd-Light" size:68];
}

UIFont *kFZZBodyFont(){
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
//    return [UIFont fontWithName:@"Futura-Medium" size:18];
}

// Guest List
UIFont *kFZZSmallFont(){
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
//    return [UIFont fontWithName:@"Futura-Medium" size:14];
}

UIFont *kFZZLabelsFont(){
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:10*2];
//    return [UIFont fontWithName:@"FuturaStd-Book" size:10*2];
}

UIFont *kFZZHostNameFont(){
    return [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:10];
//    return [UIFont fontWithName:@"FuturaStd-BoldOblique" size:10];
}

UIFont *kFZZHostBodyFont(){
    return [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:18];
//    return [UIFont fontWithName:@"Futura-MediumItalic" size:18];
}

UIFont *kFZZCapsulesFont(){
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
//    return [UIFont fontWithName:@"FuturaStd-Book" size:10*2];
}

UIFont *kFZZInputFont(){
    return [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:10*2];
//    eturn [UIFont fontWithName:@"Futura-MediumItalic" size:10*2];
}

UIColor *kFZZWhiteTextColor(){
    return [UIColor colorWithWhite:1.0 alpha:0.98];
}

UIColor *kFZZGrayTextColor(){
    return [UIColor colorWithWhite:1.0 alpha:0.5];
}

UIFont *kFZZRegularFontWithSize(CGFloat size){
    return [UIFont fontWithName:@"Futura-Medium" size:size];
}

UIFont *kFZZItalicFontWithSize(CGFloat size){
    return [UIFont fontWithName:@"Futura-MediumItalic" size:size];
}

UIFont *kFZZHeavyFontWithSize(CGFloat size){
    return [UIFont fontWithName:@"Futura-MediumItalic" size:size];
}

CGFloat kFZZHorizontalMargin() {return 4;}
CGFloat kFZZVerticalMargin() {return 8;}
CGFloat kFZZRightMargin() {return kFZZVerticalMargin();}

CGFloat kFZZHeadingBaselineToTop() {return 120;}
//Line height is container around the text
CGFloat kFZZHeadingLineHeight() {return 72;}

CGFloat kFZZHeadingMinFontSize() {return kFZZHeadingMaxFontSize()/2.0;}
CGFloat kFZZHeadingMaxFontSize() {return kFZZHeadingLineHeight();}

CGFloat kFZZChatInputBoxInsetBottom() {return kFZZVerticalMargin();}
CGFloat kFZZChatInputBoxInsetLeft() {return -6 + kFZZHorizontalMargin();}

CGFloat kFZZGuestListLineHeight() {return 24;}

CGFloat kFZZGuestListPeak() {return (3 * kFZZGuestListLineHeight())
                                + (1.0/2.0 * kFZZGuestListLineHeight());}

CGFloat kFZZGuestListOffset() {return 44;}

CGFloat kFZZInviteListLineHeight() {return 40;}

CGFloat kFZZInputRowHeight() {return 48;}

CGFloat kFZZMinChatCellHeight() {return 48;}

CGFloat kFZZBodyLineHeight() {return 24;}

//"add a comment" etc.
CGFloat kFZZTopTextTopPadding() {return 24;}
CGFloat kFZZMessageTopPadding() {return 16;}
CGFloat kFZZCapsuleTopPadding() {return 12;}

CGFloat kFZZInviteConfirmButtonDiameter() {return 32;}

CGFloat kFZZTextInputBottomPadding() {return 8;}

CGFloat kFZZCancelInviteFacebookFriendsButton() {return 9;}

CGFloat kFZZPinPadding() {return 16;}

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

UIImage* crop(UIImage *image, CGRect rect) {
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [image scale]);
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    UIImage *cropped_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropped_image;
}

UIImage *centeredCrop(UIImage *image){
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth  = image.size.width;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth  = screenRect.size.width;
    
    screenRect.origin.y = (imageHeight/2) - (screenHeight/2);
    screenRect.origin.x = (imageWidth/2) - (screenWidth/2);
    
    return crop(image, screenRect);
}

+(CGRect)getKeyboardBoundsFromNote:(NSNotification *)note{
    CGRect _keyboardEndFrame;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&_keyboardEndFrame];
    
    // (x,y) is irrelevant for the use
    return CGRectMake(0, 0, _keyboardEndFrame.size.width, _keyboardEndFrame.size.height);
}

float kFZZButtonBuffer(){
    return 10;
}

@end
