//
//  Player.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 05/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;
@class Stack;

typedef enum
{
	PlayerPositionBottom,  // the user
	PlayerPositionTop
}
PlayerPosition;

@interface Player : NSObject

@property (nonatomic, strong, readonly) Stack *handCards;
@property (nonatomic, strong, readonly) Stack *openCards;

@property (nonatomic, assign) PlayerPosition position;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *peerID;
@property (nonatomic, assign) BOOL receivedResponse;
@property (nonatomic, assign) int gamesWon;
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, readonly) NSNumber *envido;

- (Card *)turnOverTopCard;
- (Card *)turnOverCardAtIndex:(NSUInteger)index;
- (CGPoint)centerForCardAtIndex:(NSUInteger)index inRect:(CGRect)rect;
- (void)recycleAllCards;

@end
