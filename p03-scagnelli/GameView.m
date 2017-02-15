//
//  GameView.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameView.h"

@implementation GameView
@synthesize jumper;

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if(self){
        CGRect bounds = [self bounds];
        NSLog(@"y length of screen is %.2f", bounds.size.height);
        
        UIImage *jumperImage = [UIImage imageNamed:@"mario.png"];
        jumper = [[Jumper alloc] initWithImage:jumperImage];
        [jumper setFrame:CGRectMake(bounds.size.width/2, bounds.size.height - 100, 60, 110)];
        [jumper setDx:0];
        [jumper setDy:10];
        bricks = [[NSMutableArray alloc] init];
        
        [self addSubview:jumper];
        
        numPixelsCurrentBricksMoved = 0;
        
        //On each jump mario moves about 160 pixels vertically
        jumpLength = 160;
        
        bricksInRegion1 = 0;
        bricksInRegion2 = 0;
        bricksInRegion3 = 0;
        bricksInRegion4 = 0;
        bricksInRegion5 = 0;
    }
    return self;
}

-(void) updateVelocity:(CMAccelerometerData *) accelData{
    
    //Apply tilt and limit to + or - 4
    [jumper setDx:[jumper dx] + accelData.acceleration.x];
    
    if([jumper dx] > 4)
        [jumper setDx:4];
    if([jumper dx] < -4)
        [jumper setDx:-4];

}

-(void) update:(CADisplayLink *)sender{
    
//    NSLog(@"bricks now has %lu bricks", (unsigned long)[bricks count]);
    
//    NSLog(@"Score is %d", [_scoreBar.scoreLabel.text intValue]);
    CGPoint p = [jumper center];
    CGRect jumperBounds = [jumper bounds];
    CGRect bounds = [self bounds];
    double midwayHeight = bounds.size.height / 2;
    
    [jumper setDy:[jumper dy] - .3];  //Apply "gravity" (make jumper fall)
    
    
    
    if([jumper dy] > -.3 && [jumper dy] < 0){ //Jumper is approx at top of jump
    //    NSLog(@"Velocity is 0");
//        NSLog(@"At the top of the jump marios y pos is %.4f", p.y);
    }
    
    
    p.x += [jumper dx];
    p.y -= [jumper dy];  // Move jumper in direction of their y velocity
                         // positive y velocity will move up, negative down
    
    double jumperBottom = p.y + jumperBounds.size.height / 2;
    CGPoint bottomOfJumper = p;
    bottomOfJumper.y = jumperBottom;
    
    
    //We have hit the bottom of the screen 
    if(jumperBottom >= bounds.size.height){
        p.y = bounds.size.height - jumperBounds.size.height / 2;  //Set at the bottom of screen
        [jumper setDy:10];  //Give positive velocity
        /*
        NSLog(@"Calling Segue delegate's gameOverSegue method");
        [segueDelegate gameOverSegue];
         */
    }
    
    // If we have gone too far left, or too far right, wrap around
    if (p.x < 0)
        p.x += bounds.size.width;
    if (p.x > bounds.size.width)
        p.x -= bounds.size.width;
    
    
    // If moving down and touch a brick boost velocity to bounce up
    if([jumper dy] < 0){
        for (UIImageView *brick in bricks){
            CGRect brickFrame = [brick frame];
            if(CGRectContainsPoint(brickFrame, bottomOfJumper)){
  //              NSLog(@"When mario hit the brick his y pos is %.4f", p.y);
                [jumper setDy:10];
            }
        }
    }
    
    //Get new jumperBottom incase we changed it
    jumperBottom = p.y + jumperBounds.size.height / 2;
    
    // jumper is above the halfway point
    if(jumperBottom <= midwayHeight){
        p.y += midwayHeight - jumperBottom;  //place jumper so feet are midway on screen
        [self moveBricksDown:midwayHeight - jumperBottom];
    }
    
    if(numPixelsCurrentBricksMoved >= bounds.size.height){ //The bricks have been moved 1 screenlength down
        numPixelsCurrentBricksMoved = 0;
        [self generateBricks:ABOVE_SCREEN_BRICKS];
    }
    
    // Get rid of bricks that are now below the visible part of screen
    [self removeOldBricks];
    
    [jumper setCenter:p];
}

-(void) generateBricks:(BrickGeneratorMode) mode{
    CGRect bounds = [self bounds];
    float height = 20;
    bool lowBrick = NO;
    
    int i = 0;
    bricksInRegion1 = 0;
    bricksInRegion2 = 0;
    bricksInRegion3 = 0;
    bricksInRegion4 = 0;
    bricksInRegion5 = 0;
    while(![self allBrickRegionsFull]){
//    for (int i = 0; i < 10; i++){
        float width;
        //Create bricks of 2 different widths
        if(i % 2 == 0)
            width = bounds.size.width * .2;
        else
            width = bounds.size.width * .3;
        
        //Add bricks and make sure none of them overlap with eachother
        
        
        UIImageView *brick;
        bool brickRegionFull;
        do{
            brickRegionFull = NO;
            UIImage *brickImage = [UIImage imageNamed:@"bricks.jpeg"];
            brick = [[UIImageView alloc] initWithImage:brickImage];
            int xCoord = arc4random() % (int)bounds.size.width * .8;
            
            int yCoord;
            if(mode == ON_SCREEN_BRICKS){
//                NSLog(@"ON SCREEN");
                //yCoord = arc4random() % (int)bounds.size.height * .8;
                yCoord = arc4random() % (int)bounds.size.height;
  //              NSLog(@"y coord is %d", yCoord);
                if(yCoord >= 0 && yCoord < bounds.size.height / 5)
                    brickRegionFull = [self brickRegionFull:1 numBricks:bricksInRegion1 + 1];
                else if(yCoord >= bounds.size.height / 5 * 1 && yCoord < bounds.size.height / 5 * 2)
                    brickRegionFull = [self brickRegionFull:2 numBricks:bricksInRegion2 + 1];
                else if(yCoord >= bounds.size.height / 5 * 2 && yCoord < bounds.size.height / 5 * 3)
                    brickRegionFull = [self brickRegionFull:3 numBricks:bricksInRegion3 + 1];
                else if(yCoord >= bounds.size.height / 5 * 3 && yCoord < bounds.size.height / 5 * 4)
                    brickRegionFull = [self brickRegionFull:4 numBricks:bricksInRegion4 + 1];
                else if(yCoord >= bounds.size.height / 5 * 4 && yCoord < bounds.size.height)
                    brickRegionFull = [self brickRegionFull:5 numBricks:bricksInRegion5 + 1];
            }
            else if(mode == ABOVE_SCREEN_BRICKS){
//                NSLog(@"ABOVE SCREEN");
//                yCoord = arc4random() % (int)bounds.size.height * .8;
                yCoord = arc4random() % (int)bounds.size.height;
                if(yCoord >= 0 && yCoord < bounds.size.height / 5)
                    brickRegionFull = [self brickRegionFull:1 numBricks:bricksInRegion1 + 1];
                else if(yCoord >= bounds.size.height / 5 * 1 && yCoord < bounds.size.height / 5 * 2)
                    brickRegionFull = [self brickRegionFull:2 numBricks:bricksInRegion2 + 1];
                else if(yCoord >= bounds.size.height / 5 * 2 && yCoord < bounds.size.height / 5 * 3)
                    brickRegionFull = [self brickRegionFull:3 numBricks:bricksInRegion3 + 1];
                else if(yCoord >= bounds.size.height / 5 * 3 && yCoord < bounds.size.height / 5 * 4)
                    brickRegionFull = [self brickRegionFull:4 numBricks:bricksInRegion4 + 1];
                else if(yCoord >= bounds.size.height / 5 * 4 && yCoord < bounds.size.height)
                    brickRegionFull = [self brickRegionFull:5 numBricks:bricksInRegion5 + 1];
                yCoord *= -1;  //invert bricks pos so they are above screen
            }
            
            [brick setFrame:CGRectMake(xCoord, yCoord, width, height)];
        } while([self bricksOverlap:brick] || brickRegionFull);//Make sure brick region is not full and bricks do not overlap
        
        float finalYCoord = [brick frame].origin.y;
        
        if(mode == ABOVE_SCREEN_BRICKS)
            finalYCoord *= -1;  //invert back to on screen coords
        
  //      NSLog(@"Final y coord is %.2f", finalYCoord);
        
        if(finalYCoord >= 0 && finalYCoord < bounds.size.height / 5)
            bricksInRegion1++;
        else if(finalYCoord >= bounds.size.height / 5 * 1 && finalYCoord < bounds.size.height / 5 * 2)
            bricksInRegion2++;
        else if(finalYCoord >= bounds.size.height / 5 * 2 && finalYCoord < bounds.size.height / 5 * 3)
            bricksInRegion3++;
        else if(finalYCoord >= bounds.size.height / 5 * 3 && finalYCoord < bounds.size.height / 5 * 4)
            bricksInRegion4++;
        else if(finalYCoord >= bounds.size.height / 5 * 4 && finalYCoord < bounds.size.height)
            bricksInRegion5++;
/*
        NSLog(@"bricks in region1: %d", bricksInRegion1);
        NSLog(@"bricks in region2: %d", bricksInRegion2);
        NSLog(@"bricks in region3: %d", bricksInRegion3);
        NSLog(@"bricks in region4: %d", bricksInRegion4);
        NSLog(@"bricks in region5: %d", bricksInRegion5);
 */
        // brick is in lower part of screen where jumper can reach it
//        if(fabs([brick frame].origin.y - bounds.size.height) <= [jumper frame].size.height)
//            lowBrick = YES;
        
        [bricks addObject:brick];
        [self addSubview:brick];
        i++;
//    }
    }
    
/*
    if(!lowBrick){  //We never added a low brick - add one manually
        
        int width = bounds.size.width * .3;
        UIImage *brickImage = [UIImage imageNamed:@"bricks.jpeg"];
        UIImageView *brick = [[UIImageView alloc] initWithImage:brickImage];
        int xCoord = arc4random() % (int)bounds.size.width * .8;
 
        int yCoord;
        if(mode == ON_SCREEN_BRICKS)
            yCoord = bounds.size.height - [jumper frame].size.height / 2;
        else if(mode == ABOVE_SCREEN_BRICKS){
            yCoord = bounds.size.height - [jumper frame].size.height / 2;
            yCoord *= -1;  //invert bricks pos so they are above screen
        }
        
        [brick setFrame:CGRectMake(xCoord, yCoord, width, height)];
        [bricks addObject:brick];
        [self addSubview:brick];
    }
*/
}

-(bool) brickRegionFull:(int) region numBricks:(int) numBricks{
    
    bool regionFull = NO;
    switch (region) {
        case 1:
            if (numBricks > MAX_BRICKS_1)
                regionFull = YES;
            break;
        case 2:
            if (numBricks > MAX_BRICKS_2)
                regionFull = YES;
            break;
        case 3:
            if (numBricks > MAX_BRICKS_3)
                regionFull = YES;
            break;
        case 4:
            if (numBricks > MAX_BRICKS_4)
                regionFull = YES;
            break;
        case 5:
            if (numBricks > MAX_BRICKS_5)
                regionFull = YES;
            break;
    }
 /*
    NSLog(@"Region %d would have %d", region, numBricks);
    if (regionFull)
        NSLog(@"returning true");
    else
        NSLog(@"returning false");
  */
    return regionFull;

}

-(bool) allBrickRegionsFull{
    return bricksInRegion1 == MAX_BRICKS_1 && bricksInRegion2 == MAX_BRICKS_2 &&
        bricksInRegion3 == MAX_BRICKS_3 && bricksInRegion4 == MAX_BRICKS_4 &&
        bricksInRegion5 == MAX_BRICKS_5;
}


-(bool) bricksOverlap:(UIImageView *) newBrick{
    int widthExtension = 50;
    int heightExtension = 30;
    for(UIImageView *existingBrick in bricks){
        CGRect extendedFrame = [existingBrick frame];  //extend the frame so that bricks are not too close together
        extendedFrame.size.width += widthExtension;
        extendedFrame.size.height += heightExtension;
        if(CGRectIntersectsRect([newBrick frame], extendedFrame))
            return YES;
    }
    return NO;
}

-(void) moveBricksDown:(int) distanceToMove{
    
    numPixelsCurrentBricksMoved += distanceToMove;  //Each call to moveBricksDown moves all bricks down 1 pixel
    [_scoreBar incrementScore];
    
    for(UIImageView *brick in bricks){
        CGPoint newPos = [brick center];
        newPos.y += distanceToMove;   //Move each brick distanceToMove pixels down the screen
        [brick setCenter:newPos];
    }
}

/*
-(void) startMovingBricks{
    brickMovementTimer = [NSTimer scheduledTimerWithTimeInterval:.005 target:self
              selector:@selector(moveBricksDown) userInfo:nil repeats:YES];
}

-(void) stopMovingBricks{
    if([brickMovementTimer isValid])
        [brickMovementTimer invalidate];
}
 */

// deletes the bricks that are no longer visible on the screen from the bricks array
-(void) removeOldBricks{
    CGRect screenBounds = [self frame];
    for(int i = 0; i < [bricks count]; i++){
        UIImageView *brick = bricks[i];
        CGPoint brickOrigin = [brick frame].origin;
        
        // brick has fallen below visible part of screen - delete it
        if(brickOrigin.y > screenBounds.size.height)
            [bricks removeObject:brick];
    }
}

-(IBAction)callSegue:(id)sender{
    NSLog(@"Calling Segue");
    [segueDelegate gameOverSegue];
}

@end
