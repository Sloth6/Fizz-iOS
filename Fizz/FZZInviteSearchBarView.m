//
//  FZZInviteSearchBarView.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteSearchBarView.h"
#import "FZZCustomPlaceholderTextField.h"
#import "FZZUtilities.h"

@interface FZZInviteSearchBarView ()

@property (nonatomic) BOOL shouldDrawLine;

@property (strong, nonatomic) FZZCustomPlaceholderTextField *textField;
@property (nonatomic) UIButton *sendButton;

@end

@implementation FZZInviteSearchBarView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        // Initialization code
        [self setupSendButton];
        [self setupSearchBar];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _shouldDrawLine = NO;
    }
    
    return self;
}

-(void)setShouldDrawLine:(BOOL)shouldDrawLine{
    if (_shouldDrawLine != shouldDrawLine){
        _shouldDrawLine = shouldDrawLine;
        [self setNeedsDisplay];
    }
}

- (void)setupSendButton{
    CGRect frame = self.bounds;
    
    CGFloat buttonWidth = 50; //Magic Number
    
    frame.origin.x = frame.size.width - buttonWidth - kFZZHorizontalMargin();
    frame.size.width = buttonWidth;
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_sendButton setBackgroundColor:[UIColor redColor]];
    
    [_sendButton setFrame:frame];
    [_sendButton setTitle:@"SEND" forState:UIControlStateNormal];
    [[_sendButton titleLabel] setFont:kFZZCapsulesFont()];
    [_sendButton setTitleColor:kFZZWhiteTextColor() forState:UIControlStateApplication];
    
    [self addSubview:_sendButton];
}

- (void)setupSearchBar{
    [_textField removeFromSuperview];
    
    CGFloat buttonWidth = [_sendButton frame].size.width;
    
    CGRect frame = self.bounds;
    frame.origin.x += kFZZHorizontalMargin();
    frame.size.width -= kFZZHorizontalMargin() + buttonWidth;
    
    _textField = [[FZZCustomPlaceholderTextField alloc] initWithFrame:frame];
    
    UIFont *font = kFZZInputFont();
    
    [_textField setFont:font];
    
    [_textField setTextColor:kFZZWhiteTextColor()];
    [_textField setPlaceholderTextColor:kFZZGrayTextColor()];
    
    NSString *placeholder = @"search for a friend to invite";
    
    [_textField setPlaceholder:placeholder];
    [_textField setText:placeholder];
    
    [_textField setBackgroundColor:[UIColor blueColor]];
    
    [_textField setEnabled:YES];
    [_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [_textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_textField setKeyboardType:UIKeyboardTypeAlphabet];
    
    [_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    
    [self addSubview:_textField];
}

- (UITextField *)textField{
    return _textField;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)drawLine{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat cellWidth = self.bounds.size.width;
    
    CGFloat xInset = 4;
    
    CGFloat x1 = xInset;
    CGFloat x2 = cellWidth - xInset;
    
    CGFloat y = self.bounds.size.height;
    
    UIColor *grayColor = kFZZGrayTextColor();
    
    CGFloat whiteness;
    CGFloat alpha;
    
    [grayColor getWhite:&whiteness alpha:&alpha];
    
    [UIColor colorWithWhite:whiteness alpha:alpha];
    
    CGContextSetStrokeColorWithColor(context, [kFZZGrayTextColor() CGColor]);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, x1, y);
    CGContextAddLineToPoint(context, x2, y);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (_shouldDrawLine){
        [self drawLine];
    }
}

@end
