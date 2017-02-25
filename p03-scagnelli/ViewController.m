//
//  ViewController.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController
@synthesize gameView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Stop screen from falling asleep
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    displayLink = [CADisplayLink displayLinkWithTarget:gameView selector:@selector(update:)];
    [displayLink setPreferredFramesPerSecond:50];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    motionManager = [[CMMotionManager alloc] init];
    motionManager.accelerometerUpdateInterval = 1 / 60.0;
    
    if([motionManager isAccelerometerAvailable]){
        [motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                withHandler:^(CMAccelerometerData * _Nullable data, NSError * _Nullable error) {
                    [gameView performSelectorOnMainThread:@selector(updateVelocity:) withObject:data waitUntilDone:NO];
                }];
    }
    else{
        NSLog(@"Accelerometer Not available.");
    //    exit(EXIT_FAILURE);
    }
    
    [gameView generateBricks:ON_SCREEN_BRICKS];
    [gameView generateBricks:ABOVE_SCREEN_BRICKS];
    
    /*
        Once ViewController conforms to SegueDelegate by implementing gameOverSegue, ViewController IS a SegueDelegate.
        Thus we pass an instance of ViewController to be the segueDelegate in GameView so that we can switch UIViewControllers
        from GameView.
    */
    [gameView setSegueDelegate:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pauseGame:(id)sender{
    
    displayLink.paused = YES;
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Super_Mario_Brothers"  ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
     
    NSError *error;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
    
    if(error)
        NSLog(@"Error is: %@", error);
    
    Universe *universe = [Universe sharedInstance];
    [universe setAVPlayer:player];
      
    player.numberOfLoops = -1; //Infinite
    
    [player play];
}

-(IBAction) resumeGame:(UIStoryboardSegue *)segue{
    displayLink.paused = NO;
    Universe *universe = [Universe sharedInstance];
    player = [universe getAVPlayer];
    [player stop];
}

-(void) gameOverSegue{
    [self performSegueWithIdentifier:@"showGameOverScreen" sender:self];
    displayLink.paused = YES;
}


@end
