//
//  Game.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 04/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"

@class Game;

@protocol GameDelegate <NSObject>

- (void)gameDidBegin:(Game *)game;
- (void)gameShouldDealCards:(Game *)game startingWithPlayer:(Player *)startingPlayer;
- (void)game:(Game *)game didActivatePlayer:(Player *)player;
- (void)game:(Game *)game player:(Player *)player turnedOverCard:(Card *)card;
- (void)gameDidRecycleCards:(Game *)game;

- (void)gameWaitUntilRecieveResponse:(Game *)game withTitle:(NSString *)title;
- (void)gamePresentViewForEnvido:(Game *)game;
- (void)gamePresentViewForTruco:(Game *)game;
- (void)gameResumeHideViewHUD:(Game *)game;
- (void)game:(Game *)game showEnvidoRespond:(BOOL)respond;
- (void)game:(Game *)game showTrucoRespond:(BOOL)respond;

- (void)game:(Game *)game didQuitWithReason:(QuitReason)reason;
- (void)game:(Game *)game playerDidDisconnect:(Player *)disconnectedPlayer;
- (void)gameWaitingForServerReady:(Game *)game;
- (void)gameWaitingForClientsReady:(Game *)game;

@end

@interface Game : NSObject <GKSessionDelegate>

@property (nonatomic, weak) id <GameDelegate> delegate;
@property (nonatomic, assign) BOOL isServer;
@property (nonatomic, readonly) TrucoState trucoState;
@property (nonatomic, readonly) EnvidoType envidoType;

- (void)startClientGameWithSession:(GKSession *)session playerName:(NSString *)name server:(NSString *)peerID;
- (void)startServerGameWithSession:(GKSession *)session playerName:(NSString *)name clients:(NSArray *)clients;
- (void)quitGameWithReason:(QuitReason)reason;

- (void)beginRound;
- (void)beginAnotherRound;
- (void)finishRecycle;

- (NSInteger)numberOfRound;

- (void)playerCalledEnvido:(Player *)player envidoType:(EnvidoType)type;
- (void)playerCalledTruco:(Player *)player trucoState:(TrucoState)state;

- (NSDictionary *)envidoMessage;

- (void)respondEnvido:(BOOL)respond;
- (void)respondTruco:(BOOL)respond;
- (void)respondEnvidoEnvido;
- (void)respondEnvidoBeforeTruco;

- (void)turnCardForPlayerAtBottomAtIndexCard:(NSUInteger)index;

- (Player *)playerAtPosition:(PlayerPosition)position;
- (Player *)activePlayer;

@end
