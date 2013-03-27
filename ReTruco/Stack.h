//
//  Stack.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 07/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface Stack : NSObject

- (void)addCardToTop:(Card *)card;
- (NSUInteger)cardCount;
- (NSArray *)array;
- (Card *)cardAtIndex:(NSUInteger)index;
- (void)addCardsFromArray:(NSArray *)array;
- (Card *)topmostCard;
- (void)removeTopmostCard;
- (void)removeCardAtIndex:(NSUInteger)index;
- (void)removeAllCards;

@end
