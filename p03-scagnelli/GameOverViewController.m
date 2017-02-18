//
//  GameOverViewController.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/17/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameOverViewController.h"

@implementation GameOverViewController
@synthesize scoreLabel;

-(void)viewDidLoad{
    int score = [[Universe sharedInstance] currentScore];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
}

/*
-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"In view did appear");
    int score = [[Universe sharedInstance] currentScore];
    scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
    
}
 */

@end
