//
//  PauseViewController.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/17/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PauseView.h"

@implementation PauseView

-(IBAction)stopMusic{
    Universe *universe = [Universe sharedInstance];
    // Get the same AVPlayer that ViewController was using
    audioPlayer = [universe getAVPlayer];
    
    [audioPlayer stop];
}

@end

