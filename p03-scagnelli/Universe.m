//
//  Universe.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/17/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Universe.h"

@implementation Universe
@synthesize currentScore;

static Universe *singleton = nil;

-(id)init{
    
    if(singleton)
        return singleton;
    
    self = [super init];
    
    if(self){
        singleton = self;
    }
    
    return self;
}
    
    
+(Universe *)sharedInstance{
    
    if(singleton)
        return singleton;
    
    return [[Universe alloc] init];
}
    

@end

