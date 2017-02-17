//
//  RoundedButton.m
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/16/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoundedButton.h"


@implementation RoundedButton

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    if(self){
        self.layer.cornerRadius = 20;
    }
    return self;
}
    
@end
