//
//  TrucoView.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 19/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TrucoView;

@protocol TrucoViewDelegate <NSObject>
- (void)trucoViewAcceptTruco:(TrucoView *)trucoView;
- (void)trucoViewDenyTruco:(TrucoView *)trucoView;
- (void)trucoViewCalledEnvido:(TrucoView *)trucoView;
@end

@interface TrucoView : UIView

@property (nonatomic, weak) id <TrucoViewDelegate> delegate;
@property (nonatomic, readonly) TrucoState trucoState;

- (id)initWithState:(TrucoState)state andEnvidoType:(EnvidoType)envidoType;

@end
