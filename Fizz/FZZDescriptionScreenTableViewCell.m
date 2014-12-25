//
//  FZZDescriptionScreenTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZDescriptionScreenTableViewCell.h"
#import "FZZEvent.h"
#import "FZZUser.h"
#import "FZZAppDelegate.h"
#import "FZZUtilities.h"

#import "FZZExpandedVerticalTableViewController.h"

@interface FZZDescriptionScreenTableViewCell ()

@property NSTextStorage *descriptionTextStorage;
@property NSIndexPath *eventIndexPath;
@property FZZExpandedVerticalTableViewController *evtvc;

@property (strong, nonatomic) UILabel *hostLabel;

@end

@implementation FZZDescriptionScreenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupBackground];
        [self setupTextview];
        [self setupHostName];
    }
    return self;
}

-(void)setTableViewController:(FZZExpandedVerticalTableViewController *)evtvc{
    _evtvc = evtvc;
    
    [self updateTextview];
    [self updateHostName];
}

- (void)setupBackground{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
}

- (void)setupTextview{
    CGFloat leftBorder   = -8 + kFZZHorizontalMargin();
    CGFloat topBorder    = 18;
    CGFloat rightBorder  = 0;
    CGFloat bottomBorder = 0;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    frame.size.width  -= (leftBorder + rightBorder);
    frame.size.height -= (topBorder + bottomBorder);
    
    _descriptionTextStorage = [NSTextStorage new];
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    [_descriptionTextStorage addLayoutManager:layoutManager];
    
    NSTextContainer *textContainer = [NSTextContainer new];
    [layoutManager addTextContainer:textContainer];
    
    _textView = [[UITextView alloc] initWithFrame:frame
                                    textContainer:textContainer];
    
    
    
//    _textView = [[UITextView alloc] initWithFrame:frame];
    [self addSubview:_textView];
    
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setOpaque:NO];
    [_textView setUserInteractionEnabled:NO];
    
    UIFont *font = kFZZHeadingsFont();
    
    [_textView setFont:font];
    [_textView setTextColor:kFZZWhiteTextColor()];
}

//- (CGFloat)      layoutManager:(NSLayoutManager *)layoutManager
//  lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex
//  withProposedLineFragmentRect:(CGRect)rect
//{
//    return 0;
//}

- (void)setupHostName{
    CGFloat leftBorder   = kFZZHorizontalMargin();
    CGFloat topBorder    = 0;
    CGFloat rightBorder  = 0;
    CGFloat bottomBorder = 0;
    
    CGRect frame = [_textView bounds];
    
    frame.origin.y = frame.size.height;
    frame.size.height = kFZZGuestListLineHeight();
    
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    frame.size.width  -= (leftBorder + rightBorder);
    frame.size.height -= (topBorder + bottomBorder);
    
    _hostLabel = [[UILabel alloc] initWithFrame:frame];
    [self addSubview:_hostLabel];
    
    [_hostLabel setBackgroundColor:[UIColor clearColor]];
    [_hostLabel setOpaque:NO];
    
    UIFont *font = kFZZHostNameFont();
    
    [_hostLabel setFont:font];
    [_hostLabel setTextColor:kFZZWhiteTextColor()];
}

- (FZZEvent *)event{
    return [FZZEvent getEventAtIndexPath:_eventIndexPath];
}

- (void)updateTextview{
    CGFloat cellOffset = [_evtvc descriptionCellOffset];
    
    CGRect frame = [_textView frame];
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    
    frame.size.height = screenFrame.size.height - cellOffset - kFZZInputRowHeight();
    
    frame.size.height -= (frame.origin.y);
    
    [_textView setFrame:frame];
}

- (void)updateHostName{
    CGRect oldFrame = [_hostLabel frame];
    
    CGRect frame = [_textView frame];
    frame.origin.x = oldFrame.origin.x;
    
    frame.origin.y = frame.size.height;
    
    frame.origin.y -= kFZZGuestListPeak();
    frame.origin.y += kFZZVerticalMargin();
    
    frame.size.height = oldFrame.size.height;
    
    [_hostLabel setFrame:frame];
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

- (void)setDescriptionText:(NSString *)text{
    if (text != nil){
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        //    paragraphStyle.headIndent = 15; // <--- indention if you need it
        //    paragraphStyle.firstLineHeadIndent = 15;
        
        paragraphStyle.lineSpacing = -17; // <--- magic line spacing here!
        
        NSDictionary *attrsDictionary =
        @{ NSFontAttributeName: kFZZHeadingsFont(), // <-- if you need; & there are many more attrs
           NSParagraphStyleAttributeName: paragraphStyle,
           NSKernAttributeName: @(-3),
           NSForegroundColorAttributeName: kFZZWhiteTextColor()};
        
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:text
                                                                       attributes:attrsDictionary];
    }
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
    FZZEvent *event = [self event];
    NSString *title = [event eventDescription];
    
    NSString *hostName = [[[event creator] name] uppercaseString];
    
    NSLog(@"POOP3: %@", event);
    if (!title){
        title = @"";
    }
    
    [self setDescriptionText:title];
    [_hostLabel setText:hostName];
    
    NSLog(@"event: <%@>", title);
    [_textView setNeedsDisplay];
}

@end
