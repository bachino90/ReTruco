//
//  CardView.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 07/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "CardView.h"
#import "Card.h"
#import "Player.h"

@implementation CardView
{
	UIImageView *_backImageView;
	UIImageView *_frontImageView;
	CGFloat _angle;
}

@synthesize card = _card;

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.backgroundColor = [UIColor clearColor];
		[self loadBack];
	}
	return self;
}

- (void)loadBack
{
	if (_backImageView == nil)
	{
		_backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_backImageView.image = [UIImage imageNamed:@"Back"];
		_backImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:_backImageView];
	}
}

- (void)unloadBack
{
	[_backImageView removeFromSuperview];
	_backImageView = nil;
}

- (void)loadFront
{
	if (_frontImageView == nil)
	{
		_frontImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_frontImageView.contentMode = UIViewContentModeScaleToFill;
		_frontImageView.hidden = YES;
		[self addSubview:_frontImageView];
        
		NSString *suitString;
		switch (self.card.suit)
		{
			case SuitEspada:    suitString = @"Clubs"; break;
			case SuitBasto: suitString = @"Diamonds"; break;
			case SuitOro:   suitString = @"Hearts"; break;
			case SuitCopa:   suitString = @"Spades"; break;
		}
        
		NSString *valueString;
		switch (self.card.value)
		{
			case CardAncho:   valueString = @"Ace"; break;
			case CardJack:  valueString = @"Jack"; break;
			case CardCaballo: valueString = @"Queen"; break;
			case CardRey:  valueString = @"King"; break;
			default:        valueString = [NSString stringWithFormat:@"%d", self.card.value];
		}
        
		NSString *filename = [NSString stringWithFormat:@"%@ %@", suitString, valueString];
		_frontImageView.image = [UIImage imageNamed:filename];
	}
}

- (CGPoint)centerForPlayer:(Player *)player
{
	CGRect rect = self.superview.bounds;
	CGFloat midX = CGRectGetMidX(rect);
	CGFloat maxY = CGRectGetMaxY(rect);
    
	CGFloat x = -3.0f + RANDOM_INT(6) + CARD_WIDTH/2.0f;
	CGFloat y = -3.0f + RANDOM_INT(6) + CARD_HEIGHT/2.0f;
    
	if (player.position == PlayerPositionBottom)
	{
		x += midX - CARD_WIDTH - 7.0f;
		y += maxY - CARD_HEIGHT - 30.0f;
	}
	else if (player.position == PlayerPositionTop)
	{
		x += midX + 7.0f;
		y += 29.0f;
	}
    
	return CGPointMake(x, y);
}

- (CGFloat)angleForPlayer:(Player *)player
{
	float theAngle = (-0.5f + RANDOM_FLOAT()) / 4.0f;
    
	if (player.position == PlayerPositionTop)
		theAngle += M_PI;
    
	return theAngle;
}
/*
- (void)animateDealingToPlayer:(Player *)player withDelay:(NSTimeInterval)delay
{
	self.frame = CGRectMake(-100.0f, -100.0f, CARD_WIDTH, CARD_HEIGHT);
	self.transform = CGAffineTransformMakeRotation(M_PI);
    
	CGPoint point = [self centerForPlayer:player];
	_angle = [self angleForPlayer:player];
    
	[UIView animateWithDuration:0.2f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.center = point;
         self.transform = CGAffineTransformMakeRotation(_angle);
     }
                     completion:nil];
}
*/
- (void)animateDealingToPlayer:(Player *)player atIndex:(NSUInteger)index withDelay:(NSTimeInterval)delay
{
	self.frame = CGRectMake(-100.0f, -100.0f, CARD_WIDTH, CARD_HEIGHT);
	self.transform = CGAffineTransformMakeRotation(M_PI);
    
	CGPoint point = [player centerForCardAtIndex:index inRect:self.superview.bounds];
	_angle = [self angleForPlayer:player];
    
	[UIView animateWithDuration:0.2f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.center = point;
         if (player.position == PlayerPositionTop) {
             self.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(TOP_CARD_SCALE, TOP_CARD_SCALE), _angle);
         }
         else
             self.transform = CGAffineTransformMakeRotation(_angle);
     }
                     completion:^(BOOL finished)
    {
         if (player.position == PlayerPositionBottom)
             [self animateTurningOverForPlayer:player];
    }];
}

- (void)animateTurningOverForPlayer:(Player *)player
{
	[self loadFront];
	[self.superview bringSubviewToFront:self];
    
	UIImageView *darkenView = [[UIImageView alloc] initWithFrame:self.bounds];
	darkenView.backgroundColor = [UIColor clearColor];
	darkenView.image = [UIImage imageNamed:@"Darken"];
	darkenView.alpha = 0.0f;
	[self addSubview:darkenView];
    
	//CGPoint startPoint = self.center;
	//CGPoint endPoint = [self centerForPlayer:player];
	CGFloat afterAngle = [self angleForPlayer:player];
    
	//CGPoint halfwayPoint = CGPointMake((startPoint.x + endPoint.x)/2.0f, (startPoint.y + endPoint.y)/2.0f);
	CGFloat halfwayAngle = (_angle + afterAngle)/2.0f;
    
	[UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^
     {
         CGRect rect = _backImageView.bounds;
         rect.size.width = 1.0f;
         _backImageView.bounds = rect;
         
         darkenView.bounds = rect;
         darkenView.alpha = 0.5f;
         
         //self.center = halfwayPoint;
         self.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(halfwayAngle), 1.2f, 1.2f);
     }
                     completion:^(BOOL finished)
     {
         _frontImageView.bounds = _backImageView.bounds;
         _frontImageView.hidden = NO;
         
         [UIView animateWithDuration:0.15f
                               delay:0
                             options:UIViewAnimationOptionCurveEaseOut
                          animations:^
          {
              CGRect rect = _frontImageView.bounds;
              rect.size.width = CARD_WIDTH;
              _frontImageView.bounds = rect;
              
              darkenView.bounds = rect;
              darkenView.alpha = 0.0f;
              
              //self.center = endPoint;
              self.transform = CGAffineTransformMakeRotation(afterAngle);
          }
                          completion:^(BOOL finished)
          {
              [darkenView removeFromSuperview];
              [self unloadBack];
          }];
     }];
}

- (void)animateSelectingForPlayer:(Player *)player
{
	CGPoint point = [player centerForCardAtIndex:CARD_TURNOVER inRect:self.superview.bounds];
	_angle = [self angleForPlayer:player];
    
    [self.superview bringSubviewToFront:self];
    
	[UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.center = point;
         self.transform = CGAffineTransformMakeRotation(_angle + M_PI);
     }
                     completion:^(BOOL finished)
     {
         if (player.position == PlayerPositionTop)
             [self animateTurningOverForPlayer:player];
     }];
}

- (void)animateHideCardWithDelay:(NSTimeInterval)delay
{
    
	CGPoint point = CGPointMake(-100.0f, -100.0f);
    
	[UIView animateWithDuration:0.25f
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.center = point;
         self.transform = CGAffineTransformMakeRotation(M_2_PI);
     }
                     completion:^(BOOL finished)
     {
         [self removeFromSuperview];
     }];

}


@end
