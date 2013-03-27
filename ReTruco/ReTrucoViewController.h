//
//  ReTrucoViewController.h
//  ReTruco
//
//  Created by Emiliano Bivachi on 03/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostViewController.h"
#import "JoinViewController.h"
#import "GameViewController.h"

@interface ReTrucoViewController : UIViewController <HostViewControllerDelegate, JoinViewControllerDelegate, GameViewControllerDelegate>
- (void)performExitAnimationWithCompletionBlock:(void (^)(BOOL))block;
@end
