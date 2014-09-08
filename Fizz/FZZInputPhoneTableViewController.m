//
//  FZZInputPhoneTableViewController.m
//  Fizz
//
//  Created by Andrew Sweet on 8/27/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInputPhoneTableViewController.h"

#import "PhoneNumberFormatter.h"
#import "FZZAjaxPostDelegate.h"

#import "FZZInputPhoneTableViewCell.h"

#import "FZZInputVerificationCodeViewController.h"
#import "FZZUtilities.h"

#import "FZZAppDelegate.h"

@interface FZZInputPhoneTableViewController ()

@property FZZInputVerificationCodeViewController *ivcvc;

@property UITextField *firstNameTextField;
@property UITextField *lastNameTextField;
@property UITextField *cellPhoneTextField;

@property NSTimer *timer;

@property CGPoint topViewOffsetPoint;

@property UIView *topView;

@property PhoneNumberFormatter *phoneNumberFormat;
@property (strong, nonatomic) NSString *country;

@property BOOL hasSubmitted;

@end

@implementation FZZInputPhoneTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _phoneNumberFormat = [[PhoneNumberFormatter alloc] init];
        
        _hasSubmitted = NO;
        
        // Custom initialization
        [[self tableView] setScrollEnabled:NO];
        
//        [[self tableView] registerNib:[UINib nibWithNibName:@"FZZInputPhoneTopCell" bundle:nil] forCellReuseIdentifier:@"topCell"];
        
        [[self tableView] registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [[self tableView] registerNib:[UINib nibWithNibName:@"FZZInputPhoneTableViewCell" bundle:nil] forCellReuseIdentifier:@"phoneInputCell"];
        
        [[self tableView] setBackgroundColor:[UIColor blackColor]];
        
        [[self tableView] setSeparatorColor:[UIColor clearColor]];
        
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
        
        //set notification for when keyboard shows/hides
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    }
    return self;
}

- (void)performKeyboardWillShow:(NSNotification *)note{
    // get keyboard size and loction
    CGRect keyboardBounds = [FZZUtilities getKeyboardBoundsFromNote:note];
    
    // get the height since this is the main value that we need.
    NSInteger kbSizeH = keyboardBounds.size.height;
    
    _topViewOffsetPoint = CGPointMake(0, kbSizeH);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    NSLog(@"Scroll 2");
    [[self tableView] setContentOffset:_topViewOffsetPoint];
    
    [[self tableView] setScrollEnabled:YES];
    
    CGRect frame = _topView.frame;
    
    frame.origin.y -= [UIScreen mainScreen].bounds.size.height/2;
    
    [_topView setFrame:frame];
    
    [_ivcvc setKeyboardHeight:kbSizeH];
    
    // commit animations
    [UIView commitAnimations];
    
    [[self tableView] setScrollEnabled:NO];
}

- (void)keyboardWillShow:(NSNotification *)note{
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        [self performKeyboardWillShow:note];
    });
}

- (void)setInformationCellActive:(BOOL)isActive shouldAnimate:(BOOL)isAnimated{
    _hasSubmitted = !isActive;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    FZZInputPhoneTableViewCell *cell = (FZZInputPhoneTableViewCell *)[[self tableView] cellForRowAtIndexPath:indexPath];
    
    [[cell contentView] setUserInteractionEnabled:isActive];
    
    if (isActive){
        if (isAnimated){
            [UIView animateWithDuration:0.3 animations:^(void) {
                [cell setAlpha:1.0];
            }];
        } else {
            [cell setAlpha:1.0];
        }
        
        [[self tableView] setContentOffset:_topViewOffsetPoint animated:isAnimated];
        
        [_cellPhoneTextField becomeFirstResponder];
    } else {
        if (isAnimated){
            [UIView animateWithDuration:0.3 animations:^(void) {
                [cell setAlpha:0.5];
            }];
        } else {
            [cell setAlpha:0.5];
        }
        
        [self scrollToBottomAnimated:isAnimated];
    }
}

- (void)scrollToBottomAnimated:(BOOL)isAnimated{
    NSInteger numberOfCells = [[self tableView] numberOfRowsInSection:0];
    
    NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForRow:numberOfCells-1 inSection:0];
    
    [[self tableView] scrollToRowAtIndexPath:lastCellIndexPath
                            atScrollPosition:UITableViewScrollPositionTop
                                    animated:isAnimated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1){
        [self setInformationCellActive:YES shouldAnimate:YES];
    }
}

- (void)finishPhoneSetup{
    if ([FZZAjaxPostDelegate postRegistration]){
        
        [_ivcvc textFieldBecomeFirstResponder];
        
        [self setInformationCellActive:NO shouldAnimate:YES];
        
//        FZZInputVerificationCodeViewController *ivcvc = [[FZZInputVerificationCodeViewController alloc] initWithNibName:@"FZZInputVerificationCodeViewController" bundle:nil];
//        
//        [[self navigationController] pushViewController:ivcvc animated:YES];
    } else {
        NSLog(@"Registration failed! Try again");
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self scrollToLoginModeIfNeedBe];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _country = @"us";
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(phoneChange)
     name:UITextFieldTextDidChangeNotification
     object:_cellPhoneTextField];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(nameChange)
     name:UITextFieldTextDidChangeNotification
     object:_firstNameTextField];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(nameChange)
     name:UITextFieldTextDidChangeNotification
     object:_lastNameTextField];
}

- (void)scrollToLoginModeIfNeedBe{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSNumber *hasRegistered = [pref objectForKey:@"didRegister"];
    
    BOOL didRegister = NO;
    
    if (hasRegistered != nil){
        didRegister = [hasRegistered boolValue];
    }
    
    if (didRegister){
        [self cancelTimer];
        
        [_cellPhoneTextField becomeFirstResponder];
        
        [self loadInformation];
        
        // Move to next view
        [_ivcvc textFieldBecomeFirstResponder];
        
        [self setInformationCellActive:NO shouldAnimate:YES];
    }
}

- (void)loadInformation{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    NSString *firstName = [pref objectForKey:@"firstName"];
    NSString *lastName = [pref objectForKey:@"lastName"];
    NSString *phoneNumber = [pref objectForKey:@"phoneNumber"];
    
    phoneNumber = [_phoneNumberFormat strip:phoneNumber];
    
    [_firstNameTextField setText:firstName];
    [_lastNameTextField setText:lastName];
    [_cellPhoneTextField setText:phoneNumber];
}

- (void)saveInformation{
    NSString *phoneNumber = _cellPhoneTextField.text;
    
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    phoneNumber = [NSString stringWithFormat:@"+%@", cleanedString];
    
    NSString *firstName = _firstNameTextField.text;
    NSString *lastName  = _lastNameTextField.text;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:phoneNumber forKey:@"phoneNumber"];
    [pref setObject:firstName forKey:@"firstName"];
    [pref setObject:lastName forKey:@"lastName"];
    [pref synchronize];
    
    [self finishPhoneSetup];
}

- (BOOL)isValidUSPhoneNumber:(NSString *)phoneNumber{
    
    // Not Using Strip incase strip decides to keep other characters
    NSString *digits = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    // require area code
    if ([digits length] < 10){
        NSLog(@"TOO SHORT");
        return NO;
    }
    
    NSString *testExtra = [NSString stringWithFormat:@"%@5", digits];
    
    NSString *formattedOneExtra = [_phoneNumberFormat format:testExtra
                                                  withLocale:_country];
    
    // It was unformatted, and thus unmatched as a correct number
    if ([digits length] == [phoneNumber length]){
        NSLog(@"NOT FORMATTED");
        return NO;
    }
    
    // Adding a digit still counted as a match for a valid substring
    // Meaning we're still missing digits until we have a valid match
    if ([testExtra length] != [formattedOneExtra length]){
        NSLog(@"PROPER FORMAT BUT NOT COMPLETE");
        return NO;
    }
    
    NSLog(@"VALID");
    
    return YES;
}

- (void)startTimer{
    [self cancelTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:kFZZTimerDelay target:self selector:@selector(timerComplete) userInfo:nil repeats:NO];
}

- (void)cancelTimer{
    [_timer invalidate];
}

- (void)timerComplete{
    [self saveInformationIfValid];
}

- (void)phoneChange {
    if (_hasSubmitted) return;
    
    _cellPhoneTextField.text = [_phoneNumberFormat format:_cellPhoneTextField.text withLocale:_country];
    
    if ([self isValidUSPhoneNumber:_cellPhoneTextField.text]){
        [self startTimer];
        return;
    }
    
    [self cancelTimer];
}

- (void)nameChange {
    if (_hasSubmitted) return;
    
    if ([self isValidUSPhoneNumber:_cellPhoneTextField.text]){
        [self startTimer];
        return;
    }
    
    [self cancelTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_hasSubmitted && indexPath.row == 1){
        return YES;
    }
    
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
        {
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat inputHeight  = [self tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            
            return screenHeight - inputHeight;
        }
            break;
            
        case 1:
        {
            // (bottom margin * 2) + (text views) + [label + spacing]
            // (8 + 8) + (48 * 3) + ???
            
            return 160 + 40;
        }
            break;
            
        case 2:
        {
            CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            
            CGFloat peekHeight = 60 + 95;
            
            return screenHeight - peekHeight;
        }
            break;
            
        default:
        {
            return [UIScreen mainScreen].bounds.size.height;
        }
            break;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
//    [self.tableView setScrollEnabled:YES];
//    [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [self.tableView setScrollEnabled:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
//    [self.tableView setScrollEnabled:YES];
//    [[self tableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    [self.tableView setScrollEnabled:NO];
}

- (void)failVerificationStep{
    [_ivcvc failVerificationStep];
}

//-(){
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.headIndent = 15; // <--- indention if you need it
//    paragraphStyle.firstLineHeadIndent = 15;
//    
//    paragraphStyle.lineSpacing = 7; // <--- magic line spacing here!
//    
//    NSDictionary *attrsDictionary =
//  @{ NSFontAttributeName: font, <-- if you need; & there are many more attrs
//     NSParagraphStyleAttributeName: paragraphStyle};
//    
//    self.textView.attributedText = [[NSAttributedString alloc] initWithString:@"Hello World over many lines!" attributes:attrsDictionary];
//}

- (void)setupTopCellText:(UITableViewCell *)cell{
    CGFloat x = kFZZHorizontalMargin();
    CGFloat y = kFZZHeadingBaselineToTop() -kFZZHeadingLineHeight();
    
    CGFloat width = cell.bounds.size.width;
    CGFloat height = cell.bounds.size.height;
    
    NSArray *lines = [NSArray arrayWithObjects:@"get your", @"friends", @"together", nil];
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    [[cell contentView] addSubview:_topView];
    
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = CGRectMake(x, y + (idx * kFZZHeadingLineHeight()), width, height);
        
        NSString *text = obj;
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        
        [label setTextColor:kFZZWhiteTextColor()];
        [label setFont:kFZZHeadingsFont()];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setUserInteractionEnabled:NO];
        [label setText:text];
        
        [label sizeToFit];
        
        [_topView addSubview:label];
    }];
    
//    NSString *text = @"get your friends together";
//    [textView setTextColor:kFZZWhiteTextColor()];
//    [textView setFont:kFZZHeadingsFont()];
//    [textView setBackgroundColor:[UIColor clearColor]];
//    [textView setUserInteractionEnabled:NO];
//    [textView setText:text];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(-6, -6, 0, 0);
    
//    [textView setTextContainerInset:insets];
    
//    NSLog(@"textView: %@, x: %f, y: %f, w: %f, h: %f", textView, x, y, rect.size.width, rect.size.height);
    
//    [[cell contentView] addSubview:textView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor clearColor];
            
            [[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
            [self setupTopCellText:cell];
            
            return cell;
        }
            break;
            
        case 1:
        {
            FZZInputPhoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"phoneInputCell" forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell formatText];
            
            _firstNameTextField = (UITextField *)cell.firstNameTextField;
            _lastNameTextField = (UITextField *)cell.lastNameTextField;
            _cellPhoneTextField = (UITextField *)cell.cellPhoneTextField;
            
            [_firstNameTextField setDelegate:self];
            [_lastNameTextField setDelegate:self];
            [_cellPhoneTextField setDelegate:self];
            
            [_firstNameTextField setReturnKeyType:UIReturnKeyNext];
            [_lastNameTextField setReturnKeyType:UIReturnKeyNext];
            [_cellPhoneTextField setReturnKeyType:UIReturnKeyDone];
            
            [_firstNameTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
            [_lastNameTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
            [_cellPhoneTextField setKeyboardAppearance:UIKeyboardAppearanceDark];
            
            [_cellPhoneTextField setKeyboardType:UIKeyboardTypeNumberPad];
            
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            
            cell.backgroundColor = [UIColor clearColor];
            
            _ivcvc = [[FZZInputVerificationCodeViewController alloc] initWithNibName:@"FZZInputVerificationCodeViewController" bundle:nil];
            
            [[_ivcvc view] setFrame:cell.bounds];
            
            [cell addSubview:[_ivcvc view]];
            
            return cell;
        }
            break;
    }
}

-(BOOL)saveInformationIfValid{
    _cellPhoneTextField.text = [_phoneNumberFormat format:_cellPhoneTextField.text withLocale:_country];
    
    NSString *firstName = [_firstNameTextField text];
    NSString *lastName = [_lastNameTextField text];
    
    BOOL validFirstName = [firstName length] > 0;
    BOOL validLastName  = [lastName length] > 0;
    BOOL validName = validFirstName && validLastName;
    
    NSLog(@"saving if possible...");
    
    if (validName && [self isValidUSPhoneNumber:_cellPhoneTextField.text]){
        NSLog(@"Saving.");
        
        [self saveInformation];
        
        return NO;
    } else {
        NSLog(@"Not saving.");
        
        NSString *alert;
        
        if (!validFirstName && !validLastName && [self isValidUSPhoneNumber:_cellPhoneTextField.text]){
            alert = @"Fill out all of the fields.";
            [_firstNameTextField becomeFirstResponder];
        } else if (!validFirstName && !validLastName){
            alert = @"Fill out your first and last name.";
            [_firstNameTextField becomeFirstResponder];
        } else if (!validFirstName){
            alert = @"Fill out your first name.";
            [_firstNameTextField becomeFirstResponder];
        } else if (!validLastName){
            alert = @"Fill out your last name.";
            [_lastNameTextField becomeFirstResponder];
        } else if ([_cellPhoneTextField.text length] == 0){
            alert = @"Fill out your cell phone number.";
            [_cellPhoneTextField becomeFirstResponder];
        } else {
            alert = @"Make sure your phone number is correct.";
            [_cellPhoneTextField becomeFirstResponder];
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:alert
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okay"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        return NO;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:_firstNameTextField]){
        [_lastNameTextField becomeFirstResponder];
        
        return NO;
    } else if ([textField isEqual:_lastNameTextField]){
        [_cellPhoneTextField becomeFirstResponder];
        
        return NO;
    } else if ([textField isEqual:_cellPhoneTextField]){
        
        return [self saveInformationIfValid];
    }
    
    return YES;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
