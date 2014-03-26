//
//  BCNManageFriendCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNManageFriendCell.h"

@interface BCNManageFriendCell ()

@end

@implementation BCNManageFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        float cellWidth = self.bounds.size.width;
        float cellHeight = self.bounds.size.height;
        
        float midY = cellHeight / 2.0;
        float picDimension = 52;
        float picInset = 10;
        
        CGRect frame = CGRectMake(picInset, midY - (picDimension/2.0), picDimension, picDimension);
        _profilePic = [[UIImageView alloc] initWithFrame:frame];
        
        
        float leftInset = picDimension + picInset + 10;
        
        CGRect nameFrame = CGRectMake(leftInset, 0, cellWidth - leftInset, cellHeight);
        
        _friendName = [[UILabel alloc] initWithFrame:nameFrame];
        [self addSubview:_friendName];
        [_friendName setFont:[UIFont fontWithName:@"HelveticaNeue" size:17]];
        [_friendName setTextColor:[UIColor blackColor]];
    
    }
    return self;
}

@end
