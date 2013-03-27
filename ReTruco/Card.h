//
//  Card.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 07/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	SuitEspada,
	SuitBasto,
	SuitOro,
	SuitCopa
}
Suit;

#define CardAncho   1
#define CardJack  8
#define CardCaballo 9
#define CardRey  10

@interface Card : NSObject

@property (nonatomic, assign, readonly) Suit suit;
@property (nonatomic, assign, readonly) int value;
@property (nonatomic, assign, readonly) int envidoValue;
@property (nonatomic, assign, readonly) NSUInteger points;
@property (nonatomic, assign) BOOL isTurnedOver;

- (id)initWithSuit:(Suit)suit value:(int)value;
- (BOOL)hasHigherPointsThan:(Card *)card;


@end
