//
//  ScoreBarView.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/14/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreBarView.h"

@implementation ScoreBarView

-(id)init{
    self = [super init];
    
    if(self){
        self.scoreLabel.text = @"0";
        scoreInt = 0;
    }
    
    return self;
}

-(void) incrementScore{
    scoreInt++;
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", scoreInt];
}

@end
