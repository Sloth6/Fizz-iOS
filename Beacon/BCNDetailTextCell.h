//
//  BCNDetailTextCell.h
//  Beacon
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCNDetailTextCell : UITableViewCell

@property IBOutlet UILabel *label;
@property IBOutlet UIImageView *imageView;

+ (CGSize)getTextBoxForText:(NSString *)text withLabelWidth:(float)labelWidth;

@end
