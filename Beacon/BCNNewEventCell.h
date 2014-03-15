//
//  BCNNewEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCNInviteViewController;

@interface BCNNewEventCell : UICollectionViewCell <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property UITextView *textView;
@property float lineHeight;
@property UISwitch *toggleSecret;
@property UILabel *label;

@property BCNInviteViewController *ivc;

@end
