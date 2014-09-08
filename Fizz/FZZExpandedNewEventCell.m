//
//  FZZExpandedNewEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZExpandedNewEventCell.h"
#import "FZZAppDelegate.h"
#import "FZZUtilities.h"

#import "FZZTextViewWithPlaceholder.h"

static float kFZZBrightScreenAlpha;
static float kFZZDarkScreenAlpha;

@interface FZZExpandedNewEventCell ()

@property (strong, nonatomic) UIButton *sendInviteButton;
@property BOOL isSetup;

@property UIImageView *imageView;

@end

@implementation FZZExpandedNewEventCell

+ (void)initialize{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        kFZZBrightScreenAlpha = 0.9;
        kFZZDarkScreenAlpha = 0.5;
    });
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isSetup = NO;
        [self setupImageView];
        
        [self setupNewEventTextView];
    }
    return self;
}

- (void)setupImageView{
    CGRect window = [UIScreen mainScreen].bounds;
    
    _imageView = [[UIImageView alloc] initWithFrame:window];
    UIImage *image = [UIImage imageNamed:@"testImage"];
    [_imageView setAlpha:kFZZBrightScreenAlpha];
    
    image = centeredCrop(image);
    
    [_imageView setImage:image];
    [self.contentView addSubview:_imageView];
}

- (void)setupNewEventTextView{
    
    if (!_isSetup){
        _isSetup = YES;
        
        // Hard coded value, should be fine for these purposes
        float keyboardHeight = 216;
        
        float hInset  = 50;
        float hOutset = hInset;
        float vInset  = 60;
        float vOutset = 50 + keyboardHeight;
        
        float sWidth  = [UIScreen mainScreen].bounds.size.width;
        float sHeight = [UIScreen mainScreen].bounds.size.height;
        
        float x = hInset;
        float width = sWidth - x - hOutset;
        
        float y = vInset;
        float height = sHeight - y - vOutset;
        
        _textView = [[FZZTextViewWithPlaceholder alloc] initWithFrame:CGRectMake(x, y, width, height)];
        
        [_textView setFont:kFZZHeadingsFont()];//[UIFont fontWithName:@"HelveticaNeue-Light" size:38]];
        
        [self addSubview:_textView];
        
        [_textView textContainer].maximumNumberOfLines = 3;
        
        [_textView setBackgroundColor:[UIColor clearColor]];
    }
    
    [_textView setEditable:NO];
    [_textView setScrollEnabled:NO];
    [_textView setUserInteractionEnabled:NO];
    [_textView setBackgroundColor:[UIColor clearColor]];
    
    // Enable the placeholder text
    [_textView setText:@""];
    [_textView deleteBackward];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
