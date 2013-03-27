//
//  HostViewCustomSegue.m
//  ReTruco
//
//  Created by Emiliano Bivachi on 04/03/13.
//  Copyright (c) 2013 Emiliano Bivachi. All rights reserved.
//

#import "HostViewCustomSegue.h"
#import "ReTrucoViewController.h"
#import "HostViewController.h"

@implementation HostViewCustomSegue

-(void)perform
{
    ReTrucoViewController *sVC = (ReTrucoViewController*)[self sourceViewController];
    HostViewController *dVC = (HostViewController*)[self destinationViewController];
    
    [sVC performExitAnimationWithCompletionBlock:^(BOOL finished)
    {
        dVC.delegate = sVC;
        
        [sVC presentViewController:dVC animated:NO completion:nil];
    }];
}

@end
