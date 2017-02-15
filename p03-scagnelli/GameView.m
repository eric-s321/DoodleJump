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
        
        UIImage *jumperImage = [UIImage imageNamed:@"mario.png"];
        jumper = [[Jumper alloc] initWithImage:jumperImage];
        [jumper setFrame:CGRectMake(bounds.size.width/2, bounds.size.height - 100, 60, 110)];
        [jumper setDx:0];
        [jumper setDy:10];
        bricks = [[NSMutableArray alloc] init];
        
        [self addSubview:jumper];
        
        numPixelsCurrentBricksMoved = 0;
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
    
    NSLog(@"Score is %d", [_scoreBar.scoreLabel.text intValue]);
    CGPoint p = [jumper center];
    CGRect jumperBounds = [jumper bounds];
    CGRect bounds = [self bounds];
    double midwayHeight = bounds.size.height / 2;
    
    [jumper setDy:[jumper dy] - .3];  //Apply "gravity" (make jumper fall)
    
    
    /*
    if([jumper dy] > -.3 && [jumper dy] < 0){ //Jumper is approx at top of jump
        NSLog(@"Velocity is 0");
    }
    */
    
    p.x += [jumper dx];
    p.y -= [jumper dy];  // Move jumper in direction of their y velocity
                         // positive y velocity will move up, negative down
    
    double jumperBottom = p.y + jumperBounds.size.height / 2;
    CGPoint bottomOfJumper = p;
    bottomOfJumper.y = jumperBottom;
    
    
    //We went past the bottom of the screen
    if(jumperBottom > bounds.size.height){
        p.y = bounds.size.height - jumperBounds.size.height / 2;  //Set at the bottom of screen
        [jumper setDy:10];  //Give positive velocity
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
            if(CGRectContainsPoint(brickFrame, bottomOfJumper))
                [jumper setDy:10];
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
    
    for (int i = 0; i < 10; i++){
        float width;
        //Create bricks of 2 different widths
        if(i % 2 == 0)
            width = bounds.size.width * .2;
        else
            width = bounds.size.width * .3;
        
        //Add bricks and make sure none of them overlap with eachother
        UIImageView *brick;
        do{
            UIImage *brickImage = [UIImage imageNamed:@"bricks.jpeg"];
            brick = [[UIImageView alloc] initWithImage:brickImage];
            int xCoord = arc4random() % (int)bounds.size.width * .8;
            
            int yCoord;
            if(mode == ON_SCREEN_BRICKS)
                yCoord = arc4random() % (int)bounds.size.height * .8;
            else if(mode == ABOVE_SCREEN_BRICKS){
                yCoord = arc4random() % (int)bounds.size.height * .8;
                yCoord *= -1;  //invert bricks pos so they are above screen
            }
            
            [brick setFrame:CGRectMake(xCoord, yCoord, width, height)];
        } while([self bricksOverlap:brick]);
        
        // brick is in lower part of screen where jumper can reach it
        if(fabs([brick frame].origin.y - bounds.size.height) <= [jumper frame].size.height)
            lowBrick = YES;
        
        [bricks addObject:brick];
        [self addSubview:brick];
    }
    
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

@end
