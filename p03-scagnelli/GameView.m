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
        jumper.mode = MARIO_MODE;
        
        bricks = [[NSMutableArray alloc] init];
        coins = [[NSMutableArray alloc] init];
        greenMushrooms = [[NSMutableArray alloc] init];
        redMushrooms = [[NSMutableArray alloc] init];
        gameOver = NO;
        
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
        
        gameOver = YES;
        
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
                
                if(jumper.mode == MARIO_MODE){
                    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"mario_jump_sound" ofType:@"wav"];
                    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
                    AudioServicesPlaySystemSound(sound);
                    [jumper setDy:10];
                }
                else if(jumper.mode == GIANT_MARIO_MODE){
                    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"giant_mario_jump" ofType:@"wav"];
                    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
                    AudioServicesPlaySystemSound(sound);
                    [jumper setDy:20];
                }
                else if(jumper.mode == LUIGI_MODE){
                    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"luigi_jump_sound" ofType:@"wav"];
                    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
                    AudioServicesPlaySystemSound(sound);
                    [jumper setDy:15];
                }
            }
        }
    }
    
    //If we touch a coin play sound and give extra points
    for(int i = 0; i < [coins count]; i++){
        UIImageView *coin = coins[i];
        CGRect coinFrame = [coin frame];
        CGRect jumperFrame = [jumper frame];
        if(CGRectIntersectsRect(coinFrame, jumperFrame)){
            int COIN_VALUE = 100;
            //Play coin sound
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"coin_sound" ofType:@"wav"];
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
            AudioServicesPlaySystemSound(sound);
            
            // Take coin off the screen
            [coin removeFromSuperview];
            [coins removeObject:coin];
            
            int labelWidth = 100;
            int labelHeight = 30;
            int labelX = coinFrame.origin.x;
            int labelY = coinFrame.origin.y;
            UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];
            
            pointsLabel.text = [NSString stringWithFormat:@"+%d", COIN_VALUE];
            pointsLabel.font = [UIFont fontWithName:@"Super Mario 256" size:20];
            pointsLabel.textColor = [UIColor colorWithRed:252.0/255.0  //gold
                                            green:194.0/255.0 blue:0 alpha:1.0];
            
            [self addSubview:pointsLabel];
            
            [_scoreBar incrementScoreBy:COIN_VALUE];
            
            /*
             Animation code to fade the label away found on 
             http://stackoverflow.com/questions/18475850/pop-up-for-1-second
             Thanks "i_am_jorf"!
            */
            [UIView animateWithDuration:0.5 delay:1.5 options:0 animations:^{
                pointsLabel.alpha = 0;
            } completion:^(BOOL finished) {
                pointsLabel.hidden = YES;
                [pointsLabel removeFromSuperview];
            }];
        }
    }
    
    //If we touch a green mushroom change into luigi
    for(int i = 0; i < [greenMushrooms count]; i++){
        UIImageView *greenMushroom = greenMushrooms[i];
        CGRect greenMushroomFrame = [greenMushroom frame];
        CGRect jumperFrame = [jumper frame];
        if(jumper.mode == MARIO_MODE && CGRectIntersectsRect(greenMushroomFrame, jumperFrame)){
            //Play sound
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"luigi_sound" ofType:@"wav"];
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
            AudioServicesPlaySystemSound(sound);
            
            // Take mushroom off the screen
            [greenMushroom removeFromSuperview];
            [greenMushrooms removeObject:greenMushroom];
            
            //display luigi
            [jumper setImage:[UIImage imageNamed:@"Luigi.png"]];
            jumper.mode = LUIGI_MODE;
            
            [self performSelector:@selector(displayMario) withObject:nil afterDelay:15];
        }
    }
    
    //If we touch a red mushroom turn into giant mario
    for(int i = 0; i < [redMushrooms count]; i++){
        UIImageView *redMushroom = redMushrooms[i];
        CGRect redMushroomFrame = [redMushroom frame];
        CGRect jumperFrame = [jumper frame];
        if(jumper.mode == MARIO_MODE && CGRectIntersectsRect(redMushroomFrame, jumperFrame)){
            // Take mushroom off the screen
            [redMushroom removeFromSuperview];
            [redMushrooms removeObject:redMushroom];
           
            [self displayGiantMario];
            [self performSelector:@selector(displayMario) withObject:nil afterDelay:15];
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
    int NUM_REGIONS = 9;   //This is enough to not allow bricks to spawn too far apart
    bricksInRegion1 = 0;
    bricksInRegion2 = 0;
    bricksInRegion3 = 0;
    bricksInRegion4 = 0;
    bricksInRegion5 = 0;
    bricksInRegion6 = 0;
    bricksInRegion7 = 0;
    bricksInRegion8 = 0;
    bricksInRegion9 = 0;
    while(![self allBrickRegionsFull]){
        float width;
        //Create bricks of 2 different widths
        if(i % 2 == 0)
            width = bounds.size.width * .2;
        else
            width = bounds.size.width * .3;
        
        i++;
        
        //Add bricks and make sure none of them overlap with eachother
        UIImageView *brick;
        bool brickRegionFull;
        do{
            brickRegionFull = NO;
            UIImage *brickImage = [UIImage imageNamed:@"bricks.jpeg"];
            brick = [[UIImageView alloc] initWithImage:brickImage];
            
            int xCoord = arc4random() % (int)bounds.size.width * .8;
            int yCoord = arc4random() % (int)bounds.size.height;
            
            if(yCoord >= 0 && yCoord < bounds.size.height / NUM_REGIONS)
                brickRegionFull = [self brickRegionFull:1 numBricks:bricksInRegion1 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS && yCoord < bounds.size.height / NUM_REGIONS * 2)
                brickRegionFull = [self brickRegionFull:2 numBricks:bricksInRegion2 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS * 2 && yCoord < bounds.size.height / NUM_REGIONS * 3)
                brickRegionFull = [self brickRegionFull:3 numBricks:bricksInRegion3 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS * 3 && yCoord < bounds.size.height / NUM_REGIONS * 4)
                brickRegionFull = [self brickRegionFull:4 numBricks:bricksInRegion4 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS * 4 && yCoord < bounds.size.height / NUM_REGIONS * 5)
                brickRegionFull = [self brickRegionFull:5 numBricks:bricksInRegion5 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS * 5 && yCoord < bounds.size.height / NUM_REGIONS * 6)
                brickRegionFull = [self brickRegionFull:6 numBricks:bricksInRegion6 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS * 6 && yCoord < bounds.size.height / NUM_REGIONS * 7)
                brickRegionFull = [self brickRegionFull:7 numBricks:bricksInRegion7 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS * 7 && yCoord < bounds.size.height / NUM_REGIONS * 8)
                brickRegionFull = [self brickRegionFull:8 numBricks:bricksInRegion8 + 1];
            else if(yCoord >= bounds.size.height / NUM_REGIONS * 8 && yCoord < bounds.size.height)
                brickRegionFull = [self brickRegionFull:9 numBricks:bricksInRegion9 + 1];
            
            if(mode == ABOVE_SCREEN_BRICKS)
                yCoord *= -1;
            
            [brick setFrame:CGRectMake(xCoord, yCoord, width, height)];
        } while([self bricksOverlap:brick] || brickRegionFull);//Make sure brick region is not full and bricks do not overlap
        
        float finalYCoord = [brick frame].origin.y;
        
        if(mode == ABOVE_SCREEN_BRICKS)
            finalYCoord *= -1;  //invert back to on screen coords
        
        if(finalYCoord >= 0 && finalYCoord < bounds.size.height / NUM_REGIONS)
            bricksInRegion1++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS && finalYCoord < bounds.size.height / NUM_REGIONS * 2)
            bricksInRegion2++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS * 2 && finalYCoord < bounds.size.height / NUM_REGIONS * 3)
            bricksInRegion3++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS * 3 && finalYCoord < bounds.size.height / NUM_REGIONS * 4)
            bricksInRegion4++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS * 4 && finalYCoord < bounds.size.height / NUM_REGIONS * 5)
            bricksInRegion5++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS * 5 && finalYCoord < bounds.size.height / NUM_REGIONS * 6)
            bricksInRegion6++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS * 6 && finalYCoord < bounds.size.height / NUM_REGIONS * 7)
            bricksInRegion7++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS * 7 && finalYCoord < bounds.size.height / NUM_REGIONS * 8)
            bricksInRegion8++;
        else if(finalYCoord >= bounds.size.height / NUM_REGIONS * 8 && finalYCoord < bounds.size.height)
            bricksInRegion9++;
        
        //Randomly generate coins and mushrooms
        int coinProb = 8;
        int greenMushroomProb = 100;
        int redMushroomProb = 100;
        int randCoin = arc4random() % coinProb;
        int randGreenMushroom = arc4random() % greenMushroomProb;
        int randRedMushroom = arc4random() % redMushroomProb;
        
        if (randCoin == (int)coinProb / 2){
            UIImage *coinImage = [UIImage imageNamed:@"mario_coin.png"];
            UIImageView *coin = [[UIImageView alloc] initWithImage:coinImage];
            int coinHeight = 30;
            int coinWidth = 30;
            int coinXCoord = [brick frame].origin.x + [brick frame].size.width / 2 - coinWidth / 2;  //Center of brick
            int coinYCoord = [brick frame].origin.y - coinHeight; //Coin will sit on top of brick
            [coin setFrame:CGRectMake(coinXCoord, coinYCoord, coinWidth, coinHeight)];
            
            [coins addObject:coin];
            [self addSubview:coin];
        }
        
        if (randGreenMushroom == (int)greenMushroomProb / 2 && mode == ABOVE_SCREEN_BRICKS){
            UIImage *greenMushroomImage = [UIImage imageNamed:@"green_mushroom.png"];
            UIImageView *greenMushroom = [[UIImageView alloc] initWithImage:greenMushroomImage];
            int greenMushroomHeight = 30;
            int greenMushroomWidth = 30;
            int greenMushroomXCoord = [brick frame].origin.x + greenMushroomWidth;  //left end of brick 
            int greenMushroomYCoord = [brick frame].origin.y - greenMushroomHeight; //mushroom will sit on top of brick
            [greenMushroom setFrame:CGRectMake(greenMushroomXCoord, greenMushroomYCoord,
                                    greenMushroomWidth, greenMushroomHeight)];
            
            [greenMushrooms addObject:greenMushroom];
            [self addSubview:greenMushroom];
        }
        
        if (randRedMushroom == (int)redMushroomProb / 2 && mode == ABOVE_SCREEN_BRICKS){
            UIImage *redMushroomImage = [UIImage imageNamed:@"red_mushroom.png"];
            UIImageView *redMushroom = [[UIImageView alloc] initWithImage:redMushroomImage];
            int redMushroomHeight = 30;
            int redMushroomWidth = 30;
            int redMushroomXCoord = [brick frame].origin.x + redMushroomWidth;  //left end of brick
            int redMushroomYCoord = [brick frame].origin.y - redMushroomHeight;
            [redMushroom setFrame:CGRectMake(redMushroomXCoord, redMushroomYCoord,
                                    redMushroomWidth, redMushroomHeight)];
            
            [redMushrooms addObject:redMushroom];
            [self addSubview:redMushroom];
        }
        
        [bricks addObject:brick];
        [self addSubview:brick];
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
        case 6:
            if (numBricks > MAX_BRICKS_6)
                regionFull = YES;
            break;
        case 7:
            if (numBricks > MAX_BRICKS_7)
                regionFull = YES;
            break;
        case 8:
            if (numBricks > MAX_BRICKS_8)
                regionFull = YES;
            break;
        case 9:
            if (numBricks > MAX_BRICKS_9)
                regionFull = YES;
            break;
    }
    
    return regionFull;
}

-(bool) allBrickRegionsFull{
    return bricksInRegion1 == MAX_BRICKS_1 && bricksInRegion2 == MAX_BRICKS_2 &&
        bricksInRegion3 == MAX_BRICKS_3 && bricksInRegion4 == MAX_BRICKS_4 &&
        bricksInRegion5 == MAX_BRICKS_5 && bricksInRegion6 == MAX_BRICKS_6 &&
        bricksInRegion7 == MAX_BRICKS_7 && bricksInRegion8 == MAX_BRICKS_8 &&
        bricksInRegion9 == MAX_BRICKS_9;
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
    //Move the coins too!
    for(UIImageView *coin in coins){
        CGPoint newPos = [coin center];
        newPos.y += distanceToMove;   
        [coin setCenter:newPos];
    }
    
    //And the green mushrooms
    for(UIImageView *greenMushroom in greenMushrooms){
        CGPoint newPos = [greenMushroom center];
        newPos.y += distanceToMove;
        [greenMushroom setCenter:newPos];
    }
    
    //And the red ones...
    for(UIImageView *redMushroom in redMushrooms){
        CGPoint newPos = [redMushroom center];
        newPos.y += distanceToMove;
        [redMushroom setCenter:newPos];
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
    
    //Remove old coins also
    for(int i = 0; i < [coins count]; i++){
        UIImageView *coin = coins[i];
        CGPoint coinOrigin = [coin frame].origin;
        
        if(coinOrigin.y > screenBounds.size.height)
            [coins removeObject:coin];
    }
    
    //And old green mushrooms
    for(int i = 0; i < [greenMushrooms count]; i++){
        UIImageView *greenMushroom = greenMushrooms[i];
        CGPoint greenMushroomOrigin = [greenMushroom frame].origin;
        
        if(greenMushroomOrigin.y > screenBounds.size.height)
            [greenMushrooms removeObject:greenMushroom];
    }
    
    for(int i = 0; i < [redMushrooms count]; i++){
        UIImageView *redMushroom = redMushrooms[i];
        CGPoint redMushroomOrigin = [redMushroom frame].origin;
        
        if(redMushroomOrigin.y > screenBounds.size.height)
            [redMushrooms removeObject:redMushroom];
    }
}

-(void) setSegueDelegate:(id<SegueDelegate>)delegate{
    segueDelegate = delegate;
}

-(void) displayMario{
    if(jumper.mode != MARIO_MODE && !gameOver){
        
        if(jumper.mode == GIANT_MARIO_MODE){
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"mario_powerdown" ofType:@"wav"];
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
            AudioServicesPlaySystemSound(sound);
            CGRect frame = [jumper frame];
            [jumper setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height / 2,
                                    frame.size.width / 2, frame.size.height / 2)];
        }
        
        if(jumper.mode == LUIGI_MODE){
            NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"mario_name" ofType:@"wav"];
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
            AudioServicesPlaySystemSound(sound);
            [jumper setImage:[UIImage imageNamed:@"mario.png"]];
        }
        
        jumper.mode = MARIO_MODE;
    }
}

-(void) displayGiantMario{
    if(jumper.mode == MARIO_MODE){
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"mario_powerup" ofType:@"wav"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
        AudioServicesPlaySystemSound(sound);
        
        CGRect frame = [jumper frame];
        
        //Double the size of mario
        [jumper setFrame:CGRectMake(frame.origin.x, frame.origin.y - frame.size.height,
                                    frame.size.width * 2, frame.size.height * 2)];
        jumper.mode = GIANT_MARIO_MODE;
    }
}

@end
