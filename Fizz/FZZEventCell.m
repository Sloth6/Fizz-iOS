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

@interface FZZEventCell ()

@property NSMutableDictionary *bubbles;

@end

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
        
        _bubbles = [[NSMutableDictionary alloc] init];
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
        _bubbles = NULL;
        
        return;
    }
    
    //[self setSubviews:[[NSArray alloc] initWithObjects:_label, nil]];
    
    // Text
    NSString *text = [(FZZMessage *)[[event messages] firstObject] text];
    
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
//        FZZUser *user = [invitees objectAtIndex:i];
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



- (void)setEvent:(FZZEvent *)event {
    
    //[self setSubviews:[[NSArray alloc] initWithObjects:_label, nil]];
    
    // Text
    NSString *text = [(FZZMessage *)[[event messages] firstObject] text];
    
    _label.text = text;
    
    // Bubbles
    NSOrderedSet *invitees = [event invitees];
    NSOrderedSet *clusters = [event clusters];
    
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    
    [_bubbles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIImageView *bubble = obj;
        NSNumber *uid = key;
        FZZUser *user = [FZZUser userWithUID:uid];
        
        if ([invitees containsObject:user]){
            // Queue up the appropriate placements concerning clustering
        } else {
            [toRemove addObject:key];
            [bubble removeFromSuperview];
        }
    }];
    
    [_bubbles removeObjectsForKeys:toRemove];
    
    [invitees enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZUser *user = obj;
        
        // TODOAndrew If the bubble exists, move it from it's current location
        
        // else create it, and move it from offscreen
            
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
                
                [_bubbles setObject:imageView forKey:[user userID]];
                [self addSubview:imageView];
            }
        }];
    }];
    
//    for (int i = 0; i < [invitees count]; ++i){
//        FZZUser *user = [invitees objectAtIndex:i];
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
//                
//                [_bubbles setObject:imageView forKey:[user userID]];
//                [self addSubview:imageView];
//            }
//        }];
//    }
}

@end
