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
        
//        [self bringSubviewToFront:_scoreBar];
//        _scoreBar.layer.zPosition = MAXFLOAT;
        UIImage *jumperImage = [UIImage imageNamed:@"mario.png"];
        jumper = [[Jumper alloc] initWithImage:jumperImage];
        [jumper setFrame:CGRectMake(bounds.size.width/2, bounds.size.height - 200, 60, 110)];
        [jumper setDx:0];
        [jumper setDy:10];
        bricks = [[NSMutableArray alloc] init];
        
        //Create brick right under where jumper spawns so he doesn't die right away
        UIImage *brickImage = [UIImage imageNamed:@"bricks.jpeg"];
        UIImageView *brick = [[UIImageView alloc] initWithImage:brickImage];
        float height = 20;
        float width = bounds.size.width * .3;
        [brick setFrame:CGRectMake(bounds.size.width/2 - 25, bounds.size.height - 100, width, height)];
        
        [bricks addObject:brick];
        
        [self addSubview:jumper];
        [self addSubview:brick];
        
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
    
    CGPoint p = [jumper center];
    CGRect jumperBounds = [jumper bounds];
    CGRect bounds = [self bounds];
    double midwayHeight = bounds.size.height / 2;
    
    [jumper setDy:[jumper dy] - .3];  //Apply "gravity" (make jumper fall)
    
    
    p.x += [jumper dx];
    p.y -= [jumper dy];  // Move jumper in direction of their y velocity
                         // positive y velocity will move up, negative down
    
    double jumperBottom = p.y + jumperBounds.size.height / 2;
    CGPoint bottomOfJumper = p;
    bottomOfJumper.y = jumperBottom;
    
    
    //We have hit the bottom of the screen - present game over screen
    if(jumperBottom >= bounds.size.height){
        // store current score in the Universe class so it can be displayed on game over view controller.
        [[Universe sharedInstance] setCurrentScore:[_scoreBar scoreInt]];
        
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"mario_gameover_sound" ofType:@"wav"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
        AudioServicesPlaySystemSound(sound);
        
        [segueDelegate gameOverSegue];
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
                //Play jump sound
                NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"mario_jump_sound" ofType:@"wav"];
                NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
                AudioServicesPlaySystemSound(sound);
                
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
    
    int i = 0;
    bricksInRegion1 = 0;
    bricksInRegion2 = 0;
    bricksInRegion3 = 0;
    bricksInRegion4 = 0;
    bricksInRegion5 = 0;
    while(![self allBrickRegionsFull]){
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
            }
            else if(mode == ABOVE_SCREEN_BRICKS){
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
        
        [bricks addObject:brick];
        [self addSubview:brick];
        i++;
    }
    
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

-(void) setSegueDelegate:(id<SegueDelegate>)delegate{
    segueDelegate = delegate;
}

@end
