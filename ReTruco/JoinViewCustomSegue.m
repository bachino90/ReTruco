//
//  JoinViewCustomSegue.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 04/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "JoinViewCustomSegue.h"
#import "ReTrucoViewController.h"
#import "JoinViewController.h"

@implementation JoinViewCustomSegue

-(void)perform
{
    ReTrucoViewController *sVC = (ReTrucoViewController*)[self sourceViewController];
    JoinViewController *dVC = (JoinViewController*)[self destinationViewController];
    
    [sVC performExitAnimationWithCompletionBlock:^(BOOL finished)
     {
         dVC.delegate = sVC;
         
         [sVC presentViewController:dVC animated:NO completion:nil];
     }];
}

@end
