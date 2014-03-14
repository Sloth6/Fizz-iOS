//
//  BCNEventCell.m
//  Beacon
//
//  Created by Andrew Sweet on 1/17/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNEventCell.h"
#import "BCNEvent.h"
#import "BCNMessage.h"
#import "BCNUser.h"

@interface BCNEventCell ()

@property NSMutableArray *bubbles;

@end

@implementation BCNEventCell

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
        
        _bubbles = [[NSMutableArray alloc] init];
    }
    return self;
}

//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return NULL;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return 0;
//}
//
//-(void)setupCollectionViewForEvent:(BCNEvent *)event{
//    BCNCellFlowLayout *flowLayout = [[BCNCellFlowLayout alloc] init];
//    
//    _collectionView = [[UICollectionView alloc] initWithFrame:self.frame
//                                         collectionViewLayout:flowLayout];
//    
//}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_label setFrame:frame];
    [_label sizeToFit];
    [self setNeedsDisplay]; // force drawRect:
}

-(void)setEventCollapsed:(BCNEvent *)event{
    //[self setSubviews:[[NSArray alloc] initWithObjects:_label, nil]];
    
    // Text
    NSString *text = [(BCNMessage *)[[event messages] firstObject] text];
    
    _label.text = text;
    
//    // Bubbles
//    NSArray *invitees = [event invitees];
//    
//    for (int i = 0; i < [_bubbles count]; ++i){
//        UIImageView *bubble = [_bubbles objectAtIndex:i];
//        [bubble removeFromSuperview];
//    }
//    
//    _bubbles = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < [invitees count]; ++i){
//        BCNUser *user = [invitees objectAtIndex:i];
//        
//        [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
//            if (image != NULL){
//                UIImageView *imageView = [user circularImage:1.4];
//                
//                CGSize size = imageView.bounds.size;
//                //CGPoint point = imageView.bounds.origin;
//                
//                int maxX = [UIScreen mainScreen].bounds.size.width  - size.width;
//                int maxY = [UIScreen mainScreen].bounds.size.height - size.height;
//                
//                int x = rand() % maxX;
//                int y = rand() % maxY;
//                
//                [imageView setFrame:CGRectMake(x, y, size.width, size.height)];
//                
//                [_bubbles addObject:imageView];
//                [self addSubview:imageView];
//            }
//        }];
//    }
    
    _bubbles = NULL;
}



- (void)setEvent:(BCNEvent *)event {
    
    //[self setSubviews:[[NSArray alloc] initWithObjects:_label, nil]];
    
    // Text
    NSString *text = [(BCNMessage *)[[event messages] firstObject] text];
    
    _label.text = text;
    
    // Bubbles
    NSArray *invitees = [event invitees];
    
    for (int i = 0; i < [_bubbles count]; ++i){
        UIImageView *bubble = [_bubbles objectAtIndex:i];
        [bubble removeFromSuperview];
    }
    
    _bubbles = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [invitees count]; ++i){
        BCNUser *user = [invitees objectAtIndex:i];
        
        [user fetchProfilePictureIfNeededWithCompletionHandler:^(UIImage *image) {
            if (image != NULL){
                UIImageView *imageView = [user circularImage:1.4];
                
                CGSize size = imageView.bounds.size;
                //CGPoint point = imageView.bounds.origin;
                
                int maxX = [UIScreen mainScreen].bounds.size.width  - size.width;
                int maxY = [UIScreen mainScreen].bounds.size.height - size.height;
                
                int x = rand() % maxX;
                int y = rand() % maxY;
                
                [imageView setFrame:CGRectMake(x, y, size.width, size.height)];
                
                [_bubbles addObject:imageView];
                [self addSubview:imageView];
            }
        }];
    }
}

@end
