//
//  FZZKeyboardNotificationCenter.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZKeyboardNotificationCenter.h"

static FZZKeyboardNotificationCenter *notificationCenter;

@interface FZZKeyboardNotificationCenter ()

@property id<FZZKeyboardManagedObject> firstResponderDelegate;

@end

@implementation FZZKeyboardNotificationCenter

+ (void)initialize{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notificationCenter = [[FZZKeyboardNotificationCenter alloc] init];
    });
}

- (id)init{
    self = [super init];
    
    if (self){
        [self setupKeyboard];
    }
    
    return self;
}

- (void)setupKeyboard{
    //set notification for when keyboard shows/hides
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

+ (void)updateFirstResponderAsTextInputDelegate:(id<FZZKeyboardManagedObject>)textInputDelegate{
    
    [notificationCenter setFirstResponderDelegate:textInputDelegate];
}

-(void)keyboardWillShow:(NSNotification *)note{
//    [_firstResponderDelegate keyboardWillShow:note];
}

-(void)keyboardWillHide:(NSNotification *)note{
//    [_firstResponderDelegate keyboardWillHide:note];
}

@end
