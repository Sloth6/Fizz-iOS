//
//  BCNBackspaceResignTextView.m
//  Fizz
//
//  Created by Andrew Sweet on 3/19/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNBackspaceResignTextView.h"
#import "BCNEventStreamViewController.h"

@interface BCNBackspaceResignTextView ()

@property BCNEventStreamViewController *esvc;
@property (strong, nonatomic) UITextView *placeholderTextView;

@property BOOL isPlaceholder;

@end

@implementation BCNBackspaceResignTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        // Initialization code
        _placeholderTextView = [[UITextView alloc] initWithFrame:bounds];
        [_placeholderTextView setUserInteractionEnabled:NO];
        [_placeholderTextView setBackgroundColor:[UIColor clearColor]];
        _placeholderTextView.textColor = [UIColor lightGrayColor];
        [self setBackgroundColor:[UIColor clearColor]];
        
        for (id view in [self subviews]) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                [self.inputView addSubview:_placeholderTextView];
                break;
            }
        }
        
        [_placeholderTextView setText:@"PENIS"];
        
        [self showPlaceholder:YES];
        
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(myTextDidChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
    }
    return self;
}

-(void)setPlaceholderText:(NSString *)placeholderText{
    [_placeholderTextView setText:placeholderText];
}

- (void)deleteBackward
{
    [super deleteBackward];
    
    if ([self.text isEqualToString:@""]){
        if (_esvc != NULL){
            // Resign first responder status, update interface
            [_esvc exitNewEventPrompt:self];
            [self showPlaceholder:YES];
        } else {
            [self resignFirstResponder];
        }
    }
}

-(void)setESVC:(BCNEventStreamViewController *)esvc{
    _esvc = esvc;
}

-(void)setFont:(UIFont *)font{
    [super setFont:font];
    [_placeholderTextView setFont:font];
}

-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled{
    [_placeholderTextView setUserInteractionEnabled:NO];
}

-(void)setText:(NSString *)text{
    if ([text length] == 0){
        [self showPlaceholder:YES];
    } else {
        if (_isPlaceholder){
            [self showPlaceholder:NO];
        }
    }
}

- (void)showPlaceholder:(BOOL)shouldShow{
    _isPlaceholder = shouldShow;
    [_placeholderTextView setHidden:!shouldShow];
}

// Implement the method which is called when our text changes:
- (void)myTextDidChange
{
    NSLog(@"<%@>", self.text);
    
    // Change the background color
    if (_isPlaceholder){ // Placeholder is already on
        NSLog(@"It's on");
        if ([self.text length] > 0){
            NSLog(@"TURN IT OFF");
            [self showPlaceholder:NO];
        }
    } else { // Placeholder is off
        NSLog(@"It's off");
        if ([self.text length] == 0){
            NSLog(@"TURN IT ON");
            [self showPlaceholder:YES];
        }
    }
}

- (void)dealloc
{
    // Stop listening when deallocating
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
