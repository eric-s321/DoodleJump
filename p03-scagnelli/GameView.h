//
//  GameView.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "Jumper.h"

@interface GameView : UIView

@property (strong, nonatomic) Jumper *jumper;

-(void) update:(CADisplayLink *)sender;
-(void) updateVelocity:(CMAccelerometerData *) accelData;

@end
