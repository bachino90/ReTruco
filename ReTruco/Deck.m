//
//  Deck.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 07/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Deck.h"
#import "Card.h"

@implementation Deck
{
	NSMutableArray *_cards;
}

- (void)setUpCards
{
	for (Suit suit = SuitEspada; suit <= SuitCopa; ++suit)
	{
		for (int value = CardAncho; value <= CardRey; ++value)
		{
			Card *card = [[Card alloc] initWithSuit:suit value:value];
			[_cards addObject:card];
		}
	}
}

- (id)init
{
	if ((self = [super init]))
	{
		_cards = [NSMutableArray arrayWithCapacity:40];
		[self setUpCards];
	}
	return self;
}

- (int)cardsRemaining
{
	return [_cards count];
}

- (void)shuffle
{
	NSUInteger count = [_cards count];
	NSMutableArray *shuffled = [NSMutableArray arrayWithCapacity:count];
    
	for (int t = 0; t < count; ++t)
	{
		int i = arc4random() % [self cardsRemaining];
		Card *card = [_cards objectAtIndex:i];
		[shuffled addObject:card];
		[_cards removeObjectAtIndex:i];
	}
    
	NSAssert([self cardsRemaining] == 0, @"Original deck should now be empty");
    
	_cards = shuffled;
}

- (Card *)draw
{
	NSAssert([self cardsRemaining] > 0, @"No more cards in the deck");
	Card *card = [_cards lastObject];
	[_cards removeLastObject];
	return card;
}

@end