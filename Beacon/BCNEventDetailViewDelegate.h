//
//  BCNEventDetailViewDelegate.h
//  Beacon
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNEvent.h"

@class BCNEventStreamViewController;

@interface BCNEventDetailViewDelegate : NSObject
    <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UIView *viewForm;
@property (nonatomic, retain) UITextView *chatBox;
@property (nonatomic, retain) UIButton *chatButton;

@property (strong, nonatomic) BCNEvent *event;
@property (strong, nonatomic) BCNEventStreamViewController *esvc;

- (void)setupViewForm;
- (void)setupKeyboard;
- (void)popView;

@end