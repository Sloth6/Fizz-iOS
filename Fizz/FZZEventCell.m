//
//  FZZEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 1/17/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZEventCell.h"
#import "FZZEvent.h"
#import "FZZMessage.h"
#import "FZZUser.h"

@implementation FZZEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
//        _prevLabel = [[UILabel alloc] initWithFrame:self.bounds];
//        _nextLabel = [[UILabel alloc] initWithFrame:self.bounds];
        
        _label.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:_label];
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_label setFrame:frame];
    [_label sizeToFit];
    [self setNeedsDisplay]; // force drawRect:
}

-(void)setEventCollapsed:(FZZEvent *)event{
    if (event == NULL){
        _label.text = @"Create A New Event";
        
        return;
    }
    
    // Text
    NSString *text = [event description];
    
    _label.text = text;
}

- (void)setEvent:(FZZEvent *)event {
    // Text
    NSString *text = [event description];
    
    _label.text = text;
}

@end
