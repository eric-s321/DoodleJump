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
        
        [self addSubview:jumper];
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
    
    NSLog(@"bricks now has %lu bricks", (unsigned long)[bricks count]);
    /*
    if([brickMovementTimer isValid])
        NSLog(@"VALID");
    else
        NSLog(@"Invalid");
     */
    
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
    
    if(p.y < 0)  //We went past the top of the screen
        p.y += bounds.size.height;  //wrap around to bottom of screen
    
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
    
    // jumper is above the halfway point on the screen and the bricks are staying still
    if(jumperBottom <= midwayHeight && ![brickMovementTimer isValid]){
        [self startMovingBricks];
    }
    
    // jumper is below the halfway point on the screen and the bricks are still moving
    if(jumperBottom > midwayHeight && [brickMovementTimer isValid]){
        [self stopMovingBricks];
    }
    
    // Get rid of bricks that are now below the visible part of screen
    if(![brickMovementTimer isValid])
        [self removeOldBricks];
        //[self performSelectorOnMainThread:@selector(removeOldBricks) withObject:nil waitUntilDone:NO];
    
    [jumper setCenter:p];
}

-(void) generateBricks{
    CGRect bounds = [self bounds];
    float height = 20;
    
    bricks = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 15; i++){
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
            int yCoord = arc4random() % (int)bounds.size.height * .8;
            [brick setFrame:CGRectMake(xCoord, yCoord, width, height)];
        } while([self bricksOverlap:brick]);
        
        [bricks addObject:brick];
        [self addSubview:brick];
    }
}

-(bool) bricksOverlap:(UIImageView *) newBrick{
    for(UIImageView *existingBrick in bricks){
        CGRect extendedFrame = [existingBrick frame];  //extend the frame so that bricks are not too close together
        extendedFrame.size.width += 50;
        extendedFrame.size.height += 30;
        if(CGRectIntersectsRect([newBrick frame], extendedFrame))
            return YES;
    }
    return NO;
}

-(void) moveBricksDown{
    
    for(UIImageView *brick in bricks){
        CGPoint newPos = [brick center];
        newPos.y += 5;   //Move each brick 5 pixels down the screen
        [brick setCenter:newPos];
    }
    
}

-(void) startMovingBricks{
    brickMovementTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self
              selector:@selector(moveBricksDown) userInfo:nil repeats:YES];
}

-(void) stopMovingBricks{
    [brickMovementTimer invalidate];
}


// deletes the bricks that are no longer visible on the screen from the bricks array
-(void) removeOldBricks{
    CGRect screenBounds = [self frame];
    for(int i = 0; i < [bricks count]; i++){
        UIImageView *brick = bricks[i];
        CGPoint brickOrigin = [brick frame].origin;
        
        // The brick is no longer visible on the screen
        if(!CGRectContainsPoint(screenBounds, brickOrigin)){
            [bricks removeObject:brick];
        }
    }
}

@end
