//
//  Jumper.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    MARIO_MODE = 0,
    LUIGI_MODE = 1,
    GIANT_MARIO_MODE = 2
}JumperMode;

@interface Jumper : UIImageView

@property (nonatomic) double dx, dy;  //Velocity of jumper
@property (nonatomic) JumperMode mode;

@end
