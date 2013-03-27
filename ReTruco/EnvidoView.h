//
//  EnvidoView.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 19/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EnvidoView;

@protocol EnvidoViewDelegate <NSObject>
- (void)envidoViewAcceptEnvido:(EnvidoView *)envidoView;
- (void)envidoViewDenyEnvido:(EnvidoView *)envidoView;
- (void)envidoViewCalledEnvidoEnvido:(EnvidoView *)envidoView;
@end


@interface EnvidoView : UIView

@property (nonatomic, weak) id <EnvidoViewDelegate> delegate;
@property (nonatomic, readonly) EnvidoType envidoType;

- (id)initWithType:(EnvidoType)type;

@end
