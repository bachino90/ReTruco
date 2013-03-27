//
//  Player.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 05/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Player.h"
#import "Card.h"
#import "Stack.h"

@interface Player ()
@property (nonatomic, strong) NSArray *totalCards;
@property (nonatomic, strong) NSNumber *internEnvido;
@end

@implementation Player

- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ peerID = %@, name = %@, position = %d", [super description], self.peerID, self.name, self.position];
}

- (id)init
{
	if ((self = [super init]))
	{
		_handCards = [[Stack alloc] init];
		_openCards = [[Stack alloc] init];
	}
	return self;
}

- (NSArray *)totalCards
{
    if (_totalCards==nil)
    {
        __block NSMutableArray *cards = [NSMutableArray arrayWithCapacity:3];
        
        [[self.handCards array] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[Card class]])
                [cards addObject:obj];
        }];
        
        if ([cards count] < 3)
            [[self.openCards array] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[Card class]])
                    [cards addObject:obj];
            }];
        
        _totalCards = [cards copy];
    }
    return _totalCards;
}

- (NSNumber *)internEnvido
{
    if (_internEnvido == nil)
    {
        _internEnvido = [self hasEnvido];
    }
    return _internEnvido;
}

- (NSNumber *)envido
{
    return self.internEnvido;
}

- (Card *)turnOverTopCard
{
	NSAssert([self.handCards cardCount] > 0, @"No more cards");
    
	Card *card = [self.handCards topmostCard];
	card.isTurnedOver = YES;
	[self.openCards addCardToTop:card];
	[self.handCards removeTopmostCard];
    
	return card;
}

- (Card *)turnOverCardAtIndex:(NSUInteger)index
{
    NSAssert([self.handCards cardCount] > 0, @"No more cards");
    
    Card *card = [self.handCards cardAtIndex:index];
    
    if (card==nil) return nil;
    
    card.isTurnedOver = YES;
    [self.openCards addCardToTop:card];
    [self.handCards removeCardAtIndex:index];
    
    return card;
}

- (void)recycleAllCards
{
    [self.openCards removeAllCards];
    [self.handCards removeAllCards];
    self.totalCards = nil;
}

-(CGPoint)centerForCardAtIndex:(NSUInteger)index inRect:(CGRect)rect
{
    CGFloat midX = CGRectGetMidX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    
    //CGFloat x = -3.0f + RANDOM_INT(6) + CARD_WIDTH/2.0f;
    CGFloat x = midX;
    CGFloat y = -3.0f + RANDOM_INT(6) + CARD_HEIGHT/2.0f;
    

    
    CGFloat cardWidth = CARD_WIDTH;
    CGFloat cardHeight = CARD_HEIGHT;
    
    if (self.position == PlayerPositionTop)
    {
        cardWidth *= 0.5;
        cardHeight *= 0.5;
    }
    
    if (index != CARD_TURNOVER)
	{
        if (self.position == PlayerPositionBottom)
        {
            y += maxY - cardHeight - 30.0f;
        }
        else if (self.position == PlayerPositionTop)
        {
            y += 29.0f;
        }
    
        if (index == 0)
        {
            x += cardWidth + 9.0f;
        }
        else if (index == 1)
        {
        
        }
        else if (index == 2)
        {
            x = x - cardWidth - 12.0f;
        }
    }
    else
    {
        x -= 30.0;
        CGFloat midY = CGRectGetMidY(rect);
        if (self.position == PlayerPositionBottom)
        {
            y = midY + CARD_HEIGHT/2.0f;
        }
        else if (self.position == PlayerPositionTop)
        {
            y = midY - CARD_HEIGHT/2.0f;
        }
        x += [[self.openCards array] count] * 12.0f;
    }
    
    return CGPointMake(x, y);
}

- (NSNumber *)hasEnvido
{    
    NSArray *cards = self.totalCards;
    
    Suit firstSuit;
    Suit secondSuit;
    BOOL hasEnvido = NO;
    int numberOfCard = 0;
    
    int i = 0;
    
    for (Card *card in cards)
    {
        if (i==0)
            firstSuit = card.suit;
        else if (i==1)
        {
            secondSuit = card.suit;
            if (secondSuit == firstSuit)
            {
                hasEnvido = YES;
                numberOfCard = 2;
            }
        }
        else if (i==2)
        {
            if (firstSuit == card.suit && secondSuit == card.suit)
            {
                hasEnvido = YES;
                numberOfCard = 5;
            }
            else if (firstSuit == card.suit && secondSuit != card.suit)
            {
                hasEnvido = YES;
                numberOfCard = 3;
            }
            else if (firstSuit != card.suit && secondSuit == card.suit)
            {
                hasEnvido = YES;
                numberOfCard = 4;
            }
        }
        i++;
    }
    
    NSInteger envido = 0;
    Card *firstCard;
    Card *secondCard;
    
    if (hasEnvido)
    {
        envido = 20;
        switch (numberOfCard) {
            case 2:
                firstCard = cards[0];
                secondCard = cards[1];
                break;
            case 3:
                firstCard = cards[0];
                secondCard = cards[2];
                break;
            case 4:
                firstCard = cards[1];
                secondCard = cards[2];
                break;
            case 5:
            {
                //buscar las dos cartas mas altas
                firstCard = cards[0];
                secondCard = cards[1];
                Card *thirdCard = cards[2];
                Card *lowCard;
                Card *highCard;
                if (firstCard.envidoValue > secondCard.envidoValue)
                {
                    lowCard = secondCard;
                    highCard = firstCard;
                }
                else
                {
                    lowCard = firstCard;
                    highCard = secondCard;
                }
                
                if (lowCard.envidoValue < thirdCard.envidoValue) 
                    lowCard = thirdCard;
                
                firstCard = lowCard;
                secondCard = highCard;
                
                break;
            }
            default:
                break;
        }
        
        envido += firstCard.envidoValue;
        envido += secondCard.envidoValue;
    }
    
    return [NSNumber numberWithInt:envido];
}


@end
