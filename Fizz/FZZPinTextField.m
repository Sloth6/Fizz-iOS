//
//  FZZPinTextField.m
//  Fizz
//
//  Created by Andrew Sweet on 8/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZPinTextField.h"
#import "FZZPinNumberLabel.h"
#import "FZZInputVerificationCodeViewController.h"

#import "FZZUtilities.h"

#import "FZZChatScreenTableViewController.h"

@interface FZZPinTextField ()

@property UITextField *textField;
@property UIView *pinView;
@property NSInteger numberOfCharacters;

@property NSMutableArray *labels;

@property NSTimer *timer;

@property BOOL shouldSend;

@property (nonatomic) FZZInputVerificationCodeViewController *ivcvc;

@end

@implementation FZZPinTextField

- (id)initWithFrame:(CGRect)frame andNumberOfCharacters:(NSInteger)numberOfCharacters
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _shouldSend = NO;
        
        CGRect hiddenFrame = CGRectMake(0, 0, -abs(frame.size.width), -abs(frame.size.height));
        
        _textField = [[UITextField alloc] initWithFrame:hiddenFrame];
        [self addSubview:_textField];
        _textField.delegate = self;
        
        [_textField setKeyboardAppearance:UIKeyboardAppearanceDark];
        [_textField setKeyboardType:UIKeyboardTypeNumberPad];
        [_textField setReturnKeyType:UIReturnKeyDone];
        
        _pinView = [[UIView alloc] initWithFrame:frame];
        _numberOfCharacters = numberOfCharacters;
        
        _labels = [[NSMutableArray alloc] init];
        
        [self setupPinLabels];
    }
    return self;
}

- (void)setIVCVC:(FZZInputVerificationCodeViewController *)ivcvc{
    _ivcvc = ivcvc;
}

- (void)startTimer{
    [self cancelTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kFZZTimerDelay target:self selector:@selector(timerComplete) userInfo:nil repeats:NO];
}

- (void)cancelTimer{
    [_timer invalidate];
}

- (void)timerComplete{
    NSString *code = [_textField text];
    
    [_ivcvc sendCode:code];
}

- (BOOL)validInputString:(NSString *)string{
    // Check that string contains only numbers
    NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:string];
    
    return [_NumericOnly isSupersetOfSet: myStringSet];
}

- (void)clearText{
    [_textField setText:@""];
    
    [_labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZPinNumberLabel *label = obj;
        
        [label setSymbol:@""];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (![self validInputString:string]) return NO;
    
    NSInteger stringLength = [[_textField text] length];
    
    NSInteger fullStringLength = stringLength + [string length] - range.length;
    
    
    // Queue up auto send
    if (!_shouldSend && fullStringLength == _numberOfCharacters){
        
        NSLog(@"START TIMER 1");
        _shouldSend = YES;
        [self startTimer];
    }
    
    // Cancel autosend
    else if (_shouldSend && fullStringLength < _numberOfCharacters){
        
        NSLog(@"CANCEL TIMER");
        
        _shouldSend = NO;
        [self cancelTimer];
    }
    
    if (stringLength > _numberOfCharacters || range.location >= _numberOfCharacters){
        NSString *subString = [[_textField text] substringToIndex:_numberOfCharacters];
        
        [_textField setText:subString];
        return NO;
    }
    
    if (string.length > 0){
        for (int i = 0; i < string.length; ++i){
            FZZPinNumberLabel *label = [_labels objectAtIndex:range.location + i];
            
            NSRange symbolRange = NSMakeRange(i, 1);
            
            NSString *symbol = [string substringWithRange:symbolRange];
            
            [label setSymbol:symbol];
        }
        
        for (int i = string.length; i < range.length; ++i){
            FZZPinNumberLabel *label = [_labels objectAtIndex:range.location + i];
            
            [label setSymbol:@""];
        }
    } else {
        for (int i = 0; i < range.length; ++i){
            FZZPinNumberLabel *label = [_labels objectAtIndex:range.location + i];
            
            [label setSymbol:@""];
        }
    }
    
    return YES;
}

- (BOOL)becomeFirstResponder{
    NSLog(@"%@ FIRST", _textField);
    
    return [_textField becomeFirstResponder];
}

- (void)setupPinLabels{
    [_labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *label = obj;
        
        [label removeFromSuperview];
    }];
    
    _labels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _numberOfCharacters; ++i){
        CGRect viewBounds = self.bounds;
        
        CGFloat width = viewBounds.size.width/_numberOfCharacters;
        CGFloat height = viewBounds.size.height;
        CGFloat x = i * width;
        CGFloat y = 0;
        
        CGRect frame = CGRectMake(x, y, width, height);
        
        FZZPinNumberLabel *pinLabel = [[FZZPinNumberLabel alloc] initWithFrame:frame];
        pinLabel.label.textAlignment = NSTextAlignmentCenter;
        
        [_labels addObject:pinLabel];
        
        [self addSubview:pinLabel];
    }
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
