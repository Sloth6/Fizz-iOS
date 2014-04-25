//
//  FZZEventDetailViewDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZEvent.h"

@class FZZEventStreamViewController;

@interface FZZEventDetailViewDelegate : NSObject
    <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UIView *viewForm;
@property (nonatomic, retain) UITextView *chatBox;

@property (strong, nonatomic) FZZEvent *event;
@property (strong, nonatomic) FZZEventStreamViewController *esvc;

- (void)setupViewForm;
- (void)setupKeyboard;
- (void)popView;

@end