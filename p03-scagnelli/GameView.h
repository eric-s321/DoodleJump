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
#import "ScoreBarView.h"
#import "SegueDelegate.h"

#define MAX_BRICKS_1 2
#define MAX_BRICKS_2 3
#define MAX_BRICKS_3 3
#define MAX_BRICKS_4 2
#define MAX_BRICKS_5 3

typedef enum {
    ON_SCREEN_BRICKS = 0,
    ABOVE_SCREEN_BRICKS = 1
}BrickGeneratorMode;

@interface GameView : UIView{
    NSMutableArray *bricks;
    int numPixelsCurrentBricksMoved;
    id<SegueDelegate> segueDelegate;
    int jumpLength;
    int bricksInRegion1;
    int bricksInRegion2;
    int bricksInRegion3;
    int bricksInRegion4;
    int bricksInRegion5;
}

@property (strong, nonatomic) Jumper *jumper;
@property (strong, nonatomic) IBOutlet ScoreBarView *scoreBar;

-(void) update:(CADisplayLink *)sender;
-(void) updateVelocity:(CMAccelerometerData *) accelData;
-(void) generateBricks:(BrickGeneratorMode) mode;
-(bool) bricksOverlap:(UIImageView *) newBrick;
-(void) moveBricksDown:(int)distanceToMove;
-(IBAction)callSegue:(id)sender;

/*
-(void) startMovingBricks;
-(void) stopMovingBricks;
*/

@end
