//
//  ViewController.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    CMMotionManager *motionManager;
}

@end

@implementation ViewController
@synthesize gameView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
