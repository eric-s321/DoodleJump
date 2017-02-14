//
//  GameView.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Jumper.h"

typedef enum {
    ON_SCREEN_BRICKS = 0,
    ABOVE_SCREEN_BRICKS = 1
}BrickGeneratorMode;

@interface GameView : UIView{
    NSMutableArray *bricks;
    NSTimer *brickMovementTimer;
    int numPixelsCurrentBricksMoved;
}

@property (strong, nonatomic) Jumper *jumper;

-(void) update:(CADisplayLink *)sender;
-(void) updateVelocity:(CMAccelerometerData *) accelData;
-(void) generateBricks:(BrickGeneratorMode) mode;
-(bool) bricksOverlap:(UIImageView *) newBrick;
-(void) moveBricksDown;
-(void) startMovingBricks;
-(void) stopMovingBricks;

@end
