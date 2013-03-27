//
//  Card.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 07/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "Card.h"

@interface Card()
@property (nonatomic,readwrite) NSUInteger points;
@end

@implementation Card

@synthesize suit = _suit;
@synthesize value = _value;

- (void)setSuit:(Suit)suit
{
    _suit = suit;
    [self calculatePoints];
}

- (void)setValue:(int)value
{
    _value = value;
    [self calculatePoints];
}

- (id)initWithSuit:(Suit)suit value:(int)value
{
	NSAssert(value >= CardAncho && value <= CardRey, @"Invalid card value");
    
	if ((self = [super init]))
	{
		_suit = suit;
		_value = value;
        [self calculatePoints];
	}
	return self;
}

- (void)calculatePoints
{
    if (self.value >= CardAncho && self.value <= CardRey)
    {
        switch (self.value)
        {
            case CardAncho:
                if (self.suit == SuitCopa || self.suit == SuitOro)
                {
                    self.points = 500;
                }
                else if (self.suit == SuitEspada)
                {
                     self.points = 1200;
                }
                else if (self.suit == SuitBasto)
                {
                     self.points = 1100;
                }
                break;
                
            case 2:
                self.points = 600;
                break;
                
            case 3:
                self.points = 750;
                break;
                
            case 4:
                self.points = 100;
                break;
                
            case 5:
                self.points = 150;
                break;
                
            case 6:
                self.points = 200;
                break;
                
            case 7:
                if (self.suit == SuitBasto || self.suit == SuitCopa)
                {
                    self.points = 250;
                }
                else if (self.suit == SuitEspada)
                {
                     self.points = 1000;
                }
                else if (self.suit == SuitOro)
                {
                     self.points = 900;
                }
                break;
                
            case CardJack:
                self.points = 300;
                break;
                
            case CardCaballo:
                self.points = 350;
                break;
                
            case CardRey:
                self.points = 400;
                break;
                
            default:
                break;
        }
    }
}

- (BOOL)hasHigherPointsThan:(Card *)card
{
    return (self.points >= card.points)? YES: NO;
}

- (int)envidoValue
{
    if (self.value == CardCaballo || self.value == CardJack || self.value == CardRey)
        return 0;
    else
        return self.value;
}

@end
