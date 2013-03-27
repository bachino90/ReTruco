//
//  TrucoGestureRecognizer.h
//  Gesture
//
//  Created by Emiliano Bivachi on 14/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef enum
{
	RoundStateFirstRound,
    RoundStateOtherRound
}RoundState;

typedef enum
{
    ButtonTouchNothing,
    ButtonTouchEnvido,
    ButtonTouchRealEnvido,
    ButtonTouchFaltaEnvido,
    ButtonTouchTruco,
    ButtonTouchReTruco,
    ButtonTouchQuieroValeCuatro
}ButtonTouch;

@interface TrucoGestureRecognizer : UIGestureRecognizer

- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@property (nonatomic) RoundState roundState;
@property (nonatomic) TrucoState trucoState;
@property (nonatomic) ButtonTouch buttonTouch;
@property (nonatomic) BOOL disableTouch;

@end
