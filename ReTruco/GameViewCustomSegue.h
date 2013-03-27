//
//  GameViewCustomSegue.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 04/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"

typedef void (^block_game) (Game *game);

@interface GameViewCustomSegue : UIStoryboardSegue
@property (nonatomic, strong) block_game startBlockGame;
@end
