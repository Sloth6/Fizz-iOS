//
//  FZZParallaxCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZParallaxCell.h"
#import "FZZTimelineEventCell.h"

static const float kPixelShown = 40;
static CGRect textRect;
static BOOL preparedClass = NO;

@interface FZZParallaxCell ()

@end

@implementation FZZParallaxCell

+ (void)prepareClass{
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        FZZTimelineEventCell *timelineCell = [[FZZTimelineEventCell alloc] init];
        
        textRect = CGRectMake(70, 200, 200, 200);// timelineCell.textView.frame;
        
        _textView = [[UITextView alloc] initWithFrame:textRect];
        [_textView setText:@"Hello world!"];
        [_textView setBackgroundColor:[UIColor clearColor]];
        
        NSLog(@"SO MANY");
        [self addSubview:_textView];
    }
    return self;
}

+(float)parallaxOffset{
    return kPixelShown;
}

-(void)setProgress:(float)progress{
    
//    if (progress < 0) progress = 0;
//    
//    progress -= 0.5;
//    
//    if (progress < 0) progress += 1;

    [_textView setText:[NSString stringWithFormat:@"%f", progress]];
    
    float cellY = [UIScreen mainScreen].bounds.size.height - (2*[FZZParallaxCell parallaxOffset]);
    
    if (progress < 0.5){
        
        float initPos = kPixelShown - textRect.size.height;
        float y = (progress/0.5) * (textRect.origin.y) - ((0.5 - progress) * initPos);
        
        CGRect frame = CGRectMake(textRect.origin.x - (progress*20), y, textRect.size.width, textRect.size.height);
        
        [_textView setFrame:frame];
    } else {
        float initPos = textRect.origin.y;
        float y = (initPos * (1.0 - (2*(progress-0.5)))) +
            (((progress - 0.5)/0.5) * (cellY - kPixelShown));
        
        CGRect frame = CGRectMake(textRect.origin.x - (progress*20), y, textRect.size.width, textRect.size.height);
        
        [_textView setFrame:frame];
    }
}

@end
