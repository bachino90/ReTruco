//
//  GameViewCustomSegue.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 04/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "GameViewCustomSegue.h"
#import "ReTrucoViewController.h"
#import "GameViewController.h"

@implementation GameViewCustomSegue

-(void)perform
{
    ReTrucoViewController *sVC = (ReTrucoViewController*)[self sourceViewController];
    GameViewController *dVC = (GameViewController*)[self destinationViewController];
    dVC.delegate = sVC;
    
    [sVC presentViewController:dVC animated:NO completion:^
     {
         Game *game = [[Game alloc] init];
         dVC.game = game;
         game.delegate = dVC;
         self.startBlockGame(game);
     }];
}

@end
