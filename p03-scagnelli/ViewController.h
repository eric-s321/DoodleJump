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
#import "SegueDelegate.h"

@interface ViewController : UIViewController <SegueDelegate> {
    CADisplayLink *displayLink;
    NSTimer *scoreTimer;
    CMMotionManager *motionManager;
    id<SegueDelegate> segueDelegate;
}

@property (strong, nonatomic) IBOutlet GameView *gameView;

-(IBAction) pauseGame:(id)sender;
-(IBAction) resumeGame:(UIStoryboardSegue *)segue;

@end
