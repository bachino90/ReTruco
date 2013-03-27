//
//  Stack.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 07/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Stack.h"
#import "Card.h"

@implementation Stack
{
	NSMutableArray *_cards;
}

- (id)init
{
	if ((self = [super init]))
	{
		_cards = [NSMutableArray arrayWithCapacity:3];
	}
	return self;
}

- (void)addCardToTop:(Card *)card
{
	NSAssert(card != nil, @"Card cannot be nil");
	NSAssert([_cards indexOfObject:card] == NSNotFound, @"Already have this Card");
	[_cards addObject:card];
}

- (NSUInteger)cardCount
{
	return [_cards count];
}

- (NSArray *)array
{
	return [_cards copy];
}

- (Card *)cardAtIndex:(NSUInteger)index
{
    if (index<[_cards count])
    {
        id obj = [_cards objectAtIndex:index];
        
        if ([obj isKindOfClass:[Card class]])
            return (Card *)obj;
        else
            return nil;
    }
    else
        return nil;
}

- (void)addCardsFromArray:(NSArray *)array
{
	_cards = [array mutableCopy];
}

- (Card *)topmostCard
{
	return [_cards lastObject];
}

- (void)removeTopmostCard
{
	//[_cards removeLastObject];
    [_cards replaceObjectAtIndex:([_cards count]-1) withObject:@"NULL"];
}

- (void)removeCardAtIndex:(NSUInteger)index
{
    //[_cards removeObjectAtIndex:index];
    [_cards replaceObjectAtIndex:index withObject:@"NULL"];
}

- (void)removeAllCards
{
	[_cards removeAllObjects];
}

@end
