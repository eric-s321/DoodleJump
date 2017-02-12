//
//  ViewController.h
//  p03-scagnelli
//
//  Created by Eric Scagnelli on 2/9/17.
//  Copyright © 2017 escagne1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "GameView.h"

@interface ViewController : UIViewController{
    CADisplayLink *displayLink;
}

@property (strong, nonatomic) IBOutlet GameView *gameView;

@end

