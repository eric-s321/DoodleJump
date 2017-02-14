//
//  ViewController.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "GameView.h"
#import "ScoreBarView.h"

@interface ViewController : UIViewController{
    CADisplayLink *displayLink;
    NSTimer *scoreTimer;
}

@property (strong, nonatomic) IBOutlet GameView *gameView;
@property (strong, nonatomic) IBOutlet ScoreBarView *scoreBar;

-(IBAction) pauseGame:(id)sender;
-(IBAction) resumeGame:(UIStoryboardSegue *)segue;

@end

