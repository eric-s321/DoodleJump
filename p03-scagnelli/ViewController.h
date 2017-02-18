//
//  ViewController.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GameView.h"
#import "ScoreBarView.h"
#import "SegueDelegate.h"
#import "PauseView.h"

@interface ViewController : UIViewController <SegueDelegate> {
    CADisplayLink *displayLink;
    NSTimer *scoreTimer;
    CMMotionManager *motionManager;
    id<SegueDelegate> segueDelegate;
    AVAudioPlayer *player;
//    SystemSoundID sound;
}

@property (strong, nonatomic) IBOutlet GameView *gameView;

-(IBAction) pauseGame:(id)sender;
-(IBAction) resumeGame:(UIStoryboardSegue *)segue;
-(void) gameOverSegue;
    
@end
