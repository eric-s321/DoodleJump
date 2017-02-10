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
@synthesize tilt;
@synthesize jumper;

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if(self){
        CGRect bounds = [self bounds];
        
        //jumper = [[Jumper alloc] initWithFrame:CGRectMake(bounds.size.width / 2,
        //          bounds.size.height - 20, 20, 20)];
        //[jumper setBackgroundColor:[UIColor blueColor]];
        UIImage *jumperImage = [UIImage imageNamed:@"mario.png"];
        jumper = [[Jumper alloc] initWithImage:jumperImage];
        [jumper setFrame:CGRectMake(bounds.size.width/2, bounds.size.height - 100, 60, 110)];
        //[jumper setContentMode:UIViewContentModeScaleAspectFit];
        [jumper setDx:0];
        [jumper setDy:10];
        
        [self addSubview:jumper];
    }
    return self;
}

-(void) update:(CADisplayLink *)sender{
    
    CGPoint p = [jumper center];
    CGRect jumperBounds = [jumper bounds];
    CGRect bounds = [self bounds];
    
    [jumper setDy:[jumper dy] - .3];  //Apply "gravity" (make jumper fall)
    
    //Apply tilt and limit to + or - 5
    [jumper setDx:[jumper dx] + tilt];
    if ([jumper dx] > 5)
        [jumper setDx:5];
    if ([jumper dx] < -5)
        [jumper setDx:-5];
    
    
    p.x += [jumper dx];
    p.y -= [jumper dy];  // Move jumper in direction of their y velocity
                         // positive y velocity will move up, negative down
    
    double jumperBottom = p.y + jumperBounds.size.height / 2;
    
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
    
    
    [jumper setCenter:p];
    
}

@end
