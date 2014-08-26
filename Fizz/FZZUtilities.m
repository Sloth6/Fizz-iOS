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

UIFont *kFZZHeadingsFont(){
    return [UIFont fontWithName:@"Futura-MediumItalic" size:68];
}

UIFont *kFZZBodyFont(){
    return [UIFont fontWithName:@"Futura-Medium" size:18];
}

// Guest List
UIFont *kFZZSmallFont(){
    return [UIFont fontWithName:@"Futura-Medium" size:14];
}

UIFont *kFZZLabelsFont(){
    return [UIFont fontWithName:@"FuturaStd-Book" size:10*2];//-Bold
}

UIFont *kFZZHostNameFont(){
    return [UIFont fontWithName:@"FuturaStd-BoldOblique" size:10];//boldItalicFontWithFont([UIFont fontWithName:@"Futura Std" size:10]);
}

UIFont *kFZZHostBodyFont(){
    return [UIFont fontWithName:@"Futura-MediumItalic" size:18];
}

UIFont *kFZZCapsulesFont(){
    return [UIFont fontWithName:@"FuturaStd-Book" size:10*2];//-Book
}

UIFont *kFZZInputFont(){
    return [UIFont fontWithName:@"Futura-MediumItalic" size:10*2];
}

UIColor *kFZZWhiteTextColor(){
    return [UIColor colorWithWhite:1.0 alpha:0.98];
}

UIColor *kFZZGrayTextColor(){
    return [UIColor colorWithWhite:0.9 alpha:0.76];
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

UIFont *boldFontWithFont(UIFont *font)
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

UIFont *boldItalicFontWithFont(UIFont *font)
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold||UIFontDescriptorTraitItalic];
    
    return [UIFont fontWithDescriptor:fontD size:0];
}

UIFont *italicFontWithFont(UIFont *font)
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    
    return [UIFont fontWithDescriptor:fontD size:0];
}

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
    CGFloat screenHeight = screenRect.size.height * 2;
    CGFloat screenWidth  = screenRect.size.width * 2;
    
    screenRect.origin.y = (imageHeight/2) - (screenHeight/2);
    screenRect.origin.x = (imageWidth/2) - (screenWidth/2);
    
    return crop(image, screenRect);
}

@end
