//
//  FZZInviteSearchBarTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteSearchBarTableViewCell.h"
#import "FZZCustomPlaceholderTextField.h"
#import "FZZUtilities.h"
#import "FZZInvitationViewsTableViewController.h"

@interface FZZInviteSearchBarTableViewCell ()

@property (nonatomic) BOOL shouldDrawLine;

@property (strong, nonatomic) FZZCustomPlaceholderTextField *textField;
@property (strong, nonatomic) FZZInvitationViewsTableViewController *ivtvc;

@end

@implementation FZZInviteSearchBarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupSearchBar];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
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

- (void)setupSearchBar{
    [_textField removeFromSuperview];
    _textField = [[FZZCustomPlaceholderTextField alloc] initWithFrame:self.frame];
    
    UIFont *font = kFZZInputFont();
    
    [_textField setFont:font];
    
    [_textField setTextColor:kFZZWhiteTextColor()];
    [_textField setPlaceholderTextColor:kFZZGrayTextColor()];
    
    NSString *placeholder = @"search for a friend to invite";
    
    [_textField setPlaceholder:placeholder];
    [_textField setText:placeholder];
    
    [_textField setEnabled:NO];
    [_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [_textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_textField setKeyboardType:UIKeyboardTypeAlphabet];
    
    [_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    [self addSubview:_textField];
}

- (UITextField *)textField{
    return _textField;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawLine{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat cellWidth = self.frame.size.width;
    
    CGFloat xInset = 4;
    
    CGFloat x1 = xInset;
    CGFloat x2 = cellWidth - xInset;
    
    CGFloat y = self.frame.size.height;
    
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
