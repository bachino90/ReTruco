//
//  CardView.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 07/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Card;
@class Player;

@interface CardView : UIView

@property (nonatomic, strong) Card *card;

- (void)animateTurningOverForPlayer:(Player *)player;

//- (void)animateDealingToPlayer:(Player *)player withDelay:(NSTimeInterval)delay;
- (void)animateDealingToPlayer:(Player *)player atIndex:(NSUInteger)index withDelay:(NSTimeInterval)delay;
- (void)animateSelectingForPlayer:(Player *)player;
- (void)animateHideCardWithDelay:(NSTimeInterval)delay;

@end