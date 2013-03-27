//
//  TrucoGestureRecognizer.m
//  Gesture
//
//  Created by Emiliano Bivachi on 14/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "TrucoGestureRecognizer.h"
#import "ButtonView.h"

@interface TrucoGestureRecognizer ()

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGRect rectContainer;

@property (nonatomic, strong) ButtonView *trucoView;
@property (nonatomic, strong) ButtonView *reTrucoView;
@property (nonatomic, strong) ButtonView *quieroValeCuatroView;

@property (nonatomic, strong) ButtonView *envidoView;
@property (nonatomic, strong) ButtonView *realEnvidoView;
@property (nonatomic, strong) ButtonView *faltaEnvidoView;

@property (nonatomic, strong) NSArray *views;
@property (nonatomic, strong) NSArray *touchViews;

@property (nonatomic) BOOL isAnimatingViews;
@property (nonatomic) NSUInteger selectedViewCount;

@end

@implementation TrucoGestureRecognizer

#define VIEW_WIDTH 90.0
#define VIEW_HEIGHT 35.0
#define SPACE_BETWEEN 60.0

- (UIView *)envidoView
{
    if (_envidoView==nil)
    {
        _envidoView = [[ButtonView alloc] initWithFrame:CGRectMake(0.0, 0.0, VIEW_WIDTH, VIEW_HEIGHT)];
        _envidoView.alpha = 0.0;
        _envidoView.backgroundColor = [UIColor blueColor];
        _envidoView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    }
    return _envidoView;
}

- (UIView *)realEnvidoView
{
    if (_realEnvidoView==nil)
    {
        _realEnvidoView = [[ButtonView alloc] initWithFrame:CGRectMake(0.0, 0.0, VIEW_WIDTH, VIEW_HEIGHT)];
        _realEnvidoView.alpha = 0.0;
        _realEnvidoView.backgroundColor = [UIColor redColor];
        _realEnvidoView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    }
    return _realEnvidoView;
}

- (UIView *)faltaEnvidoView
{
    if (_faltaEnvidoView==nil)
    {
        _faltaEnvidoView = [[ButtonView alloc] initWithFrame:CGRectMake(0.0, 0.0, VIEW_WIDTH, VIEW_HEIGHT)];
        _faltaEnvidoView.alpha = 0.0;
        _faltaEnvidoView.backgroundColor = [UIColor redColor];
        _faltaEnvidoView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    }
    return _faltaEnvidoView;
}

- (UIView *)trucoView
{
    if (_trucoView==nil)
    {
        _trucoView = [[ButtonView alloc] initWithFrame:CGRectMake(0.0, 0.0, VIEW_WIDTH, VIEW_HEIGHT)];
        _trucoView.alpha = 0.0;
        _trucoView.backgroundColor = [UIColor greenColor];
        _trucoView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    }
    return _trucoView;
}

- (UIView *)reTrucoView
{
    if (_reTrucoView==nil)
    {
        _reTrucoView = [[ButtonView alloc] initWithFrame:CGRectMake(0.0, 0.0, VIEW_WIDTH, VIEW_HEIGHT)];
        _reTrucoView.alpha = 0.0;
        _reTrucoView.backgroundColor = [UIColor yellowColor];
        _reTrucoView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    }
    return _reTrucoView;
}

- (UIView *)quieroValeCuatroView
{
    if (_quieroValeCuatroView==nil)
    {
        _quieroValeCuatroView = [[ButtonView alloc] initWithFrame:CGRectMake(0.0, 0.0, VIEW_WIDTH, VIEW_HEIGHT)];
        _quieroValeCuatroView.alpha = 0.0;
        _quieroValeCuatroView.backgroundColor = [UIColor blackColor];
        _quieroValeCuatroView.transform = CGAffineTransformMakeScale(0.05, 0.05);
    }
    return _quieroValeCuatroView;
}


- (void)showViews
{
    [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop){
        [self.view addSubview:view];
        view.center = self.startPoint;
    }];
    self.isAnimatingViews = YES;
    [UIView animateWithDuration:0.25f
                          delay:0.05f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         __block CGFloat y = self.startPoint.y;
                         [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop){
                             view.alpha = 1.0;
                             view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             view.center = CGPointMake(self.startPoint.x, y - SPACE_BETWEEN);
                             y -= SPACE_BETWEEN;
                         }];
                     }
                     completion:^(BOOL finished){
                         self.isAnimatingViews = NO;
                     }];
}

- (void)hideViews
{
    [UIView animateWithDuration:0.2f
                          delay:0.05f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop){
                             view.alpha = 0.0;
                             view.transform = CGAffineTransformMakeScale(0.05, 0.05);
                             view.center = self.startPoint;
                         }];
                     }
                     completion:^(BOOL finished){
                        if (finished) 
                            [self.views enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop){
                                 [view removeFromSuperview];
                            }];
                        
                        self.startPoint = CGPointZero;
                     }];
}

- (void)moveView:(UIView *)view differenceY:(CGFloat)difY withDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         view.center = CGPointMake(view.center.x, view.center.y - difY * 0.15);
                     }
                     completion:NULL];
}

- (ButtonView *)touchSelectView:(CGPoint)point
{
    __block ButtonView *selectedView = nil;
    [self.views enumerateObjectsUsingBlock:^(ButtonView *view, NSUInteger index, BOOL *stop){
        BOOL select = CGRectContainsPoint(view.frame, point);
        if (select)
        {
            view.isSelected = YES;
            self.buttonTouch = [self.touchViews[index] intValue];
            selectedView = view;
            *stop = YES;
        }
        else
        {
            view.isSelected = NO;
            self.buttonTouch = ButtonTouchNothing;
        }
    }];
    
    return selectedView;
}

- (ButtonView *)searchCloserViewToPoint:(CGPoint)point
{
    __block ButtonView *closerView = nil;
    __block CGFloat lastDistance = 1000.0f;
    __block CGFloat distance;
    [self.views enumerateObjectsUsingBlock:^(ButtonView *view, NSUInteger index, BOOL *stop){
        distance = point.y - view.center.y;
        if (distance > 0 && distance < lastDistance)
        {
            closerView = view;
            lastDistance = distance;
        }
    }];
    
    return closerView;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"began");
    if ([touches count] != 1 || self.disableTouch == YES) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    UITouch *touch = [touches anyObject];
    self.startPoint = [touch locationInView:self.view];
    
    if (self.roundState == RoundStateFirstRound)
    {
        self.views = @[self.envidoView, self.realEnvidoView, self.faltaEnvidoView, self.trucoView];
        self.touchViews = @[@(ButtonTouchEnvido),@(ButtonTouchRealEnvido),@(ButtonTouchFaltaEnvido),@(ButtonTouchTruco)];
    }
    else
    {
        if (self.trucoState == TrucoStateNothing)
        {
            self.views = @[self.trucoView];
            self.touchViews = @[@(ButtonTouchTruco)];
        }
        else if (self.trucoState == TrucoStateTruco)
        {
            self.views = @[self.reTrucoView];
            self.touchViews = @[@(ButtonTouchReTruco)];
        }
        else if (self.trucoState == TrucoStateReTruco)
        {
            self.views = @[self.quieroValeCuatroView];
            self.touchViews = @[@(ButtonTouchQuieroValeCuatro)];
        }
    }
    
    CGFloat height = ([self.views count] * (VIEW_HEIGHT + 30.0)) + 40.0;
    self.rectContainer = CGRectMake(self.startPoint.x - (VIEW_WIDTH + 20.0)/2, self.startPoint.y - height, VIEW_WIDTH + 20.0, height + 20.0);
    
    [self showViews];
    
    self.selectedViewCount = 0;
    self.buttonTouch = ButtonTouchNothing;
    
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint nowPoint = [touch locationInView:self.view];
    CGPoint prevPoint = [touch previousLocationInView:self.view];
    
    if (!CGRectContainsPoint(self.rectContainer, nowPoint))
    {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    ButtonView *viewSelected = [self touchSelectView:nowPoint];
       
    if (viewSelected == nil)
    {
        ButtonView *closerView = [self searchCloserViewToPoint:nowPoint];
        CGFloat difY = nowPoint.y - prevPoint.y;
        [self moveView:closerView differenceY:difY withDuration:touch.timestamp];
    }
    
    
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    NSLog(@"Ended");
    [self hideViews];
    self.views = nil;
    self.touchViews = nil;
    
    if (self.state == UIGestureRecognizerStateChanged && self.buttonTouch != ButtonTouchNothing) {
        self.state = UIGestureRecognizerStateRecognized;
    }    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateFailed;
    NSLog(@"cancelled");
    [self hideViews];
    self.views = nil;
    self.touchViews = nil;
    self.buttonTouch = ButtonTouchNothing;
}

- (void)reset
{
    [super reset];
    NSLog(@"reset");
    [self hideViews];
    self.views = nil;
    self.touchViews = nil;
    self.buttonTouch = ButtonTouchNothing;
}

@end
